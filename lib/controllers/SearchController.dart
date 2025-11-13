import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Searchcontroller {
  Future<List<ServiceProvider>> searchWorkers(
    String? fullName,
    String? profession,
    int? workerType,
    String? location,
    ProviderType ProviderType,
  ) async {
    try {
      List<ServiceProvider> providers = [];
      final tokenService = getIt<TokenService>();
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null) {
        return [];
      }
      final url = Uri.parse(
        '$apiRoute/search/${ProviderType.name}',
      ); // replace with your endpoint
      debugPrint(ProviderType.toString());
      final body = {
        'workerType': workerType,
        'profession': profession,
        'location': location,
        'pageNumber': 1,
        'fullName': fullName,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var item in data) {
          providers.add(ServiceProvider.fromJson(item));
        }
        debugPrint(providers.toString());
        return providers;
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
