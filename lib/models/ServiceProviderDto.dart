import 'package:hive/hive.dart';

part 'ServiceProviderDto.g.dart';

@HiveType(typeId: 1)
class ServiceProviderDto extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final bool isAvailable;

  @HiveField(2)
  final String bio;

  @HiveField(3)
  final String providerType;

  @HiveField(4)
  final String specialization;

  @HiveField(5)
  final double pay;

  @HiveField(6)
  final String business;

  @HiveField(7)
  final String owner;

  @HiveField(8)
  final int workerTypes;

  @HiveField(9)
  final String? marketplace;

  @HiveField(10)
  final String? derivedSpec;

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
    this.marketplace,
    this.derivedSpec,
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
      marketplace: json['marketplace']?.toString(),
      derivedSpec: (json['derivedSpec'] ?? json['derviedSpec'] ?? '')
          .toString(),
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
      'marketplace': marketplace,
      'derivedSpec': derivedSpec,
    };
  }
}
