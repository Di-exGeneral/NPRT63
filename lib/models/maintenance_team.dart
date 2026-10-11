import 'package:equatable/equatable.dart';

enum TeamStatus { available, busy, offline }

class MaintenanceTeam extends Equatable {
  final String id;
  final String name;
  final String leadName;
  final String leadPhone;
  final List<String> memberIds;
  final List<String> memberNames;
  final String area;
  final String specialization;
  final TeamStatus status;
  final int activeTaskCount;
  final double latitude;
  final double longitude;
  final DateTime lastLocationUpdate;
  final bool isActive;

  const MaintenanceTeam({
    required this.id,
    required this.name,
    required this.leadName,
    required this.leadPhone,
    required this.memberIds,
    required this.memberNames,
    required this.area,
    required this.specialization,
    required this.status,
    required this.activeTaskCount,
    required this.latitude,
    required this.longitude,
    required this.lastLocationUpdate,
    this.isActive = true,
  });

  MaintenanceTeam copyWith({
    String? id,
    String? name,
    String? leadName,
    String? leadPhone,
    List<String>? memberIds,
    List<String>? memberNames,
    String? area,
    String? specialization,
    TeamStatus? status,
    int? activeTaskCount,
    double? latitude,
    double? longitude,
    DateTime? lastLocationUpdate,
    bool? isActive,
  }) {
    return MaintenanceTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      leadName: leadName ?? this.leadName,
      leadPhone: leadPhone ?? this.leadPhone,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      area: area ?? this.area,
      specialization: specialization ?? this.specialization,
      status: status ?? this.status,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        leadName,
        leadPhone,
        memberIds,
        memberNames,
        area,
        specialization,
        status,
        activeTaskCount,
        latitude,
        longitude,
        lastLocationUpdate,
        isActive,
      ];
}
