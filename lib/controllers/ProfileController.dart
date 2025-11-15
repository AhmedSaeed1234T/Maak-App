import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// ============= UPDATED CONTROLLER =============
class ProfileController {
  /// Fetch profile and return UserProfile DTO
  Future<UserProfile?> fetchProfile() async {
    final tokenService = getIt<TokenService>();
    final accessToken = await tokenService.getAccessToken();
    if (accessToken == null) return null;

    try {
      final url = Uri.parse('$apiRoute/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
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

  /// Update profile with provider-specific fields
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
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null) return false;

      // Upload profile image if provided
      String? uploadedImageUrl;
      if (profileImage != null) {
        uploadedImageUrl = await uploadProfileImage(profileImage);
      }

      final url = Uri.parse('$apiRoute/profile');

      // Build payload with all editable fields
      final body = {
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "pay": double.tryParse(pay) ?? 0,
        "governorate": governorate,
        "city": city,
        "district": district,
      };

      // Add provider-specific fields if provided

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
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
}
