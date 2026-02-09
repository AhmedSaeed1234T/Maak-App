import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
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
        return 'مستخدم الاحالة غير موجود يمكن ترك هذا الحقل فارغا';
      case 'PhoneNumberAlreadyExists':
        return 'رقم الهاتف موجود بالفعل';
      case 'EmailAlreadyExists':
        return 'البريد الإلكتروني موجود بالفعل';
      case 'ImageIsNull':
        return 'يرجى رفع صورة الملف الشخصي';
      case 'InvalidPaymentValue':
        return 'قيمة الدفع غير صحيحة';
      case 'InvalidInput':
        return 'هناك خطأ في البيانات المدخلة , اعد كتابتها بشكل سليم';
      case "PasswordInvalid":
        return 'يجب علي الاقل 8 حروف لكلمة المرور';
      case "EmailOrPasswordInCorrect":
        return 'الايميل او الباسورد خطأ, يرجي اعادة التأكد';
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
      var request = http.MultipartRequest('POST', url);

      // Add DTO fields as individual form fields
      request.fields['firstName'] = user.firstName;
      if (user.lastName != null) request.fields['lastName'] = user.lastName!;
      request.fields['email'] = user.email;
      request.fields['phoneNumber'] = user.phoneNumber;
      request.fields['password'] = user.password;
      if (user.governorate != null)
        request.fields['governorate'] = user.governorate!;
      if (user.city != null) request.fields['city'] = user.city!;
      if (user.district != null) request.fields['district'] = user.district!;
      if (user.bio != null) request.fields['bio'] = user.bio!;
      if (user.providerType != null)
        request.fields['providerType'] = user.providerType!;
      if (user.skill != null) request.fields['skill'] = user.skill!;
      if (user.workerType != null)
        request.fields['workerType'] = user.workerType.toString();
      if (user.business != null) request.fields['business'] = user.business!;
      if (user.owner != null) request.fields['owner'] = user.owner!;
      if (user.pay != null) request.fields['pay'] = user.pay.toString();
      if (user.specialization != null)
        request.fields['specialization'] = user.specialization!;
      if (user.referralUserName != null && user.referralUserName!.isNotEmpty) {
        request.fields['referralUserName'] = user.referralUserName!;
      }

      // Add profile image
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imageFile', profileImage.path),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Register Status code: ${response.statusCode}');
      debugPrint('Register Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // ✅ FIXED: Parse subscription expiry date (Egypt date from backend)
        final expiryDate = DateTime.parse(
          data['expiryDate'],
        ); // Backend sends "2025-12-28"

        debugPrint('📅 Subscription expiry date: ${expiryDate.toString()}');
        debugPrint('📧 Email: ${user.email}');
        debugPrint('📱 Phone: ${user.phoneNumber}');

        // ✅ Save subscription for both email and phone
        await saveSubscriptionForUser(user.email, expiryDate);

        // ✅ Format phone number consistently
        String phoneKey = user.phoneNumber.startsWith('+20')
            ? user.phoneNumber
            : '+20${user.phoneNumber.substring(1)}';
        await saveSubscriptionForUser(phoneKey, expiryDate);

        return RegisterResult(success: true);
      } else {
        String? errorCode;
        String? errorMessage;

        try {
          final errorData = jsonDecode(response.body);
          errorCode = errorData['errorCode'];
          errorMessage = errorData['message'];
        } catch (_) {
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
      return RegisterResult(success: false, message: 'حدث خطأ في التسجيل: $e');
    }
  }
}
