import 'dart:convert';
import 'dart:io';

import 'package:abokamall/helpers/FirebaseUtilities.dart';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/ApiMessage.dart';
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
      final tokenService = getIt<TokenService>();

      // If we have valid cache and not forcing refresh, return cached (IF ALLOWED)
      if (!forceRefresh && _cacheService.hasValidCache) {
        if (await tokenService.isDataAccessibleAsync()) {
          return _cacheService.loadCachedProfile();
        } else {
          debugPrint(
            "🚫 Security: Blocking cached profile access (Grace passed)",
          );
          return null;
        }
      }

      final response = await apiClient.get("/profile");

      if (response.statusCode != 200) {
        debugPrint('Profile fetch failed: ${response.body}');

        // ✅ NEW: Detect expiry from profile fetch too
        if (response.statusCode == 403) {
          await saveCurrentUserIsExpired(true);
        }

        // If API fails, check security before returning cached (fallback)
        if (await tokenService.isDataAccessibleAsync()) {
          return _cacheService.loadCachedProfile();
        }
        return null;
      }

      final data = jsonDecode(response.body);
      UserProfile profile = UserProfile.fromJson(data);

      // Cache the profile
      await _cacheService.cacheProfile(profile);

      // ✅ NEW: Clear expiry flag on success so UI recovers immediately
      await saveCurrentUserIsExpired(false);

      // ✅ NEW: Sync the fresh subscription end date to local storage too
      if (profile.subscription != null) {
        try {
          final endDate = DateTime.parse(profile.subscription!.endDate);
          await saveCurrentUserSubscription(endDate);
        } catch (e) {
          debugPrint("Error parsing subscription endDate: $e");
        }
      }

      return profile;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Return cached profile if offline / error (IF ALLOWED)
      if (await getIt<TokenService>().isDataAccessibleAsync()) {
        return _cacheService.loadCachedProfile();
      }
      return null;
    }
  }

  /// Update profile and refresh cache
  Future<ApiMessage> updateProfile({
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
    String? marketplace,
    String? derivedSpec,
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
        if (marketplace != null) "marketplace": marketplace,
        if (derivedSpec != null) "derivedSpec": derivedSpec,
        if (uploadedImageUrl != null) "profileImage": uploadedImageUrl,
      };

      final response = await apiClient.put("/profile", body: body);

      if (response.statusCode != 200) {
        debugPrint('Profile update failed: ${response.body}');
        final decoded = jsonDecode(response.body);

        return ApiMessage.fromJson(decoded);
      }

      // After successful update, refetch and cache profile
      await fetchProfile(forceRefresh: true);

      return ApiMessage(
        success: true,
        message: "تم تحديث البيانات بنجاح",
        errorCode: null,
      );
    } on SocketException {
      return ApiMessage(
        success: false,
        message: "لا يوجد اتصال بالإنترنت",
        errorCode: "NetworkError",
      );
    } catch (e) {
      return ApiMessage(
        success: false,
        message: "حدث خطأ غير متوقع",
        errorCode: "GeneralError",
      );
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

        // Delete Firebase token locally
        await FirebaseUtilities.deleteLocalFcmToken();
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

  /// Set user as occupied until midnight
  Future<ApiMessage> setOccupied() async {
    try {
      final response = await apiClient.post("/profile/set-occupied");

      if (response.statusCode != 200) {
        debugPrint('Set occupied failed: ${response.body}');
        final decoded = jsonDecode(response.body);
        return ApiMessage.fromJson(decoded);
      }

      final data = jsonDecode(response.body);
      return ApiMessage(
        success: true,
        message: data['message'] ?? "تم تعيينك كغير متاح حتى منتصف الليل",
        errorCode: null,
      );
    } on SocketException {
      return ApiMessage(
        success: false,
        message: "لا يوجد اتصال بالإنترنت",
        errorCode: "NetworkError",
      );
    } catch (e) {
      debugPrint('Error setting occupied: $e');
      return ApiMessage(
        success: false,
        message: "حدث خطأ غير متوقع",
        errorCode: "GeneralError",
      );
    }
  }

  /// Remove occupation status (set as available)
  Future<ApiMessage> removeOccupied() async {
    try {
      final response = await apiClient.delete("/profile/remove-occupied");

      if (response.statusCode != 200) {
        debugPrint('Remove occupied failed: ${response.body}');
        final decoded = jsonDecode(response.body);
        return ApiMessage.fromJson(decoded);
      }

      final data = jsonDecode(response.body);
      return ApiMessage(
        success: true,
        message: data['message'] ?? "تم تعيينك كمتاح",
        errorCode: null,
      );
    } on SocketException {
      return ApiMessage(
        success: false,
        message: "لا يوجد اتصال بالإنترنت",
        errorCode: "NetworkError",
      );
    } catch (e) {
      debugPrint('Error removing occupied: $e');
      return ApiMessage(
        success: false,
        message: "حدث خطأ غير متوقع",
        errorCode: "GeneralError",
      );
    }
  }

  /// Get current occupation status
  Future<bool?> getOccupationStatus() async {
    try {
      final response = await apiClient.get("/profile/occupation-status");

      if (response.statusCode != 200) {
        debugPrint('Get occupation status failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      return data['isOccupied'] as bool?;
    } catch (e) {
      debugPrint('Error getting occupation status: $e');
      return null;
    }
  }
}
