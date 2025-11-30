import 'dart:convert';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TokenService {
  final FlutterSecureStorage _storage;
  String? _accessToken;
  String? _refreshToken;
  String? _refreshExpiry;

  TokenService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _refreshExpiryKey = 'refresh_expiry'; // ✅ Better name

  /// Save tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String
    refreshTokenExpiry, // ✅ This should be UTC ISO string from backend
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _refreshExpiry = refreshTokenExpiry;

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _refreshExpiryKey, value: refreshTokenExpiry);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    _accessToken ??= await _storage.read(key: _accessTokenKey);
    return _accessToken;
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    _refreshToken ??= await _storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  /// Get refresh token expiry (UTC DateTime)
  Future<DateTime?> getRefreshTokenExpiry() async {
    _refreshExpiry ??= await _storage.read(key: _refreshExpiryKey);
    if (_refreshExpiry == null) return null;

    try {
      debugPrint(DateTime.parse(_refreshExpiry!).toString());
      return DateTime.parse(_refreshExpiry!); // ✅ Parse UTC DateTime
    } catch (e) {
      debugPrint('Error parsing refresh expiry: $e');
      return null;
    }
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _refreshExpiry = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _refreshExpiryKey);
  }

  /// ✅ FIXED: Check if refresh token is locally valid
  Future<bool> isRefreshTokenLocallyValid() async {
    final token = await getRefreshToken();
    if (token == null) return false;

    // Check refresh token expiry (UTC comparison)
    final refreshExpiry = await getRefreshTokenExpiry();
    if (refreshExpiry == null) return false;

    // ✅ Compare UTC to UTC
    if (refreshExpiry.isBefore(DateTime.now().toUtc())) {
      debugPrint('Refresh token expired');
      return false;
    }

    // Check subscription expiry (date-only comparison)
    final subscriptionExpired = await isSubscriptionExpired();
    if (subscriptionExpired) {
      debugPrint('Subscription expired');
      return false;
    }

    return true;
  }

  /// Refresh access token using backend
  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiRoute/auth/refresh'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);

      // ✅ Save new tokens
      await saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        refreshTokenExpiry: data['refreshTokenExpiry'], // ✅ UTC ISO string
      );

      // ✅ Update subscription if provided
      if (data['subscriptionExpiry'] != null) {
        debugPrint("Saving....");
        final subExpiry = DateTime.parse(
          data['subscriptionExpiry'],
        ); // Egypt date
        await saveCurrentUserSubscription(subExpiry);
      }

      return true;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }
}
