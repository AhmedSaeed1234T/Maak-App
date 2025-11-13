import 'dart:convert';
import 'dart:io';

import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String?> uploadProfileImage(File imageFile) async {
  try {
    final tokenService = getIt<TokenService>();
    final accessToken = await tokenService.getAccessToken();
    if (accessToken == null) return null;

    final url = Uri.parse('$apiRoute/auth/upload-profile-image');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Add the image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // backend field name for file
        imageFile.path,
      ),
    );

    // Send request
    var response = await request.send();

    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);
      return data['imageUrl']; // Assuming backend returns the uploaded image URL
    } else {
      debugPrint('Image upload failed: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Error uploading image: $e');
    return null;
  }
}
