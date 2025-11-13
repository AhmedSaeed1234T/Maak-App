class ServiceProvider {
  final String name;
  final String skill;
  final String location;
  final String? pay;
  final String? owner;
  final String? imageUrl;
  final bool isCompany;

  final String? mobileNumber;
  final String? email;
  final String? locationOfServiceArea;
  final String? typeOfService;
  final String? aboutMe;

  ServiceProvider({
    required this.name,
    required this.skill,
    required this.location,
    this.pay,
    this.owner,
    this.imageUrl,
    this.isCompany = false,
    this.mobileNumber,
    this.email,
    this.locationOfServiceArea,
    this.typeOfService,
    this.aboutMe,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      name: json['name'] ?? '',
      skill: json['skill'] ?? '',
      location: json['location'] ?? '',
      pay: json['pay']?.toString(),
      owner: json['owner']?.toString(),
      imageUrl: json['imageUrl'],
      isCompany: json['isCompany'] ?? false,
      mobileNumber: json['mobileNumber']?.toString(),
      email: json['email']?.toString(),
      locationOfServiceArea: json['locationOfServiceArea']?.toString(),
      typeOfService: json['typeOfService']?.toString(),
      aboutMe: json['aboutMe']?.toString(),
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
    };
  }
}
