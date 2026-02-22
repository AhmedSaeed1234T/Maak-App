import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add this dependency

const _subscriptionsKey = 'subscriptions';
const _currentUserKey = 'current_user_email';
const _isExpiredKey = 'is_expired_map';

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
/// ✅ FIXED: Store as date-only string
Future<void> saveSubscriptionForUser(String email, DateTime endDate) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_subscriptionsKey) ?? '{}';
  Map<String, String> subscriptions = Map<String, String>.from(
    jsonDecode(dataString),
  );

  // ✅ Store as "yyyy-MM-dd" format (Egypt date)
  subscriptions[email] = DateFormat('yyyy-MM-dd').format(endDate);

  await prefs.setString(_subscriptionsKey, jsonEncode(subscriptions));
}

/// Get subscription for a user
/// ✅ FIXED: Parse date-only string
Future<DateTime?> getSubscriptionForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_subscriptionsKey);
  if (dataString != null) {
    Map<String, String> subscriptions = Map<String, String>.from(
      jsonDecode(dataString),
    );
    if (subscriptions.containsKey(email)) {
      debugPrint('Subscription date: ${subscriptions[email]!}');

      // ✅ Parse "yyyy-MM-dd" string
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

/// ✅ NEW: Check if subscription is expired (date comparison only)
Future<bool> isSubscriptionExpired() async {
  final expiryDate = await getCurrentUserSubscription();
  if (expiryDate == null) return true;
  debugPrint("the expiry is$expiryDate");
  // Compare dates only (ignore time)
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

  return today.isAfter(expiry);
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

  // Also clear isExpired flag
  final expiredDataString = prefs.getString(_isExpiredKey) ?? '{}';
  Map<String, dynamic> expiredMap = Map<String, dynamic>.from(
    jsonDecode(expiredDataString),
  );
  if (expiredMap.containsKey(email)) {
    expiredMap.remove(email);
    await prefs.setString(_isExpiredKey, jsonEncode(expiredMap));
  }
}

/// Delete subscription for the current user
Future<void> deleteCurrentUserSubscription() async {
  final email = await getCurrentUser();
  if (email != null) {
    await deleteSubscriptionForUser(email);
  }
}

/// Save isExpired flag for a user
Future<void> saveUserIsExpired(String email, bool isExpired) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_isExpiredKey) ?? '{}';
  Map<String, dynamic> expiredMap = Map<String, dynamic>.from(
    jsonDecode(dataString),
  );
  expiredMap[email] = isExpired;
  await prefs.setString(_isExpiredKey, jsonEncode(expiredMap));
}

/// Get isExpired flag for a user
Future<bool> getUserIsExpired(String email) async {
  final prefs = await SharedPreferences.getInstance();
  final dataString = prefs.getString(_isExpiredKey);
  if (dataString != null) {
    Map<String, dynamic> expiredMap = Map<String, dynamic>.from(
      jsonDecode(dataString),
    );
    return expiredMap[email] ?? false;
  }
  return false;
}

/// Save isExpired flag for current user
Future<void> saveCurrentUserIsExpired(bool isExpired) async {
  final email = await getCurrentUser();
  if (email != null) await saveUserIsExpired(email, isExpired);
}

/// Get isExpired flag for current user
/// ✅ IMPROVED: Dual-check both the flag and the local expiry date
Future<bool> isCurrentUserExpired() async {
  final email = await getCurrentUser();
  if (email == null) return false;

  // 1. Check explicit flag (set by server 403 or logic)
  final flag = await getUserIsExpired(email);
  if (flag) return true; // Hard flag takes priority

  // 2. If flag is false, double check the cached date
  final expiryDate = await getSubscriptionForUser(email);
  if (expiryDate == null) return false;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

  return today.isAfter(expiry);
}

/// ✅ NEW: Get formatted subscription expiration message (simplified per user request)
Future<String?> getFormattedSubscriptionMessage() async {
  return "انتهى اشتراكك، يرجى التجديد";
}

Future<void> deleteCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_currentUserKey);
}
