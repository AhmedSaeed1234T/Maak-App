import 'dart:convert';
import 'dart:io';

import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:abokamall/services/ProfileCacheService.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileController {
  final ProfileCacheService _cacheService = getIt<ProfileCacheService>();

  /// Fetch profile with caching and offline support
  Future<UserProfile?> fetchProfile({bool forceRefresh = false}) async {
    try {
      // If we have valid cache and not forcing refresh, return cached
      if (!forceRefresh && _cacheService.hasValidCache) {
        return _cacheService.loadCachedProfile();
      }

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
        // If API fails, return cached profile (if available)
        return _cacheService.loadCachedProfile();
      }

      final data = jsonDecode(response.body);
      UserProfile profile = UserProfile.fromJson(data);

      // Cache the profile
      await _cacheService.cacheProfile(profile);

      return profile;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Return cached profile if offline / error
      return _cacheService.loadCachedProfile();
    }
  }

  /// Update profile and refresh cache
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

      // After successful update, refetch and cache profile
      await fetchProfile(forceRefresh: true);

      return true;
    } on SocketException catch (e) {
      debugPrint('Socket Timeout :  $e');
      return false;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      // I need to add network check here
      if (Connectivity().checkConnectivity() == ConnectivityResult.none) {
        return false;
      }
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
      // Clear cached profile on logout
      await _cacheService.clearCache();

      return true;
    } on SocketException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }
}
