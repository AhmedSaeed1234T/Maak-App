import 'package:flutter/foundation.dart';

class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool isRead;
  final String senderName;
  final String senderId;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.senderName,
    required this.senderId,
    required this.createdAt,

    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    // Handle DateTime parsing safely
    DateTime parseCreatedAt() {
      // Debug prints
      if (json['createdAt'] == null && json['timestamp'] == null) {
        debugPrint(
          '⚠️ Notification: Missing createdAt/timestamp. Keys: ${json.keys.toList()}',
        );
        return DateTime.now();
      }

      final createdAtValue = json['createdAt'] ?? json['timestamp'];
      debugPrint('🔔 Parsing Notification Date: Raw Value: $createdAtValue');

      if (createdAtValue is String) {
        final parsed = DateTime.tryParse(createdAtValue);
        debugPrint('   -> Parsed: $parsed (isUtc: ${parsed?.isUtc})');
        if (parsed != null) return parsed;
      } else if (createdAtValue is int) {
        // Handle Unix timestamp
        return DateTime.fromMillisecondsSinceEpoch(createdAtValue);
      }

      return DateTime.now();
    }

    // Handle data field safely
    Map<String, dynamic>? parseData() {
      if (json['data'] == null) return null;
      if (json['data'] is Map) {
        return Map<String, dynamic>.from(json['data'] as Map);
      }
      return null;
    }

    return Notification(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['Title']?.toString() ?? '',
      body:
          json['body']?.toString() ??
          json['Body']?.toString() ??
          json['message']?.toString() ??
          '',
      isRead: json['isRead'] as bool? ?? json['IsRead'] as bool? ?? false,
      senderId: json['senderId'],
      senderName: json['senderName'],

      createdAt: parseCreatedAt(),
      data: parseData(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      if (data != null) 'data': data,
    };
  }
}

class NotificationPageResult {
  final List<Notification> notifications;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final bool hasMore;

  NotificationPageResult({
    required this.notifications,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
  });

  factory NotificationPageResult.fromJson(dynamic json) {
    // Handle case where json is already a List (shouldn't happen but be safe)
    if (json is List) {
      final parsedNotifications = json
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Notification.fromJson(item);
              }
              return null;
            } catch (e) {
              return null;
            }
          })
          .whereType<Notification>()
          .toList();

      return NotificationPageResult(
        notifications: parsedNotifications,
        pageNumber: 1,
        pageSize: json.length,
        totalCount: json.length,
        hasMore: false,
      );
    }

    // Handle case where json is a Map
    if (json is! Map<String, dynamic>) {
      throw FormatException(
        'Expected Map<String, dynamic> or List, got ${json.runtimeType}',
      );
    }

    // Handle different response structures - backend might return array directly or wrapped
    List<dynamic> notificationsList = [];

    if (json['notifications'] != null && json['notifications'] is List) {
      notificationsList = json['notifications'] as List<dynamic>;
    } else if (json['items'] != null && json['items'] is List) {
      notificationsList = json['items'] as List<dynamic>;
    } else if (json['data'] != null && json['data'] is List) {
      notificationsList = json['data'] as List<dynamic>;
    } else if (json['results'] != null && json['results'] is List) {
      notificationsList = json['results'] as List<dynamic>;
    }

    // Safely parse notifications
    final parsedNotifications = notificationsList
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return Notification.fromJson(item);
            }
            return null;
          } catch (e) {
            return null;
          }
        })
        .whereType<Notification>()
        .toList();

    // Calculate pagination info
    final pageSize = json['pageSize'] as int? ?? 20;
    final pageNumber =
        json['pageNumber'] as int? ??
        json['currentPage'] as int? ??
        json['page'] as int? ??
        1;
    final totalCount =
        json['totalCount'] as int? ??
        json['total'] as int? ??
        json['totalRecords'] as int? ??
        parsedNotifications.length;

    // Determine if there are more pages
    final hasMore =
        json['hasMore'] as bool? ??
        (json['hasNextPage'] as bool?) ??
        (parsedNotifications.length >= pageSize &&
            (pageNumber * pageSize) < totalCount);

    return NotificationPageResult(
      notifications: parsedNotifications,
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }
}
