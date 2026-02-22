import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:abokamall/services/ProfileCacheService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TokenService {
  final FlutterSecureStorage storage;
  String? _accessToken;
  String? _refreshToken;
  String? refreshExpiry;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  // Offline check tracking (for 2-day limit)
  DateTime? lastOnlineCheck;
  static const maxOfflineDuration = Duration(days: 2);

  TokenService({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const refreshExpiryKey = 'refresh_expiry';
  static const lastOnlineCheckKey = 'last_online_check';
  static const _refreshInvalidKey = 'refresh_invalid';

  // ------------------------------------------------------------
  // Save Tokens
  // ------------------------------------------------------------
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String refreshTokenExpiry,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    refreshExpiry = refreshTokenExpiry;

    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
    await storage.write(key: refreshExpiryKey, value: refreshTokenExpiry);
    // Clearing any previous permanent-refresh-failure flag on new tokens
    await storage.delete(key: _refreshInvalidKey);

    // ✅ NEW: Mark that we were online JUST NOW.
    // This allows the user to stay offline for the next 48 hours.
    await updateLastOnlineCheck();
    // After saving tokens, ensure presence controller connects to mark user online
    try {
      if (getIt.isRegistered<PresenceController>()) {
        // Fire-and-forget connection; token is now available
        getIt<PresenceController>().connect();
      }
    } catch (e) {
      debugPrint('Error connecting presence after saveTokens: $e');
    }
  }

  // ------------------------------------------------------------
  // Getters
  // ------------------------------------------------------------
  Future<String?> getAccessToken() async {
    _accessToken ??= await storage.read(key: _accessTokenKey);
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    _refreshToken ??= await storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  Future<DateTime?> getRefreshTokenExpiry() async {
    refreshExpiry ??= await storage.read(key: refreshExpiryKey);
    if (refreshExpiry == null) return null;

    try {
      return DateTime.parse(refreshExpiry!).toUtc();
    } catch (e) {
      debugPrint('Error parsing refresh token expiry: $e');
      return null;
    }
  }

  /// If a previous refresh attempt was marked permanently invalid by the server
  /// (e.g. subscription revoked), this returns the server-provided reason.
  Future<String?> getRefreshInvalidReason() async {
    return await storage.read(key: _refreshInvalidKey);
  }

  /// Convenience helper: returns true when a previous refresh attempt was
  /// marked permanently invalid by the server (e.g. subscription revoked).
  Future<bool> isRefreshInvalid() async {
    final r = await getRefreshInvalidReason();
    return r != null && r.isNotEmpty;
  }

  /// ✅ NEW: Clear the permanent invalidation status to allow recovery
  Future<void> clearRefreshInvalidStatus() async {
    await storage.delete(key: _refreshInvalidKey);
  }

  /// ✅ NEW: Force clear the expiry flag globally
  Future<void> forceClearExpiryFlag() async {
    final email = await getCurrentUser();
    if (email != null) {
      await saveUserIsExpired(email, false);
    }
  }

  // ------------------------------------------------------------
  // Clear Tokens (Logout)
  // ------------------------------------------------------------
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    refreshExpiry = null;
    lastOnlineCheck = null;

    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: refreshExpiryKey);
    await storage.delete(key: lastOnlineCheckKey);
  }

  // ------------------------------------------------------------
  // Check Local Token Validity
  // ------------------------------------------------------------
  Future<bool> isRefreshTokenLocallyValid() async {
    final token = await getRefreshToken();
    if (token == null) return false;

    final expiry = await getRefreshTokenExpiry();
    if (expiry == null) return false;

    final now = DateTime.now().toUtc();
    if (expiry.isBefore(now)) {
      debugPrint('Refresh token expired');
      return false;
    }

    debugPrint('TokenService: Local tokens are valid');
    return true;
  }

  // ------------------------------------------------------------
  // Refresh Access Token
  // ✅ SIMPLIFIED: No more 5-minute cache logic
  // Just refresh when called (usually triggered by 401)
  // ------------------------------------------------------------
  Future<RefreshResult> refreshAccessToken() async {
    // If previously marked as permanently invalid (e.g. subscription invalid), do not retry
    final invalid = await storage.read(key: _refreshInvalidKey);
    if (invalid != null) {
      debugPrint('🚫 Refresh permanently invalid: $invalid');
      return RefreshResult(isSuccess: false);
    }
    // If already refreshing, wait for that refresh to complete
    if (_isRefreshing) {
      debugPrint("⏳ Already refreshing, waiting...");
      final result = await _refreshCompleter!.future;
      return RefreshResult(isSuccess: result);
    }

    // Set refreshing flag and create completer
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      debugPrint("🔄 Refreshing token...");
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return RefreshResult(isSuccess: false);
      }

      final response = await http
          .post(
            Uri.parse('$apiRoute/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Refresh request timed out');
            },
          );

      if (response.statusCode != 200) {
        debugPrint('Refresh failed: ${response.body}');

        // Try to parse server error to detect permanent failure reasons
        try {
          final err = jsonDecode(response.body);
          final errCode = err['errorCode']?.toString();
          final errMsg = err['message']?.toString() ?? '';

          if (errCode == 'SubscriptionInvalid' ||
              errMsg.toLowerCase().contains('expired or revoked')) {
            // Mark as permanently invalid so we don't keep retrying
            await storage.write(
              key: _refreshInvalidKey,
              value: errMsg.isNotEmpty ? errMsg : errCode ?? 'invalid_refresh',
            );

            // ✅ NEW: Proactively mark as expired locally so logic reacts
            if (errCode == 'SubscriptionInvalid') {
              final email = await getCurrentUser();
              if (email != null) await saveUserIsExpired(email, true);
            }

            // Per user request, we don't clear tokens or logout here anymore
            // await clearTokens();

            _refreshCompleter!.complete(false);
            return RefreshResult(
              isSuccess: false,
              isExpired: err['isExpired'] ?? false,
              expiryDate: err['subscriptionExpiry'],
            );
          }
        } catch (e) {
          debugPrint('Error parsing refresh error response: $e');
        }

        _refreshCompleter!.complete(false);
        return RefreshResult(isSuccess: false);
      }

      final data = jsonDecode(response.body);

      // Validate server response
      if (data['accessToken'] == null ||
          data['refreshToken'] == null ||
          data['refreshTokenExpiry'] == null) {
        debugPrint('Invalid refresh response from server: $data');
        _refreshCompleter!.complete(false);
        return RefreshResult(isSuccess: false);
      }

      // Save new tokens
      await saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        refreshTokenExpiry: data['refreshTokenExpiry'],
      );

      // Successful refresh: clear permanent-invalid flag
      await storage.delete(key: _refreshInvalidKey);

      // Optional: subscription update
      if (data['subscriptionExpiry'] != null) {
        try {
          final subExpiry = DateTime.parse(data['subscriptionExpiry']);
          await saveCurrentUserSubscription(subExpiry);
        } catch (e) {
          debugPrint("Subscription date parse error: $e");
        }
      }

      await saveCurrentUserIsExpired(data['isExpired'] ?? false);

      debugPrint("✅ Token refreshed successfully");
      _refreshCompleter!.complete(true);
      return RefreshResult(
        isSuccess: true,
        isExpired: data['isExpired'] ?? false,
        expiryDate: data['subscriptionExpiry'],
      );
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      _refreshCompleter!.complete(false);
      // ✅ Detect if it was a network error (Socket, Timeout, etc.)
      final isNet =
          e is SocketException ||
          e is TimeoutException ||
          e.toString().contains('timed out');
      return RefreshResult(isSuccess: false, isNetworkError: isNet);
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  // ------------------------------------------------------------
  // Check if we MUST go online (2-day check)
  // ------------------------------------------------------------
  Future<bool> mustCheckOnline() async {
    if (lastOnlineCheck == null) {
      // Try to load from storage
      final stored = await storage.read(key: lastOnlineCheckKey);
      if (stored != null) {
        try {
          lastOnlineCheck = DateTime.parse(stored);
        } catch (e) {
          debugPrint('Error parsing last online check: $e');
        }
      }
    }

    if (lastOnlineCheck == null) return true;

    final timeSinceLastCheck = DateTime.now().difference(lastOnlineCheck!);
    return timeSinceLastCheck > maxOfflineDuration;
  }

  // ------------------------------------------------------------
  // Update Last Online Check (call this after successful API calls)
  // ------------------------------------------------------------
  Future<void> updateLastOnlineCheck() async {
    lastOnlineCheck = DateTime.now();
    await storage.write(
      key: lastOnlineCheckKey,
      value: lastOnlineCheck!.toIso8601String(),
    );
  }

  // ------------------------------------------------------------
  // ✅ SIMPLIFIED Session Validation
  // Only checks local validity + 2-day offline limit
  // Does NOT proactively refresh tokens
  // ------------------------------------------------------------
  Future<SessionValidityResult> checkSessionValidity() async {
    // 0. ✅ NEW: Strict boolean check FIRST (per user request)
    // This ensures non-eligible users are caught even if tokens are valid.
    if (await isCurrentUserExpired()) {
      debugPrint("🚫 User is marked as expired (boolean flag)");

      return SessionValidityResult(
        isValid: false,
        reason: 'Subscription expired (boolean flag)',
        requiresLogin: true,
        isSubscriptionExpired: true,
      );
    }

    // 1. Check local token validity first (fast, no API call)
    final hasValidLocalTokens = await isRefreshTokenLocallyValid();

    if (!hasValidLocalTokens) {
      return SessionValidityResult(
        isValid: false,
        reason: 'Tokens expired locally',
        requiresLogin: true,
      );
    }

    // 2. Check if we MUST validate online (2+ days passed)
    if (await mustCheckOnline()) {
      debugPrint(
        "⚠️ Must check online (${maxOfflineDuration.inDays} days since last validation)",
      );

      try {
        final refreshResult = await refreshAccessToken();

        if (refreshResult.isSuccess) {
          debugPrint(
            'TokenService: ✅ Online validation successful via refresh',
          );
          await updateLastOnlineCheck();

          return SessionValidityResult(
            isValid: true,
            reason: 'Online validation successful',
            requiresLogin: false,
          );
        } else if (refreshResult.isNetworkError) {
          debugPrint(
            'TokenService: ❌ Online validation FAILED (Network Error)',
          );
          // Network error - but we MUST validate online
          // ✅ SECURITY: Clear sensitive cache if we can't validate online after 2 days
          await getIt<UserListCacheService>().clearAllCache();
          await getIt<ProfileCacheService>().clearCache();

          return SessionValidityResult(
            isValid: false,
            reason:
                'Cannot validate online (network error during required check)',
            requiresLogin: true,
            showOfflineWarning: true,
          );
        } else {
          debugPrint(
            'TokenService: ❌ Online validation failed: Server rejected tokens',
          );
          // Server rejected tokens - force login
          return SessionValidityResult(
            isValid: false,
            reason: 'Server rejected tokens during required online check',
            requiresLogin: true,
            isSubscriptionExpired: refreshResult.isExpired, // ✅ PASS THIS UP
          );
        }
      } catch (e) {
        debugPrint(
          'TokenService: ❌ Unexpected error during required online check: $e',
        );

        // ✅ SECURITY: Clear sensitive cache if we can't validate online after 2 days
        await getIt<UserListCacheService>().clearAllCache();
        await getIt<ProfileCacheService>().clearCache();

        return SessionValidityResult(
          isValid: false,
          reason: 'Unexpected error during online check',
          requiresLogin: true,
          showOfflineWarning: true,
        );
      }
    }

    // 3. ✅ Tokens are valid locally and within 2-day window
    // DON'T refresh here - let API calls handle 401s
    return SessionValidityResult(
      isValid: true,
      reason: 'Local validation successful',
      requiresLogin: false,
    );
  }

  // ------------------------------------------------------------
  /// Extracts the user ID (uid/sub) from the current access token.
  // ------------------------------------------------------------
  Future<String?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      debugPrint('TokenService: Decoded token payload: $map');

      final candidates = ['uid', 'sub', 'nameid', 'userId', 'unique_name'];
      for (final k in candidates) {
        if (map.containsKey(k) && map[k] != null) return map[k].toString();
      }
      return null;
    } catch (e) {
      debugPrint('Token parse error in getUserId: $e');
      return null;
    }
  }

  // ------------------------------------------------------------
  /// ✅ NEW: Centralized security decision for data access
  /// Returns true ONLY if:
  /// 1. User is NOT past the 2-day offline limit (Hard Blockade)
  /// Note: Explicitly allows data visibility during subscription expiry (Warning only)
  // ------------------------------------------------------------
  Future<bool> isDataAccessibleAsync() async {
    // SECURITY CUTOFF: Only block if past the 2-day offline limit.
    // Explicitly allow visibility during expiry per user request.
    if (await mustCheckOnline()) {
      debugPrint("🚫 Security: Data inaccessible (Offline > 2 days)");
      return false;
    }

    debugPrint("✅ Security: Data access allowed");
    return true;
  }
}

class RefreshResult {
  final bool isSuccess;
  final bool isExpired;
  final bool isNetworkError; // ✅ NEW
  final String? expiryDate;

  RefreshResult({
    required this.isSuccess,
    this.isExpired = false,
    this.isNetworkError = false,
    this.expiryDate,
  });
}

// Result class for clear communication
class SessionValidityResult {
  final bool isValid;
  final String reason;
  final bool requiresLogin;
  final bool showOfflineWarning;
  final bool isSubscriptionExpired; // ✅ NEW

  SessionValidityResult({
    required this.isValid,
    required this.reason,
    required this.requiresLogin,
    this.showOfflineWarning = false,
    this.isSubscriptionExpired = false, // ✅ NEW
  });
}
