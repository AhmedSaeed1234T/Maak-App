import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // ✅ Add for date formatting

class LoginController {
  final ApiClient apiClient = getIt<ApiClient>();
  final TokenService tokenService = getIt<TokenService>();

  Future<LoginResult> login(String email, String password) async {
    final url = Uri.parse('$apiRoute/Auth/login');
    final body = {'email': email, 'password': password};

    try {
      final response = await apiClient.post("/auth/login", body: body);
      debugPrint(response.body.toString());
      debugPrint(response.statusCode.toString());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Save tokens with correct parameter name
        await tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          refreshTokenExpiry: data['refreshTokenExpiry'], // ✅ UTC ISO string
        );

        // ✅ Save current user

        // ✅ Parse and save subscription expiry (Egypt date from backend)
        final subscriptionExpiry = DateTime.parse(
          data['subscriptionExpiry'],
        ); // "2024-12-30"
        debugPrint(
          'Subscription expiry: ${DateFormat('yyyy-MM-dd').format(subscriptionExpiry)}',
        );
        await setCurrentUser(email);
        await saveCurrentUserSubscription(subscriptionExpiry);

        bool isValidToEnter = await isSubscriptionExpired();
        if (!isValidToEnter) {
          return LoginResult(isSuccess: true);
        }
        return LoginResult(
          errorCode: "SubscriptionInvalid",
          isSuccess: false,
          lastDate: data['subscriptionExpiry'],
        );
      } else {
        // ✅ Handle error response with subscription date
        debugPrint("Error: ${data['message']}");
        debugPrint(
          "Last subscription date: ${data['subscriptionExpiry'] ?? data['LastDate']}",
        );

        return LoginResult(
          isSuccess: false,
          errorCode: data['errorCode'],
          errorMessage: data['message'],
          lastDate:
              data['subscriptionExpiry'] ??
              data['LastDate'], // ✅ Handle both possible keys
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
  String? lastDate; // ✅ This will be "2024-12-30" format (Egypt date)

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
        // ✅ Format the date nicely for Arabic display
        if (lastDate != null) {
          try {
            final date = DateTime.parse(lastDate!);
            final formattedDate = DateFormat('dd/MM/yyyy').format(date);
            return "انتهى اشتراكك في $formattedDate، يرجى التجديد";
          } catch (e) {
            return "انتهى اشتراكك، يرجى التجديد";
          }
        }
        return "انتهى اشتراكك، يرجى التجديد";
      case "EmailOrPasswordInCorrect":
        return 'الايميل او الباسورد خطأ, يرجي اعادة التأكد';
      default:
        return errorMessage ?? 'حدث خطأ: $errorCode';
    }
  }
}
