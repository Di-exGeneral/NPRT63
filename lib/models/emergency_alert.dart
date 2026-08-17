import 'package:equatable/equatable.dart';

enum AlertSeverity { low, medium, high, critical }

class EmergencyAlert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final List<String> targetAreas;
  final int estimatedAffectedResidents;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? sentAt;
  final int smsSentCount;
  final int smsDeliveredCount;
  final bool isActive;

  const EmergencyAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.targetAreas,
    required this.estimatedAffectedResidents,
    required this.createdAt,
    required this.createdBy,
    this.sentAt,
    this.smsSentCount = 0,
    this.smsDeliveredCount = 0,
    this.isActive = true,
  });

  EmergencyAlert copyWith({
    String? id,
    String? title,
    String? message,
    AlertSeverity? severity,
    List<String>? targetAreas,
    int? estimatedAffectedResidents,
    DateTime? createdAt,
    String? createdBy,
    DateTime? sentAt,
    int? smsSentCount,
    int? smsDeliveredCount,
    bool? isActive,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      targetAreas: targetAreas ?? this.targetAreas,
      estimatedAffectedResidents:
          estimatedAffectedResidents ?? this.estimatedAffectedResidents,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      sentAt: sentAt ?? this.sentAt,
      smsSentCount: smsSentCount ?? this.smsSentCount,
      smsDeliveredCount: smsDeliveredCount ?? this.smsDeliveredCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        severity,
        targetAreas,
        estimatedAffectedResidents,
        createdAt,
        createdBy,
        sentAt,
        smsSentCount,
        smsDeliveredCount,
        isActive,
      ];
}
