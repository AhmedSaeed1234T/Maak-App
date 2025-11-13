import 'dart:convert';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/apiroute.dart';
import '../helpers/ServiceLocator.dart';
import '../screens/settings_screen.dart'; // for sessionUser & sessionImage

class ProfileController {
  Future<bool> fetchProfile() async {
    final tokenService = getIt<TokenService>();
    final accessToken = await tokenService.getAccessToken();
    if (accessToken == null) {
      return false;
    }
    try {
      final url = Uri.parse('$apiRoute/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Include token header if needed:
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle image (network)
        final imageUrl = data['imageUrl'];

        // Base user info
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final fullName = "$firstName $lastName".trim();

        // Common fields
        sessionUser['firstName'] = firstName;
        sessionUser['lastName'] = lastName;

        sessionUser['username'] = data['userName'] ?? '';
        sessionUser['email'] = data['email'] ?? '';
        sessionUser['phone'] = data['phoneNumber'] ?? '';
        sessionUser['address'] = data['location'] ?? '';
        sessionUser['points'] = data['points'] ?? 0;

        // Determine user type & specialized info
        final sp = data['serviceProvider'];
        if (sp != null) {
          final providerType = sp['providerType'] ?? '';
          sessionUser['accountType'] = providerType.toLowerCase();

          if (providerType == 'Worker') {
            sessionUser['job'] = sp['skill'] ?? '';
            sessionUser['salaryType'] = sp['workerTypes'] == 0
                ? 'يومي'
                : 'مقطوعية';
            sessionUser['pay'] = sp['pay']?.toString() ?? '';
          } else if (providerType == 'Contractor' ||
              providerType == 'Engineer') {
            sessionUser['specialization'] = sp['specialization'] ?? '';
            sessionUser['bio'] = sp['bio'] ?? '';
            sessionUser['pay'] = sp['pay']?.toString() ?? '';
            sessionUser['business'] = sp['business'] ?? '';
            sessionUser['owner'] = sp['owner'] ?? '';
          } else if (providerType == 'Company') {
            sessionUser['business'] = sp['business'] ?? '';
            sessionUser['owner'] = sp['owner'] ?? '';
          }
        } else {
          sessionUser['accountType'] = data['userType'] ?? 'User';
        }

        // Handle image
        if (imageUrl != null && imageUrl != '') {
          sessionUser['imageUrl'] = imageUrl;
        } else {
          sessionUser['imageUrl'] = null;
        }

        return true;
      } else {
        debugPrint('Profile fetch failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String providerType,
    String? bio,
    String? skill,
    String? pay,
    String? specialization,
    String? business,
    String? owner,
  }) async {
    try {
      final tokenService = getIt<TokenService>();
      final accessToken = await tokenService.getAccessToken();
      if (accessToken == null) {
        return false;
      }
      final url = Uri.parse('$apiRoute/profile');

      // Start with common fields
      Map<String, dynamic> body = {
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio ?? '',
        "providerType": providerType,
      };

      // Add type-specific fields
      if (providerType == 'Worker') {
        body.addAll({
          "skill": skill ?? '',
          "pay": int.tryParse(pay ?? '0') ?? 0,
        });
      } else if (providerType == 'Contractor' || providerType == 'Engineer') {
        body.addAll({
          "specialization": specialization ?? '',
          "pay": int.tryParse(pay ?? '0') ?? 0,
        });
      } else if (providerType == 'Company' || providerType == 'Marketplace') {
        body.addAll({"business": business ?? '', "owner": owner ?? ''});
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Update local sessionUser map
        sessionUser['name'] = "$firstName $lastName".trim();
        sessionUser['accountType'] = providerType.toLowerCase();
        sessionUser['bio'] = bio ?? '';

        if (providerType == 'Worker') {
          sessionUser['skill'] = skill ?? '';
          sessionUser['pay'] = pay ?? '';
        } else if (providerType == 'Contractor' || providerType == 'Engineer') {
          sessionUser['specialization'] = specialization ?? '';
          sessionUser['pay'] = pay ?? '';
        } else if (providerType == 'Company' || providerType == 'Marketplace') {
          sessionUser['business'] = business ?? '';
          sessionUser['owner'] = owner ?? '';
        }

        return true;
      } else {
        debugPrint('Profile update failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}
