import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/Worker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginController {
  // Async function to login
  Future<bool> login(String email, String password) async {
    final tokenService = getIt<TokenService>();
    // final accessToken = await tokenService.getAccessToken();
    // if (accessToken == null) {
    //   return false;
    // }
    final url = Uri.parse('$apiRoute/Auth/login'); // your login endpoint

    // Create the request body
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Login successful
        final data = jsonDecode(response.body);
        tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        print('Login successful: $data');
        return true;
      } else {
        // Login failed
        print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }
}
