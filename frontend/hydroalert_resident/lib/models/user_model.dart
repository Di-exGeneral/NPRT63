class UserModel {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userID'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}

class ResidentModel {
  final String residentID;
  final String userID;
  final String? areaID;

  ResidentModel({
    required this.residentID,
    required this.userID,
    this.areaID,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      residentID: json['residentID'],
      userID: json['userID'],
      areaID: json['areaID'],
    );
  }
}