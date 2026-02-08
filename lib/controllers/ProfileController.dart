import 'dart:convert';
import 'dart:io';

import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:abokamall/services/ProfileCacheService.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileController {
  final ProfileCacheService _cacheService = getIt<ProfileCacheService>();
  final ApiClient apiClient = getIt<ApiClient>();

  /// Fetch profile with caching and offline support
  Future<UserProfile?> fetchProfile({bool forceRefresh = false}) async {
    try {
      // If we have valid cache and not forcing refresh, return cached
      if (!forceRefresh && _cacheService.hasValidCache) {
        return _cacheService.loadCachedProfile();
      }

      final response = await apiClient.get("/profile");

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

      final response = await apiClient.put("/profile", body: body);

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
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('No internet connection');
        return false;
      }

      final tokenService = getIt<TokenService>();
      final refreshToken = await tokenService.getRefreshToken();

      if (refreshToken != null) {
        final response = await apiClient
            .post("/auth/logout", body: {'refreshToken': refreshToken})
            .timeout(Duration(seconds: 10));

        if (response.statusCode != 200) {
          debugPrint('Logout failed: ${response.body}');
          // Still proceed to clear tokens locally
        }
      }

      // Clear local tokens and user info
      await tokenService.clearTokens();
      final currentUser = await getCurrentUser();
      // He should be inside the app so why he gets out ?
      await deleteSubscriptionForUser(currentUser!);
      await deleteCurrentUser();

      // Clear cached profile
      await _cacheService.clearCache();

      return true;
    } on SocketException catch (_) {
      debugPrint('Network error during logout');
      return false;
    } catch (e) {
      debugPrint('Unexpected error during logout: $e');
      return false;
    }
  }
}

/*
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

class ProfileResult {
  final UserProfile? profile;
  final bool isSubscriptionExpired;
  final String? errorMessage;

  ProfileResult({
    this.profile,
    this.isSubscriptionExpired = false,
    this.errorMessage,
  });
}

class UpdateResult {
  final bool success;
  final bool isSubscriptionExpired;
  final String? errorMessage;

  UpdateResult({
    required this.success,
    this.isSubscriptionExpired = false,
    this.errorMessage,
  });
}

class ProfileController {
  final ProfileCacheService _cacheService = getIt<ProfileCacheService>();

  /// Fetch profile with caching and offline support
  Future<ProfileResult> fetchProfile({bool forceRefresh = false}) async {
    try {
      // If we have valid cache and not forcing refresh, return cached
      if (!forceRefresh && _cacheService.hasValidCache) {
        return ProfileResult(profile: _cacheService.loadCachedProfile());
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

      if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        if (data['errorCode'] == 'SubscriptionInvalid') {
          // Return cached profile with subscription expired flag
          return ProfileResult(
            profile: _cacheService.loadCachedProfile(),
            isSubscriptionExpired: true,
            errorMessage: 'انتهت صلاحية اشتراكك',
          );
        }
      }

      if (response.statusCode != 200) {
        debugPrint('Profile fetch failed: ${response.body}');
        // If API fails, return cached profile (if available)
        return ProfileResult(
          profile: _cacheService.loadCachedProfile(),
          errorMessage: 'فشل تحميل الملف الشخصي',
        );
      }

      final data = jsonDecode(response.body);
      UserProfile profile = UserProfile.fromJson(data);

      // Cache the profile
      await _cacheService.cacheProfile(profile);

      return ProfileResult(profile: profile);
    } on SocketException catch (e) {
      debugPrint('Socket exception: $e');
      return ProfileResult(
        profile: _cacheService.loadCachedProfile(),
        errorMessage: 'لا يوجد اتصال بالإنترنت',
      );
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Return cached profile if offline / error
      return ProfileResult(
        profile: _cacheService.loadCachedProfile(),
        errorMessage: 'حدث خطأ أثناء تحميل الملف الشخصي',
      );
    }
  }

  /// Update profile and refresh cache
  Future<UpdateResult> updateProfile({
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
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return UpdateResult(
          success: false,
          errorMessage: 'لا يوجد اتصال بالإنترنت',
        );
      }

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

      if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        if (data['errorCode'] == 'SubscriptionInvalid') {
          return UpdateResult(
            success: false,
            isSubscriptionExpired: true,
            errorMessage: 'انتهت صلاحية اشتراكك',
          );
        }
      }

      if (response.statusCode != 200) {
        debugPrint('Profile update failed: ${response.body}');
        return UpdateResult(
          success: false,
          errorMessage: 'فشل تحديث الملف الشخصي',
        );
      }

      // After successful update, refetch and cache profile
      await fetchProfile(forceRefresh: true);

      return UpdateResult(success: true);
    } on SocketException catch (e) {
      debugPrint('Socket Timeout: $e');
      return UpdateResult(
        success: false,
        errorMessage: 'انقطع الاتصال بالإنترنت',
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return UpdateResult(
        success: false,
        errorMessage: 'حدث خطأ أثناء التحديث',
      );
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
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
      debugPrint('Socket exception during logout: $e');
      return false;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }
}
*/
