import 'package:hive/hive.dart';

part 'Subscription.g.dart'; // <-- exactly one per file

@HiveType(typeId: 99)
class Subscription {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String startDate;
  @HiveField(2)
  final String endDate;
  @HiveField(3)
  final bool isActive;
  @HiveField(4)
  final String updatedAt;

  Subscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      isActive: json['isActive'] ?? false,
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'updatedAt': updatedAt,
    };
  }
}
