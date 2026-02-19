import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/NetworkStatus.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/SearchResult.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class searchcontroller {
  final UserListCacheService _cacheService = getIt<UserListCacheService>();
  final ApiClient apiClient = getIt<ApiClient>();
  final TokenService _tokenService = getIt<TokenService>();
  Future<List<ServiceProvider>> searchWorkers({
    ServerActionError? serverActionError,
    BuildContext? context,
    String? firstName,
    String? lastName,
    String? profession,
    String? governorate,
    String? city,
    String? district,
    String? marketplace,
    String? derivedSpec,
    int? workerType,
    ProviderType? providerType,
    bool basedOnPoints = false,
    int pageNumber = 1,
  }) async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      final type = providerType ?? ProviderType.Workers;
      final cacheKey = type.name.toLowerCase();

      // If no token, return cached users for this provider type (IF ALLOWED)
      if (accessToken == null) {
        return await _cacheService.loadCachedUsersAsync(cacheKey);
      }

      final body = {
        "firstName": firstName,
        "lastName": lastName,
        "profession": profession,
        "workerType": workerType,
        "governorate": (governorate?.isEmpty ?? true) ? null : governorate,
        "city": (city?.isEmpty ?? true) ? null : city,
        "district": (district?.isEmpty ?? true) ? null : district,
        "marketplace": (marketplace?.isEmpty ?? true) ? null : marketplace,
        "derivedSpec": (derivedSpec?.isEmpty ?? true) ? null : derivedSpec,
        "basedOnPoints": basedOnPoints,
        "pageNumber": pageNumber,
      };

      final response = await apiClient
          .post("/search/$cacheKey", body: body)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        debugPrint('Search API response data: ${data.length} items found');

        final providers = data
            .map(
              (item) => ServiceProvider.fromJson(
                item,
              ).copyWith(cachedAt: DateTime.now().toUtc()),
            )
            .toList();

        // ✅ NEW: Clear expiry flag on any successful search so UI recovers immediately
        final currentUserEmail = await getCurrentUser();
        if (currentUserEmail != null) {
          await saveUserIsExpired(currentUserEmail, false);
        }

        if (basedOnPoints) {
          await _cacheService.cacheUsers(cacheKey, providers);
        }

        return providers;
      }

      // Log unauthorized access (401/403) but allow cache fallback per user request
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint(
          'SearchController: Unauthorized access (${response.statusCode}). Attempting cache fallback.',
        );

        // ✅ NEW: If 403, mark as expired in storage so UI can react
        if (response.statusCode == 403) {
          final currentUserEmail = await getCurrentUser();
          if (currentUserEmail != null) {
            await saveUserIsExpired(currentUserEmail, true);
          }
        }
      }

      // Return cache or empty list depending on basedOnPoints
      return basedOnPoints
          ? await _cacheService.loadCachedUsersAsync(cacheKey)
          : [];
    } on SocketException catch (e) {
      serverActionError = ServerActionError.networkError;
      debugPrint('Socket Exception: $e');
      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      return basedOnPoints
          ? await _cacheService.loadCachedUsersAsync(cacheKey)
          : [];
    } on TimeoutException catch (e) {
      serverActionError = ServerActionError.timeout;
      debugPrint('Timeout Exception: $e');
      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      return basedOnPoints
          ? await _cacheService.loadCachedUsersAsync(cacheKey)
          : [];
    } catch (e) {
      debugPrint('Unexpected error: $e');
      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      return basedOnPoints
          ? await _cacheService.loadCachedUsersAsync(cacheKey)
          : [];
    }
  }
}

class LoginResult {
  bool isSuccess;
  String? errorCode;
  String? errorMessage;
  String? lastDate; // ✅ This will be "2024-12-30" format (Egypt date)

  LoginResult({
    this.isSuccess = false,
    this.errorCode,
    this.errorMessage,
    this.lastDate,
  });

  String get arabicErrorMessage {
    if (errorCode == null) return errorMessage ?? 'حدث خطأ غير معروف';

    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام أثناء تسجيل الدخول';

      case 'SubscriptionInvalid':
        // ✅ Format the date nicely for Arabic display
        if (lastDate != null) {
          try {
            final date = DateTime.parse(lastDate!);
            final formattedDate = DateFormat('dd/MM/yyyy').format(date);
            return "انتهى اشتراكك في $formattedDate، يرجى التجديد";
          } catch (e) {
            return "انتهى اشتراكك، يرجى التجديد";
          }
        }
        return "انتهى اشتراكك، يرجى التجديد";

      default:
        return errorMessage ?? 'حدث خطأ: $errorCode';
    }
  }
}
