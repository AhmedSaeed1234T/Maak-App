import 'dart:convert';
import 'dart:io';

import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/models/ApiMessage.dart';
import 'package:abokamall/models/Notification.dart' as models;
import 'package:flutter/material.dart';

class NotificationController {
  final ApiClient apiClient = getIt<ApiClient>();

  /// Get paginated notifications for the authenticated user
  Future<models.NotificationPageResult?> getMyNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await apiClient.get(
        "/notification/my-notifications?pageNumber=$pageNumber&pageSize=$pageSize",
      );

      if (response.statusCode != 200) {
        debugPrint('Get notifications failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);

      // Handle case where backend returns List directly
      if (data is List) {
        return models.NotificationPageResult.fromJson({
          'notifications': data,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'totalCount': data.length,
          'hasMore': data.length >= pageSize,
        });
      }

      // Handle case where backend returns Map
      if (data is Map<String, dynamic>) {
        return models.NotificationPageResult.fromJson(data);
      }

      debugPrint('Unexpected response format: ${data.runtimeType}');
      return null;
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return null;
    }
  }

  /// Mark a notification as read
  Future<models.Notification?> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.patch(
        "/notification/$notificationId/read",
      );

      if (response.statusCode != 200) {
        debugPrint('Mark as read failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      return models.Notification.fromJson(data);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return null;
    }
  }

  /// Delete a single notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete("/notification/$notificationId");

      if (response.statusCode == 204) {
        return true;
      }

      debugPrint('Delete notification failed: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications for the authenticated user
  Future<ApiMessage> deleteAllNotifications() async {
    try {
      final response = await apiClient.delete("/notification/all");

      if (response.statusCode != 200) {
        debugPrint('Delete all notifications failed: ${response.body}');
        final decoded = jsonDecode(response.body);
        return ApiMessage.fromJson(decoded);
      }

      final data = jsonDecode(response.body);
      final deletedCount = data['deletedCount'] as int? ?? 0;
      return ApiMessage(
        success: true,
        message: "تم حذف $deletedCount إشعار",
        errorCode: null,
      );
    } on SocketException {
      return ApiMessage(
        success: false,
        message: "لا يوجد اتصال بالإنترنت",
        errorCode: "NetworkError",
      );
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return ApiMessage(
        success: false,
        message: "حدث خطأ غير متوقع",
        errorCode: "GeneralError",
      );
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      // Fetch the first page to check for unread items
      // Ideally, the backend should provide an endpoint for count, but we'll use this as a proxy
      final result = await getMyNotifications(pageNumber: 1, pageSize: 20);
      if (result != null) {
        return result.notifications.where((n) => !n.isRead).length;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}
