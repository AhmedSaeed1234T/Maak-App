import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginController {
  final TokenService tokenService = getIt<TokenService>();

  Future<LoginResult> login(String email, String password) async {
    // 1. Offline subscription check (hard lock)
    // final expiryDate = await getSubscriptionForUser(email);
    // if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
    //   return LoginResult(
    //     isSuccess: false,
    //     errorCode: 'SubscriptionInvalid',
    //     lastDate: expiryDate.toIso8601String(),
    //   );
    // }

    final url = Uri.parse('$apiRoute/Auth/login');
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save tokens
        await tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        // Save current user
        await setCurrentUser(email);
        debugPrint(DateTime.parse(data['subscriptionExpiry']).toString());
        await saveCurrentUserSubscription(
          DateTime.parse(data['subscriptionExpiry']),
        );
        return LoginResult(isSuccess: true);
      } else {
        debugPrint("The last date is ${data['subscriptionExpiry']}");
        return LoginResult(
          isSuccess: false,
          errorCode: data['errorCode'],
          errorMessage: data['message'],
          lastDate: data['subscriptionExpiry'],
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return LoginResult(
        isSuccess: false,
        errorCode: 'GeneralError',
        errorMessage: 'حدث خطأ أثناء تسجيل الدخول',
      );
    }
  }
}

class LoginResult {
  bool isSuccess;
  String? errorCode;
  String? errorMessage;
  String? lastDate;

  LoginResult({
    this.isSuccess = false,
    this.errorCode,
    this.errorMessage,
    this.lastDate,
  });

  String get arabicErrorMessage {
    if (errorCode == null) return errorMessage ?? 'حدث خطأ غير معروف';
    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام أثناء تسجيل الدخول';
      case 'SubscriptionInvalid':
        return "انتهى اشتراكك في $lastDate، يرجى التجديد";
      default:
        return errorMessage ?? 'حدث خطأ: $errorCode';
    }
  }
}
