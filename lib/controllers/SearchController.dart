import 'dart:convert';
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

  Future<List<ServiceProvider>> searchWorkers(
    String? firstName,
    String? lastName,
    String? profession,
    String? governorate,
    String? city,
    String? district,
    int? workerType,
    ProviderType? providerType,
    bool basedOnPoints,
    int pageNumber,
  ) async {
    try {
      final tokenService = getIt<TokenService>();
      final accessToken = await tokenService.getAccessToken();

      // If no token, return cached users
      if (accessToken == null) return _cacheService.loadCachedUsers();

      ProviderType type = providerType ?? ProviderType.Workers;
      final url = Uri.parse('$apiRoute/search/${type.name.toLowerCase()}');

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
        return await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
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

        // Cache the results for offline use
        await _cacheService.cacheUsers(providers);

        return providers;
      } else {
        debugPrint('Search API error: ${response.body}');
        return _cacheService.loadCachedUsers(); // fallback offline
      }
    } catch (e) {
      debugPrint('Search error: $e');
      return _cacheService.loadCachedUsers(); // fallback offline
    }
  }
}
