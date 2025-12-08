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
    int? workerType,
    ProviderType? providerType,
    bool basedOnPoints = false,
    int pageNumber = 1,
  }) async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      final type = providerType ?? ProviderType.Workers;
      final cacheKey = type.name.toLowerCase();

      // If no token, return cached users for this provider type
      if (accessToken == null) {
        return _cacheService.loadCachedUsers(cacheKey);
      }

      final url = Uri.parse('$apiRoute/search/$cacheKey');

      final body = {
        "firstName": firstName,
        "lastName": lastName,
        "profession": profession,
        "workerType": workerType,
        "governorate": governorate,
        "city": city,
        "district": district,
        "basedOnPoints": basedOnPoints,
        "pageNumber": pageNumber,
      };

      final response = await apiClient
          .post("/search/$cacheKey", body: body)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw TimeoutException("Request timed out");
            },
          );

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

        // Cache the results by provider type

        // if they are the users in the main screen so cache them , search will cook things up
        if (basedOnPoints == true) {
          await _cacheService.cacheUsers(cacheKey, providers);
        }

        return providers;
      }
      if (response.statusCode == 401) {
        try {
          debugPrint(401.toString());
          // debugPrint(responseBody);
          final DateTime = await getCurrentUserSubscription();
          debugPrint(DateTime.toString());
          final searchResult = SearchResult(
            errorCode: jsonDecode(response.body)["errorCode"],
            lastDate: DateTime.toString(),
          );
          if (context!.mounted) {
            String message = await searchResult.arabicErrorMessage;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          debugPrint('Search API error: ${response.body}');
        } catch (e) {
          if (context!.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("لقد حدث خطأ يرجي اعادة التسجيل")),
            );
          }
        }

        if (basedOnPoints) {
          return _cacheService.loadCachedUsers(cacheKey);
        } else {
          return []; // In case the user searched when the server is down
        }
      } else {
        serverActionError = ServerActionError.unknown;

        debugPrint('Search API error: ${response.body}');
        if (basedOnPoints) {
          return _cacheService.loadCachedUsers(cacheKey);
        } else {
          return []; // In case the user searched when the server is down
        }
      }
    } on SocketException catch (e) {
      serverActionError = ServerActionError.networkError;

      debugPrint('Socket Timeout :  $e');
      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      if (basedOnPoints) {
        return _cacheService.loadCachedUsers(cacheKey);
      } else {
        return []; // In case the user searched when the server is down
      }
    } on TimeoutException catch (e) {
      debugPrint(' Timeout Exception:  $e');
      serverActionError = ServerActionError.timeout;

      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      if (basedOnPoints) {
        return _cacheService.loadCachedUsers(cacheKey);
      } else {
        return []; // In case the user searched when the server is down
      }
    } catch (e) {
      debugPrint('Search error: $e');
      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      if (basedOnPoints) {
        return _cacheService.loadCachedUsers(cacheKey);
      } else {
        return []; // In case the user searched when the server is down
      }
    }
  }
}

class SearchResult {
  bool isSuccess;
  String? errorCode;
  String? errorMessage;
  String? lastDate;

  SearchResult({
    this.isSuccess = false,
    this.errorCode,
    this.errorMessage,
    this.lastDate,
  });

  Future<String> get arabicErrorMessage async {
    if (errorCode == null) return errorMessage ?? 'حدث خطأ غير معروف';
    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام أثناء تسجيل الدخول';
      case 'SubscriptionInvalid':
        if (lastDate != null) {
          try {
            final date = await getCurrentUserSubscription();
            final formattedDate = DateFormat('dd/MM/yyyy').format(date!);
            debugPrint("Format is $formattedDate");

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
