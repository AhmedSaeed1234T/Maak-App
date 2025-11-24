import 'dart:convert';

import 'package:abokamall/helpers/apiroute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenService {
  final FlutterSecureStorage _storage;

  // In-memory cache (optional, faster than reading from storage every time)
  String? _accessToken;
  String? _refreshToken;

  TokenService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // Keys for storage
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _refreshTokenSavedAtKey = 'refresh_token_saved_at';

  /// Save both tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    debugPrint("Successful in storing the token");
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(
      key: _refreshTokenSavedAtKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Save accessToken only
  Future<void> saveAccessToken({required String accessToken}) async {
    _accessToken = accessToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  /// Read accessToken
  Future<String?> getAccessToken() async {
    try {
      _accessToken ??= await _storage.read(key: _accessTokenKey);

      return _accessToken;
    } catch (e) {
      print('SecureStorage read failed: $e');
      await _storage.deleteAll(); // optional recovery
    }
    return null;
  }

  /// Read refreshToken
  Future<String?> getRefreshToken() async {
    _refreshToken ??= await _storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  /// Delete both tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _refreshTokenSavedAtKey);
  }

  /// Returns true if the refreshToken was saved less than 2 weeks ago.
  Future<bool> isRefreshTokenLocallyValid() async {
    final token = await getRefreshToken();
    final savedAtStr = await _storage.read(key: _refreshTokenSavedAtKey);
    if (token == null || savedAtStr == null) return false;
    final savedAt = int.tryParse(savedAtStr) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const twoWeeksMs = 14 * 24 * 60 * 60 * 1000;
    return (now - savedAt) < twoWeeksMs;
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    debugPrint("Sending to api currently");
    try {
      final response = await http.post(
        Uri.parse('$apiRoute/auth/refresh'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint(response.toString());
      if (response.statusCode != 200) {
        debugPrint('Token refresh failed: ${response.body}');
        return false;
      }
      final data = jsonDecode(response.body);
      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];
      await saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } catch (e) {
      return false; // refresh failed
    }
  }
}
