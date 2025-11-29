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

  TokenService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  /// Save tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
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

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Check if user is eligible to use app offline
  /// Returns true if refresh token exists and subscription is within expiry + 1 day grace period
  Future<bool> isRefreshTokenLocallyValid() async {
    final token = await getRefreshToken();
    if (token == null) return false;

    final expiryDate = await getCurrentUserSubscription();
    if (expiryDate == null) return false;

    // Add 1-day grace period
    if ((expiryDate.add(const Duration(days: 1))).isBefore(DateTime.now())) {
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
      await saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
