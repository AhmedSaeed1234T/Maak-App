import 'dart:async';
import 'dart:convert';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TokenService {
  final FlutterSecureStorage storage;
  String? _accessToken;
  String? _refreshToken;
  String? refreshExpiry;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  // ✅ NEW: Caching mechanism to reduce API calls
  DateTime? lastValidationTime;
  bool? lastValidationResult;
  static const validationCacheDuration = Duration(
    minutes: 5,
  ); // Cache for 5 minutes

  // Offline check tracking
  DateTime? lastOnlineCheck;
  static const maxOfflineDuration = Duration(
    days: 2,
  ); // Force online check after 7 days

  TokenService({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const refreshExpiryKey = 'refresh_expiry';
  static const lastOnlineCheckKey = 'last_online_check';

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

  // ------------------------------------------------------------
  // Clear Tokens (Logout)
  // ------------------------------------------------------------
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    refreshExpiry = null;
    lastValidationTime = null;
    lastValidationResult = null;
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

    final subscriptionExpired = await isSubscriptionExpired();
    if (subscriptionExpired) {
      debugPrint('Subscription expired');
      return false;
    }

    return true;
  }

  // ------------------------------------------------------------
  // ✅ NEW: Check if we should validate (uses cache)
  // ------------------------------------------------------------
  Future<bool> shouldValidateSession({bool forceValidation = false}) async {
    // Force validation overrides cache
    if (forceValidation) {
      debugPrint("🔄 Force validation requested");
      return true;
    }

    // If we validated recently and it was successful, skip
    if (lastValidationTime != null && lastValidationResult == true) {
      final timeSinceLastCheck = DateTime.now().difference(lastValidationTime!);

      if (timeSinceLastCheck < validationCacheDuration) {
        debugPrint(
          "⚡ Using cached validation (${timeSinceLastCheck.inSeconds}s ago)",
        );
        return false; // Don't need to validate
      }
    }

    return true; // Need to validate
  }

  // ------------------------------------------------------------
  // Refresh Access Token (with caching)
  // ------------------------------------------------------------
  Future<bool> refreshAccessToken({bool forceRefresh = false}) async {
    // Check if we need to refresh at all (unless forced)
    if (!forceRefresh && !await shouldValidateSession()) {
      return true; // Use cached result
    }

    // If already refreshing, wait for that refresh to complete
    if (_isRefreshing) {
      debugPrint("Already refreshing, waiting...");
      return await _refreshCompleter!.future;
    }

    // Set refreshing flag and create completer
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      debugPrint("🔄 Refreshing token...");
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        lastValidationResult = false;
        _refreshCompleter!.complete(false);
        return false;
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
        lastValidationResult = false;
        _refreshCompleter!.complete(false);
        return false;
      }

      final data = jsonDecode(response.body);

      // Validate server response
      if (data['accessToken'] == null ||
          data['refreshToken'] == null ||
          data['refreshTokenExpiry'] == null) {
        debugPrint('Invalid refresh response from server: $data');
        lastValidationResult = false;
        _refreshCompleter!.complete(false);
        return false;
      }

      // Save new tokens
      await saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        refreshTokenExpiry: data['refreshTokenExpiry'],
      );

      // Optional: subscription update
      if (data['subscriptionExpiry'] != null) {
        try {
          final subExpiry = DateTime.parse(data['subscriptionExpiry']);
          await saveCurrentUserSubscription(subExpiry);
        } catch (e) {
          debugPrint("Subscription date parse error: $e");
        }
      }

      // ✅ Update cache
      lastValidationTime = DateTime.now();
      lastValidationResult = true;

      _refreshCompleter!.complete(true);
      return true;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      lastValidationResult = false;
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  // ------------------------------------------------------------
  // Check if we MUST go online
  // ------------------------------------------------------------
  Future<bool> _mustCheckOnline() async {
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
  // Enhanced Session Validation
  // ------------------------------------------------------------
  Future<SessionValidityResult> checkSessionValidity({
    bool forceValidation = false,
  }) async {
    // 1. Check local token validity first (fast, no API call)
    final hasValidLocalTokens = await isRefreshTokenLocallyValid();

    if (!hasValidLocalTokens) {
      return SessionValidityResult(
        isValid: false,
        reason: 'Tokens expired locally',
        requiresLogin: true,
      );
    }

    // 2. Check if we MUST validate online (7 days passed)
    if (await _mustCheckOnline()) {
      debugPrint(
        "⚠️ Must check online (${maxOfflineDuration.inDays} days since last validation)",
      );

      try {
        final refreshed = await refreshAccessToken(forceRefresh: true);

        if (refreshed) {
          lastOnlineCheck = DateTime.now();
          await storage.write(
            key: lastOnlineCheckKey,
            value: lastOnlineCheck!.toIso8601String(),
          );

          return SessionValidityResult(
            isValid: true,
            reason: 'Online validation successful',
            requiresLogin: false,
          );
        } else {
          // Server rejected tokens - force login
          return SessionValidityResult(
            isValid: false,
            reason: 'Server rejected tokens',
            requiresLogin: true,
          );
        }
      } catch (e) {
        // Network error - but we MUST validate online
        return SessionValidityResult(
          isValid: false,
          reason: 'Cannot validate online (required)',
          requiresLogin: true,
          showOfflineWarning: true,
        );
      }
    }

    // 3. Check if we should validate (uses 5-minute cache)
    if (!forceValidation && !await shouldValidateSession()) {
      debugPrint("⚡ Skipping validation (cached)");
      return SessionValidityResult(
        isValid: true,
        reason: 'Using cached validation',
        requiresLogin: false,
      );
    }

    // 4. Try online validation (best effort)
    try {
      final refreshed = await refreshAccessToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (refreshed) {
        lastOnlineCheck = DateTime.now();
        await storage.write(
          key: lastOnlineCheckKey,
          value: lastOnlineCheck!.toIso8601String(),
        );

        return SessionValidityResult(
          isValid: true,
          reason: 'Online validation successful',
          requiresLogin: false,
        );
      }
    } catch (e) {
      debugPrint("Online check failed: $e");
    }

    // 5. Offline mode - allow with local validation
    return SessionValidityResult(
      isValid: true,
      reason: 'Offline mode - using local validation',
      requiresLogin: false,
      isOfflineMode: true,
    );
  }
}

// Result class for clear communication
class SessionValidityResult {
  final bool isValid;
  final String reason;
  final bool requiresLogin;
  final bool isOfflineMode;
  final bool showOfflineWarning;

  SessionValidityResult({
    required this.isValid,
    required this.reason,
    required this.requiresLogin,
    this.isOfflineMode = false,
    this.showOfflineWarning = false,
  });
}
