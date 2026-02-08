class Subscription {
  // int id;
  // String userId;
  // User user;
  DateTime startDate;
  DateTime endDate;

  Subscription({
    // required this.id,
    // required this.userId,
    // required this.user,
    required this.startDate,
    required this.endDate,
  });

  // Computed property for IsActive
  bool get isActive => endDate.isAfter(DateTime.now().toUtc());

  // Factory to create Subscription from JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      // id: json['Id'] ?? 0,
      // userId: json['UserId'] ?? '',
      // user: User.fromJson(json['User'] ?? {}),
      startDate: DateTime.tryParse(json['StartDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['EndDate'] ?? '') ?? DateTime.now(),
    );
  }

  // Convert to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      // 'Id': id,
      // 'UserId': userId,
      // 'User': user.toJson(),
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
    };
  }
}
