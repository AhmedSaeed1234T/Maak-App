import 'dart:convert';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/models/Worker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterController {
  void RegisterWorker(Worker worker) {
    try {
      Future<void> registerWorker(Worker worker) async {
        final url = Uri.parse('$apiRoute/auth/register');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(worker.toJson()), // <-- converts Map to JSON string
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Worker registered successfully');
        } else {
          print('Failed to register: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
