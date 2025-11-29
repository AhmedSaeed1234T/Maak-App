import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _subscriptionsKey = 'subscriptions';
const _currentUserKey = 'current_user_email';

/// Set current user
Future<void> setCurrentUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_currentUserKey, email);
}

/// Get current user
Future<String?> getCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_currentUserKey);
}

/// Save subscription for a user
Future<void> saveSubscriptionForUser(String email, DateTime endDate) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_subscriptionsKey) ?? '{}';
  Map<String, String> subscriptions = Map<String, String>.from(
    jsonDecode(dataString),
  );
  subscriptions[email] = endDate.toIso8601String();
  await prefs.setString(_subscriptionsKey, jsonEncode(subscriptions));
}

/// Get subscription for a user
Future<DateTime?> getSubscriptionForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_subscriptionsKey);
  if (dataString != null) {
    Map<String, String> subscriptions = Map<String, String>.from(
      jsonDecode(dataString),
    );
    if (subscriptions.containsKey(email)) {
      debugPrint(subscriptions[email]!);
      return DateTime.parse(subscriptions[email]!);
    }
  }
  return null;
}

/// Save subscription for current user
Future<void> saveCurrentUserSubscription(DateTime endDate) async {
  final email = await getCurrentUser();
  if (email != null) await saveSubscriptionForUser(email, endDate);
}

/// Get subscription for current user
Future<DateTime?> getCurrentUserSubscription() async {
  final email = await getCurrentUser();
  if (email != null) return getSubscriptionForUser(email);
  return null;
}

/// Delete subscription for a specific user
Future<void> deleteSubscriptionForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_subscriptionsKey) ?? '{}';
  Map<String, String> subscriptions = Map<String, String>.from(
    jsonDecode(dataString),
  );

  if (subscriptions.containsKey(email)) {
    subscriptions.remove(email);
    await prefs.setString(_subscriptionsKey, jsonEncode(subscriptions));
  }
}

/// Delete subscription for the current user
Future<void> deleteCurrentUserSubscription() async {
  final email = await getCurrentUser();
  if (email != null) {
    await deleteSubscriptionForUser(email);
  }
}

Future<void> deleteCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_currentUserKey);
}
