class ProviderDto {
  final String imageUrl;
  final String fullName;
  final String specialization;

  ProviderDto({
    required this.imageUrl,
    required this.fullName,
    required this.specialization,
  });

  factory ProviderDto.fromJson(Map<String, dynamic> json) {
    return ProviderDto(
      imageUrl: json['imageUrl'] ?? '',
      fullName: json['fullName'] ?? '',
      specialization: json['specialization'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'fullName': fullName,
      'specialization': specialization,
    };
  }
}
