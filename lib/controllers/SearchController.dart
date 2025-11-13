import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchController {
  Future<bool> searchWorkers(
    String? fullName,
    String? profession,
    bool? workerType,
    String? location,
    ProviderType ProviderType,
  ) async {
    try {
      final tokenService = getIt<TokenService>();
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null) {
        return false;
      }
      final url = Uri.parse(
        '$apiRoute/search/${ProviderType.toString()}',
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
        // Do something with your data
        print(data);
        return true;
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
