import 'dart:convert';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<http.Response> withTokenRetry(
  Future<http.Response> Function(String accessToken) requestFn,
) async {
  final tokenService = getIt<TokenService>();
  String accessToken = await tokenService.getAccessToken() ?? '';
  http.Response response = await requestFn(accessToken);

  if (response.statusCode == 401) {
    // Access token expired, try refresh
    debugPrint("Refreshing right now");
    bool refreshed = await tokenService.refreshAccessToken();
    if (refreshed) {
      debugPrint("Refreshed successfully");
      // Get the new token
      accessToken = await tokenService.getAccessToken() ?? '';
      // Retry the request
      response = await requestFn(accessToken);
    }
  }

  return response;
}
