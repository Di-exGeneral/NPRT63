import 'package:equatable/equatable.dart';

enum FaultType { lowPressure, noWater, contamination, leak, other }

enum ReportStatus { submitted, reviewed, assigned, inProgress, resolved, closed }

class FaultReport extends Equatable {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reporterPhone;
  final String address;
  final String area;
  final double latitude;
  final double longitude;
  final FaultType faultType;
  final String description;
  final List<String> photoUrls;
  final ReportStatus status;
  final DateTime reportedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final String? assignedTeamId;
  final String? assignedTeamName;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final int priority; // 1-5, where 1 is highest priority

  const FaultReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reporterPhone,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.faultType,
    required this.description,
    required this.photoUrls,
    required this.status,
    required this.reportedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.assignedTeamId,
    this.assignedTeamName,
    this.assignedAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.priority = 3,
  });

  FaultReport copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reporterPhone,
    String? address,
    String? area,
    double? latitude,
    double? longitude,
    FaultType? faultType,
    String? description,
    List<String>? photoUrls,
    ReportStatus? status,
    DateTime? reportedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
    String? assignedTeamId,
    String? assignedTeamName,
    DateTime? assignedAt,
    DateTime? resolvedAt,
    String? resolutionNotes,
    int? priority,
  }) {
    return FaultReport(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      address: address ?? this.address,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      faultType: faultType ?? this.faultType,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      assignedTeamName: assignedTeamName ?? this.assignedTeamName,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        reporterName,
        reporterPhone,
        address,
        area,
        latitude,
        longitude,
        faultType,
        description,
        photoUrls,
        status,
        reportedAt,
        reviewedAt,
        reviewedBy,
        reviewNotes,
        assignedTeamId,
        assignedTeamName,
        assignedAt,
        resolvedAt,
        resolutionNotes,
        priority,
      ];
}
