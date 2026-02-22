import 'dart:convert';
import 'package:abokamall/helpers/FirebaseUtilities.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/ApiMessage.dart';
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

        await setCurrentUser(email);

        // ✅ Parse and save subscription expiry (Egypt date from backend)
        final subscriptionExpiryStr = data['subscriptionExpiry'];
        if (subscriptionExpiryStr != null) {
          final subscriptionExpiry = DateTime.parse(subscriptionExpiryStr);
          debugPrint(
            'Subscription expiry: ${DateFormat('yyyy-MM-dd').format(subscriptionExpiry)}',
          );
          await saveCurrentUserSubscription(subscriptionExpiry);
        }

        await saveCurrentUserIsExpired(data['isExpired'] ?? false);
        FirebaseUtilities.syncFcmTokenWithBackend();
        return LoginResult(
          isSuccess: true,
          isExpired: data['isExpired'] ?? false,
          expiryDate: data['subscriptionExpiry'],
        );
      } else {
        // ✅ Handle error response with subscription date
        final apiMessage = ApiMessage.fromJson(data);
        if (apiMessage.errorCode == "SubscriptionInvalid") {
          // ✅ Must set user first so saveCurrentUserIsExpired works
          await setCurrentUser(email);
          await saveCurrentUserIsExpired(true);

          if (data['subscriptionExpiry'] != null) {
            try {
              final date = DateTime.parse(data['subscriptionExpiry']);
              await saveCurrentUserSubscription(date);
            } catch (_) {}
          }
        }

        return LoginResult.fromApiMessage(
          apiMessage,
          lastDate: data['subscriptionExpiry'] ?? data['LastDate'],
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
  final bool isSuccess;
  final String? errorCode;
  final String? errorMessage;
  final String? lastDate; // backend subscription or last valid date
  final bool isExpired;
  final String? expiryDate;

  LoginResult({
    required this.isSuccess,
    this.errorCode,
    this.errorMessage,
    this.lastDate,
    this.isExpired = false,
    this.expiryDate,
  });

  /// Factory to create LoginResult from ApiMessage
  factory LoginResult.fromApiMessage(
    ApiMessage apiMessage, {
    String? lastDate,
  }) {
    String? message = apiMessage.message;

    // Customize subscription invalid message with Arabic formatting
    if (apiMessage.errorCode == "SubscriptionInvalid" && lastDate != null) {
      try {
        final date = DateTime.parse(lastDate);
        final formattedDate = DateFormat('dd/MM/yyyy').format(date);
        message = "انتهى اشتراكك في $formattedDate، يرجى التجديد";
      } catch (_) {
        message = "انتهى اشتراكك، يرجى التجديد";
      }
    }

    return LoginResult(
      isSuccess: apiMessage.success,
      errorCode: apiMessage.errorCode,
      errorMessage: message,
      lastDate: lastDate,
      isExpired: apiMessage.errorCode == "SubscriptionInvalid",
      expiryDate: lastDate,
    );
  }
}
