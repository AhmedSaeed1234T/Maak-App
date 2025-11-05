import 'package:abokamall/models/Subscription.dart';

class Worker {
  String userName;
  String firstName;
  String lastName;
  String email;

  String imageUrl;
  String phoneNumber;
  String password;
  String location;
  String skill;
  String bio;
  int pay;
  String refer;
  bool workerType;
  int points;
  bool isAvailable;
  Subscription? subscription; // nullable in case backend returns null

  Worker(
    this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.imageUrl,
    this.phoneNumber,
    this.password,
    this.location,
    this.skill,
    this.bio,
    this.pay,

    this.refer,
    this.workerType,
    this.points,
    this.isAvailable,
    this.subscription,
  );

  // Fetching from JSON
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      json['UserName'] ?? '',
      json['FirstName'] ?? '',
      json['LastName'] ?? '',
      json['Email'] ?? '',
      json['ImageUrl'] ?? '',
      json['PhoneNumber'] ?? '',
      json['Password'] ?? '',
      json['Location'] ?? '',
      json['Skill'] ?? '',
      json['Bio'] ?? '',
      json['Pay'] ?? '',
      json['Refer'] ?? 0,
      json['WorkerType'] ?? '',
      json['Points'] ?? '',

      json['IsAvailable'] ?? false,
      json['Subscription'] != null
          ? Subscription.fromJson(json['Subscription'])
          : null,
    );
  }

  // Sending data like register or login
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'location': location,
      'bio': bio,
      'providerType': 'Worker',
      'skill': skill,
      'workerType': workerType,
      'pay': pay,
      'refer': refer,
    };
  }
}
