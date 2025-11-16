import 'dart:convert';
import 'package:abokamall/helpers/HttpHelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class searchcontroller {
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
      List<ServiceProvider> providers = [];
      final tokenService = getIt<TokenService>();
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null) {
        return [];
      }
      ProviderType NewproviderType =
          providerType ?? ProviderType.Workers; // default if null
      // default if null
      final url = Uri.parse(
        '$apiRoute/search/${NewproviderType.name.toLowerCase()}', // use instance, not type
      );
      debugPrint(providerType!.name.toLowerCase());

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
      //Pagination should be implemented late
      final response = await withTokenRetry((accessToken) async {
        return await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      });
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var item in data) {
          providers.add(ServiceProvider.fromJson(item));
        }
        debugPrint(providers.toString());
        return providers;
      } else {
        // Handle error
        print('Error: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
