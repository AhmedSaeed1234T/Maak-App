import 'dart:convert';
import 'dart:io';

import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileController {
  /// Helper method to wrap requests with token refresh

  /// Fetch profile
  Future<UserProfile?> fetchProfile() async {
    try {
      final url = Uri.parse('$apiRoute/profile');

      final response = await withTokenRetry(
        (token) => http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        debugPrint('Profile fetch failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String bio,
    required String pay,
    required String governorate,
    required String city,
    required String district,
    String? specialization,
    String? business,
    String? owner,
    int? workerTypes,
    File? profileImage,
  }) async {
    try {
      final tokenService = getIt<TokenService>();
      String? uploadedImageUrl;

      if (profileImage != null) {
        uploadedImageUrl = await uploadProfileImage(profileImage);
      }

      final url = Uri.parse('$apiRoute/profile');

      final body = {
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "pay": double.tryParse(pay) ?? 0,
        "governorate": governorate,
        "city": city,
        "district": district,
        if (specialization != null) "specialization": specialization,
        if (business != null) "business": business,
        if (owner != null) "owner": owner,
        if (workerTypes != null) "workerTypes": workerTypes,
        if (uploadedImageUrl != null) "profileImage": uploadedImageUrl,
      };

      final response = await withTokenRetry(
        (token) => http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ),
      );

      if (response.statusCode != 200) {
        debugPrint('Profile update failed: ${response.body}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final tokenService = getIt<TokenService>();
      final refreshToken = await tokenService.getRefreshToken();
      final response = await http.post(
        Uri.parse('$apiRoute/auth/logout'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        debugPrint('logout failed: ${response.body}');
        return false;
      }
      await tokenService.clearTokens();

      return true;
    } catch (e) {
      return false; // refresh failed
    }
  }
}
