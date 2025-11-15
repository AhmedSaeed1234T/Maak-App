class UserProfile {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String imageUrl;
  final int points;
  final Subscription? subscription;
  final ServiceProviderDto? serviceProvider;
  final String governorate;
  final String city;
  final String district;

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
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userName: json['userName'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
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
    };
  }
}

class ServiceProviderDto {
  final int id;
  final bool isAvailable;
  final String bio;
  final String providerType;
  final String specialization;
  final double pay;
  final String business;
  final String owner;
  final int workerTypes;

  ServiceProviderDto({
    required this.id,
    required this.isAvailable,
    required this.bio,
    required this.providerType,
    required this.specialization,
    required this.pay,
    required this.business,
    required this.owner,
    required this.workerTypes,
  });

  factory ServiceProviderDto.fromJson(Map<String, dynamic> json) {
    return ServiceProviderDto(
      id: json['id'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      bio: json['bio'] ?? '',
      providerType: json['providerType'] ?? '',
      specialization: json['specialization'] ?? '',
      pay: (json['pay'] != null) ? (json['pay'] as num).toDouble() : 0,
      business: json['business'] ?? '',
      owner: json['owner'] ?? '',
      workerTypes: json['workerTypes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAvailable': isAvailable,
      'bio': bio,
      'providerType': providerType,
      'specialization': specialization,
      'pay': pay,
      'business': business,
      'owner': owner,
      'workerTypes': workerTypes,
    };
  }
}

class Subscription {
  final int id;
  final String startDate;
  final String endDate;
  final bool isActive;

  Subscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
