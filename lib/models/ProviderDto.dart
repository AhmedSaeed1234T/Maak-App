import 'package:flutter/material.dart';

class ProviderDto {
  final String imageUrl;
  final String fullName;
  final String specialization;
  final int? points;

  ProviderDto({
    required this.imageUrl,
    required this.fullName,
    required this.specialization,
    required this.points,
  });

  factory ProviderDto.fromJson(Map<String, dynamic> json) {
    debugPrint(json['points'].toString());
    return ProviderDto(
      imageUrl: json['imageUrl'] ?? '',
      fullName: json['fullName'] ?? '',
      specialization: json['specialization'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'fullName': fullName,
      'specialization': specialization,
      'points': 0,
    };
  }
}
