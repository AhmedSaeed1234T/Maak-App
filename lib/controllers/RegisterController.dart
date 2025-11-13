import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/RegisterClass.dart';
import 'package:abokamall/models/Worker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abokamall/helpers/apiroute.dart';

class RegisterController {
  Future<bool> registerUser(RegisterUserDto user, File? profileImage) async {
    final url = Uri.parse('$apiRoute/Auth/register');
    String? uploadedImageUrl;
    if (profileImage != null) {
      uploadedImageUrl = await uploadProfileImage(profileImage);
    }
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('User registered successfully: $data');
        return true;
      } else {
        print('Failed to register: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }
}
