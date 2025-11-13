import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/ProviderDto.dart';
import 'package:abokamall/models/Worker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardController {
  // Async function to login
  Future<List<ProviderDto>> ReturnFeaturedSellers() async {
    final tokenService = getIt<TokenService>();
    final accessToken = await tokenService.getAccessToken();
    if (accessToken == null) {
      return [];
    }
    final url = Uri.parse('$apiRoute/search/providers'); // your login endpoint

    // Create the request body

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        List<ProviderDto> providers = [];
        final data = jsonDecode(response.body);
        for (var item in data) {
          providers.add(ProviderDto.fromJson(item));
        }
        debugPrint(providers.toString());
        return providers;
      } else {
        debugPrint('Profile fetch failed: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return [];
    }
  }
}
