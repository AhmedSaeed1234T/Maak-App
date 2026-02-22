// lib/services/auth_service.dart
import 'dart:convert';

import 'package:abokamall/helpers/apiroute.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Step 1: Initiate Google Sign-In
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled
        return null;
      }

      return googleUser;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Step 2: Get ID Token (Secure)
  Future<String?> getGoogleIdToken(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ✅ This is the secure token - send THIS to backend, not user data
      return googleAuth.idToken;
    } catch (e) {
      print('Failed to get ID token: $e');
      return null;
    }
  }

  /*
  /// Step 3: Verify with Backend
  Future<RegistrationInitResponse?> initiateRegistration(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$apiRoute/auth/initiate-registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken, // ✅ Only send the token
        }),
      );

      if (response.statusCode == 200) {
        return RegistrationInitResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 409) {
        // User already exists
        throw Exception('User already registered');
      } else {
        throw Exception('Failed to initiate registration');
      }
    } catch (e) {
      print('Error initiating registration: $e');
      return null;
    }
  }
  */
}
