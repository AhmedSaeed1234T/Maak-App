class RegisterUserDto {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String password;
  double lat; // for locationCoords
  double lng; // for locationCoords
  String userType;
  String location;
  String bio;
  String providerType;
  String? skill;
  int? workerType; // 0 = daily, 1 = fixed
  String? business;
  String? owner;
  double? pay;
  String? specialization;
  String? referralUserName;

  RegisterUserDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.lat,
    required this.lng,
    required this.userType,
    required this.location,
    required this.bio,
    required this.providerType,
    this.skill,
    this.workerType,
    this.business,
    this.owner,
    this.pay,
    this.specialization,
    this.referralUserName,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
      "locationCoords": {"lat": lat, "lng": lng},
      "userType": userType,
      "location": location,
      "bio": bio,
      "providerType": providerType,
      "skill": skill,
      "workerType": workerType,
      "business": business,
      "owner": owner,
      "pay": pay,
      "specialization": specialization,
      "referralUserName": referralUserName,
    };
  }
}
