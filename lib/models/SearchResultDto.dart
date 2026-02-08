class ServiceProvider {
  final String name;
  final String skill;
  final String location;
  final String? pay;
  final String? owner;
  final String? imageUrl;
  final bool isCompany;
  final int? workerType;
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
    this.workerType,
    this.mobileNumber,
    this.email,
    this.locationOfServiceArea,
    this.typeOfService,
    this.aboutMe,
  });

  static String? returnSuitableSkillName(String skill) {
    switch (skill) {
      case 'Company':
        return 'شركة';
      case 'Contractor':
        return 'مقاول';
      case 'Engineer':
        return 'مهندس';
      case 'Worker':
        return 'عامل';
      case 'Marketplace':
        return 'متجر';
      default:
        return skill;
    }
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      name: json['name'] ?? '',
      skill: json['skill'] ?? '',
      location:
          '${json['governorate'] ?? 'غير محدد'} - ${json['city'] ?? 'غير محدد'} - ${json['district'] ?? 'غير محدد'}' ??
          '',
      pay: json['pay']?.toString(),
      owner: json['owner']?.toString(),
      imageUrl: json['imageUrl'],
      isCompany: json['isCompany'] ?? false,
      mobileNumber: json['mobileNumber']?.toString(),
      email: json['email']?.toString(),
      locationOfServiceArea: json['locationOfServiceArea']?.toString(),
      typeOfService: json['typeOfService'] ?? '',
      aboutMe: json['aboutMe']?.toString(),
      workerType: json['workerType'],
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
    };
  }
}
