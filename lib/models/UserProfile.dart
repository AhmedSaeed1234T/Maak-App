import 'package:abokamall/models/ServiceProviderDto.dart';
import 'package:abokamall/models/Subscription.dart';
import 'package:hive/hive.dart';
part 'UserProfile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String userName;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String phoneNumber;
  @HiveField(5)
  final String imageUrl;
  @HiveField(6)
  final int points;
  @HiveField(7)
  final Subscription? subscription;
  @HiveField(8)
  final ServiceProviderDto? serviceProvider;
  @HiveField(9)
  final String governorate;
  @HiveField(10)
  final String city;
  @HiveField(11)
  final String district;
  @HiveField(12)
  DateTime cachedAt;

  UserProfile({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
    required this.points,
    this.subscription,
    this.serviceProvider,
    required this.governorate,
    required this.city,
    required this.district,
    required this.cachedAt,
  });

  bool get isAvailable => subscription?.isActive ?? true;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final phone = json['phoneNumber'] ?? '';
    return UserProfile(
      userName: json['userName'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: phone,
      imageUrl: json['imageUrl'] ?? '',
      points: json['points'] ?? 0,
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
      serviceProvider: json['serviceProvider'] != null
          ? ServiceProviderDto.fromJson(json['serviceProvider'])
          : null,
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      cachedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'points': points,
      'subscription': subscription?.toJson(),
      'serviceProvider': serviceProvider?.toJson(),
      'governorate': governorate,
      'city': city,
      'district': district,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }
}
