import 'package:equatable/equatable.dart';

enum UserRole { admin, maintenanceTeam, itStaff }

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String municipality;
  final DateTime createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.municipality,
    required this.createdAt,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    String? municipality,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      municipality: municipality ?? this.municipality,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        role,
        municipality,
        createdAt,
        isActive,
      ];
}
