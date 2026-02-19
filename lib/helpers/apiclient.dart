import 'dart:convert';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/apiroute.dart';

class ApiClient {
  final TokenService _tokenService;

  ApiClient(this._tokenService);

  /// GET request with automatic 401 handling
  Future<http.Response> get(String endpoint) async {
    return _makeRequest(() async {
      final needsAuth = !_isAuthEndpoint(endpoint);
      final token = needsAuth ? await _tokenService.getAccessToken() : null;
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (needsAuth && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return http.get(Uri.parse('$apiRoute$endpoint'), headers: headers);
    });
  }

  /// POST request with automatic 401 handling
  Future<http.Response> post(String endpoint, {Object? body}) async {
    return _makeRequest(() async {
      final needsAuth = !_isAuthEndpoint(endpoint);
      final token = needsAuth ? await _tokenService.getAccessToken() : null;
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (needsAuth && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return http.post(
        Uri.parse('$apiRoute$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// PUT request with automatic 401 handling
  Future<http.Response> put(String endpoint, {Object? body}) async {
    return _makeRequest(() async {
      final needsAuth = !_isAuthEndpoint(endpoint);
      final token = needsAuth ? await _tokenService.getAccessToken() : null;
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (needsAuth && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return http.put(
        Uri.parse('$apiRoute$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// PATCH request with automatic 401 handling
  Future<http.Response> patch(String endpoint, {Object? body}) async {
    return _makeRequest(() async {
      final needsAuth = !_isAuthEndpoint(endpoint);
      final token = needsAuth ? await _tokenService.getAccessToken() : null;
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (needsAuth && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return http.patch(
        Uri.parse('$apiRoute$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// DELETE request with automatic 401 handling
  Future<http.Response> delete(String endpoint) async {
    return _makeRequest(() async {
      final needsAuth = !_isAuthEndpoint(endpoint);
      final token = needsAuth ? await _tokenService.getAccessToken() : null;
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (needsAuth && token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return http.delete(Uri.parse('$apiRoute$endpoint'), headers: headers);
    });
  }

  bool _isAuthEndpoint(String endpoint) {
    final e = endpoint.toLowerCase();
    if (e == "/auth/add-firebase-token" || e.startsWith("/auth/refresh")) {
      return false;
    }
    return e.startsWith('/auth') || e.contains('/auth/');
  }

  /// ✅ Core request handler - automatically retries on 401
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunction,
  ) async {
    // Make initial request
    http.Response response = await requestFunction();

    // If 401 Unauthorized, refresh token and retry ONCE
    if (response.statusCode == 401) {
      debugPrint("🔄 Got 401 Unauthorized, refreshing token...");

      // If server already marked refresh as permanently invalid, don't retry
      final invalidReason = await _tokenService.getRefreshInvalidReason();
      if (invalidReason != null) {
        debugPrint('🚫 Refresh permanently invalid: $invalidReason');
        throw UnauthorizedException(invalidReason);
      }

      final refreshResult = await _tokenService.refreshAccessToken();

      if (refreshResult.isSuccess) {
        debugPrint("✅ Token refreshed, retrying request...");

        // ✅ Update last online check (we just successfully connected)
        await _tokenService.updateLastOnlineCheck();

        // Retry the request with new token
        response = await requestFunction();

        debugPrint("✅ Request retry: ${response.statusCode}");
      } else {
        debugPrint("❌ Token refresh failed");
        throw UnauthorizedException('Session expired');
      }
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      // ✅ Successful request - update last online check
      await _tokenService.updateLastOnlineCheck();
    }

    return response;
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
