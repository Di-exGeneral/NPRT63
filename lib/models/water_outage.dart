import 'package:equatable/equatable.dart';

enum OutageStatus { planned, ongoing, completed, cancelled }

class WaterOutage extends Equatable {
  final String id;
  final String area;
  final String areaId;
  final String reason;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final OutageStatus status;
  final String? description;
  final List<String> affectedAreas;
  final int estimatedAffectedResidents;
  final bool notificationSent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const WaterOutage({
    required this.id,
    required this.area,
    required this.areaId,
    required this.reason,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.status,
    this.description,
    required this.affectedAreas,
    required this.estimatedAffectedResidents,
    this.notificationSent = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  WaterOutage copyWith({
    String? id,
    String? area,
    String? areaId,
    String? reason,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    OutageStatus? status,
    String? description,
    List<String>? affectedAreas,
    int? estimatedAffectedResidents,
    bool? notificationSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return WaterOutage(
      id: id ?? this.id,
      area: area ?? this.area,
      areaId: areaId ?? this.areaId,
      reason: reason ?? this.reason,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      status: status ?? this.status,
      description: description ?? this.description,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      estimatedAffectedResidents:
          estimatedAffectedResidents ?? this.estimatedAffectedResidents,
      notificationSent: notificationSent ?? this.notificationSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        area,
        areaId,
        reason,
        scheduledStartTime,
        scheduledEndTime,
        status,
        description,
        affectedAreas,
        estimatedAffectedResidents,
        notificationSent,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
