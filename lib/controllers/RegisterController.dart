import 'dart:convert';
import 'dart:io';
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
      case 'ImageIsNull':
        return 'يرجى رفع صورة الملف الشخصي';
      case 'InvalidPaymentValue':
        return 'قيمة الدفع غير صحيحة';
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
      // Add other fields like Specialization, Owner, Business, etc., if needed

      // Add profile image
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imageFile', // must match backend parameter name
            profileImage.path,
          ),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      return RegisterResult(success: false, message: 'حدث خطأ في التسجيل');
    }
  }
}
