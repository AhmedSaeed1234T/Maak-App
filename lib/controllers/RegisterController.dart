import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/RegisterClass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Result class for registration operations
class RegisterResult {
  final bool success;
  final String? errorCode;
  final String? message;

  RegisterResult({required this.success, this.errorCode, this.message});

  /// Get Arabic error message based on error code
  String get arabicErrorMessage {
    if (errorCode == null) return message ?? 'حدث خطأ غير معروف';

    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام في التسجيل';
      case 'ReferralUserNotFound':
        return 'مستخدم الإحالة غير موجود';
      case 'PhoneNumberAlreadyExists':
        return 'رقم الهاتف موجود بالفعل';
      case 'EmailAlreadyExists':
        return 'البريد الإلكتروني موجود بالفعل';
      default:
        return 'حدث خطأ في التسجيل: $errorCode';
    }
  }
}

class RegisterController {
  Future<RegisterResult> registerUser(
    RegisterUserDto user,
    File? profileImage,
  ) async {
    final url = Uri.parse('$apiRoute/Auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      debugPrint(user.toJson().toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? uploadedImageUrl;
        if (profileImage != null) {
          uploadedImageUrl = await uploadProfileImage(profileImage);
          debugPrint(
            "Something happened while uploading image: $uploadedImageUrl",
          );
        }
        return RegisterResult(success: true);
      } else {
        // Parse error response
        String? errorCode;
        String? errorMessage;

        try {
          final errorData = jsonDecode(response.body);
          errorCode = errorData['errorCode'];
          errorMessage = errorData['message'];
        } catch (e) {
          // If JSON parsing fails, use the raw response body
          errorMessage = response.body;
        }

        debugPrint(
          'Failed to register: ${response.statusCode} - ${response.body}',
        );

        return RegisterResult(
          success: false,
          errorCode: errorCode,
          message: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('Register error: $e');
      return RegisterResult(success: false, message: 'حدث خطأ في التسجيل');
    }
  }
}
