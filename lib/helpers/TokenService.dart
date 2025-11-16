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
  }

  /// Save both tokens
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
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiRoute/auth/refresh'),
        body: {'refreshToken': refreshToken},
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body);
      final newAccessToken = data['accessToken'];
      await saveAccessToken(accessToken: newAccessToken);
      return true;
    } catch (e) {
      return false; // refresh failed
    }
  }
}
