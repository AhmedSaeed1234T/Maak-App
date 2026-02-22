class RegisterUserDto {
  String firstName;
  String? lastName;
  String email;
  String phoneNumber;
  String password;
  String? governorate;
  String? city;
  String? district;
  String? bio;
  String? providerType;
  String? skill;
  int? workerType; // 0 = daily, 1 = fixed
  String? business;
  String? owner;
  double? pay;
  String? specialization;
  String? referralUserName;
  // NEW: marketplace attribute (for workers/assistants/marketplaces)
  String? marketplace;
  // NEW: derived specialization (for engineers/workers/assistants)
  String? derivedSpec;

  RegisterUserDto({
    required this.firstName,
    this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.governorate,
    this.city,
    this.district,
    this.bio,
    this.providerType,
    this.skill,
    this.workerType,
    this.business,
    this.owner,
    this.pay,
    this.specialization,
    this.referralUserName,
    this.marketplace,
    this.derivedSpec,
  });

  Map<String, dynamic> toJson() {
    final userRegister = {
      "firstName": firstName,
      "lastName": lastName ?? '',
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
      "governorate": governorate,
      "city": city,
      "district": district,
      "bio": bio,
      "providerType": providerType,
      "skill": skill,
      "workerType": workerType ?? 1,
      "business": business,
      "owner": owner,
      "pay": pay ?? 0.0,
      "specialization": specialization,
      "marketplace": marketplace,
      "derivedSpec": derivedSpec,
    };
    if (referralUserName != null && referralUserName!.isNotEmpty) {
      userRegister['referralUserName'] = referralUserName;
    }
    return userRegister;
  }

  factory RegisterUserDto.fromJson(Map<String, dynamic> json) {
    return RegisterUserDto(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      bio: json['bio'] ?? '',
      providerType: json['providerType'] ?? '',
      skill: json['skill'] ?? '',
      workerType: json['workerType'] ?? 1,
      business: json['business'] ?? '',
      owner: json['owner'] ?? '',
      pay: (json['pay'] != null) ? (json['pay'] as num).toDouble() : 0.0,
      specialization: json['specialization'] ?? '',
      referralUserName: json['referralUserName'] ?? '',
      marketplace: json['marketplace'] ?? '',
      derivedSpec: json['derivedSpec'] ?? '',
    );
  }
}
