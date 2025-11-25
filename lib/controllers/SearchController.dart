import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/enums.dart';
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

class searchcontroller {
  final UserListCacheService _cacheService = getIt<UserListCacheService>();
  final TokenService _tokenService = getIt<TokenService>();

  Future<List<ServiceProvider>> searchWorkers({
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

      final response = await withTokenRetry((token) async {
        return await http
            .post(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () {
                throw TimeoutException("Request timed out");
              },
            );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        final providers = data
            .map(
              (item) => ServiceProvider.fromJson(
                item,
              ).copyWith(cachedAt: DateTime.now()),
            )
            .toList();

        // Cache the results by provider type

        // if they are the users in the main screen so cache them , search will cook things up
        if (basedOnPoints == true) {
          await _cacheService.cacheUsers(cacheKey, providers);
        }

        return providers;
      } else {
        debugPrint('Search API error: ${response.body}');
        if (basedOnPoints) {
          return _cacheService.loadCachedUsers(cacheKey);
        } else {
          return []; // In case the user searched when the server is down
        }
      }
    } on SocketException catch (e) {
      debugPrint('Socket Timeout :  $e');
      final cacheKey = providerType?.name.toLowerCase() ?? 'workers';
      if (basedOnPoints) {
        return _cacheService.loadCachedUsers(cacheKey);
      } else {
        return []; // In case the user searched when the server is down
      }
    } on TimeoutException catch (e) {
      debugPrint(' Timeout Exception:  $e');
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
