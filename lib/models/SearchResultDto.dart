import 'package:hive/hive.dart';

part 'SearchResultDto.g.dart'; // Hive adapter generator

@HiveType(typeId: 4)
class ServiceProvider extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String skill;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final String? pay;

  @HiveField(4)
  final String? owner;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final bool isCompany;

  @HiveField(7)
  final int? workerType;

  @HiveField(8)
  final String? mobileNumber;

  @HiveField(9)
  final String? email;

  @HiveField(10)
  final String? locationOfServiceArea;

  @HiveField(11)
  final String? typeOfService;

  @HiveField(12)
  final String? aboutMe;

  @HiveField(13)
  final DateTime cachedAt; // final, immutable

  @HiveField(14)
  final String userName;

  @HiveField(15)
  final String? userId;

  @HiveField(16)
  final bool isOccupied;

  @HiveField(17)
  final String? marketplace;

  @HiveField(18)
  final String? derivedSpec;

  ServiceProvider({
    required this.name,
    required this.skill,
    required this.location,
    this.pay,
    this.owner,
    this.imageUrl,
    this.isCompany = false,
    this.workerType,
    this.mobileNumber,
    this.email,
    this.locationOfServiceArea,
    this.typeOfService,
    this.aboutMe,
    required this.userName,
    this.userId, // Add to constructor
    this.isOccupied = false,
    this.marketplace,
    this.derivedSpec,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now().toUtc();

  ServiceProvider copyWith({
    String? name,
    String? skill,
    String? location,
    String? pay,
    String? owner,
    String? imageUrl,
    bool? isCompany,
    int? workerType,
    String? mobileNumber,
    String? email,
    String? locationOfServiceArea,
    String? typeOfService,
    String? aboutMe,
    DateTime? cachedAt,
    String? userName,
    String? userId,
    bool? isOccupied,
    String? marketplace,
    String? derivedSpec,
  }) {
    return ServiceProvider(
      name: name ?? this.name,
      skill: skill ?? this.skill,
      location: location ?? this.location,
      pay: pay ?? this.pay,
      owner: owner ?? this.owner,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompany: isCompany ?? this.isCompany,
      workerType: workerType ?? this.workerType,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      locationOfServiceArea:
          locationOfServiceArea ?? this.locationOfServiceArea,
      typeOfService: typeOfService ?? this.typeOfService,
      aboutMe: aboutMe ?? this.aboutMe,
      cachedAt: cachedAt ?? this.cachedAt,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      isOccupied: isOccupied ?? this.isOccupied,
      marketplace: marketplace ?? this.marketplace,
      derivedSpec: derivedSpec ?? this.derivedSpec,
    );
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    String getLocation(Map<String, dynamic> json) {
      final parts = ['governorate', 'city', 'district'].map((key) {
        return (json[key] == null || json[key] == "") ? 'غير محدد' : json[key];
      }).toList();
      return parts.join(' - ');
    }

    return ServiceProvider(
      name: json['name'] ?? '',
      skill: json['skill'] ?? '',
      location: json['location'] ?? getLocation(json),
      pay: json['pay']?.toString(),
      owner: json['owner']?.toString(),
      imageUrl: json['imageUrl'],
      isCompany: json['isCompany'] ?? false,
      mobileNumber: json['mobileNumber']?.toString(),
      email: json['email']?.toString(),
      locationOfServiceArea: json['locationOfServiceArea'] ?? getLocation(json),
      typeOfService: json['typeOfService'] ?? '',
      aboutMe: json['aboutMe']?.toString(),
      workerType: json['workerType'],
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'])
          : DateTime.now().toUtc(),
      userName: json['userName'] ?? '',
      userId: json['userId'] ?? json['id'], // Try both userId and id
      isOccupied: json['isOccupied'] as bool? ?? false,
      marketplace: (json['marketPlace'] ?? json['marketplace'] ?? '')
          .toString(),
      derivedSpec: (json['derivedSpec'] ?? json['derviedSpec'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'skill': skill,
      'location': location,
      'pay': pay,
      'owner': owner,
      'imageUrl': imageUrl,
      'isCompany': isCompany,
      'mobileNumber': mobileNumber,
      'email': email,
      'locationOfServiceArea': locationOfServiceArea,
      'typeOfService': typeOfService,
      'aboutMe': aboutMe,
      'workerType': workerType,
      'cachedAt': cachedAt.toIso8601String(),
      'userName': userName,
      'userId': userId, // ✅ Add userId to preserve it in cache
      'isOccupied': isOccupied,
      'marketplace': marketplace,
      'derivedSpec': derivedSpec,
    };
  }
}
