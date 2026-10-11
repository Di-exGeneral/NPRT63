import '../utils/formatters.dart';

String _str(dynamic v) => v?.toString() ?? '';
int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

class AdminUser {
  final String userID;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;

  const AdminUser({
    required this.userID,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        userID: _str(json['userID']),
        username: _str(json['username']),
        email: _str(json['email']),
        phoneNumber: _str(json['phoneNumber']),
        role: _str(json['role']),
      );
}

class Area {
  final String areaID;
  final String suburbName;
  final String municipalityName;

  const Area({
    required this.areaID,
    required this.suburbName,
    required this.municipalityName,
  });

  String get label => '$suburbName, $municipalityName';

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        areaID: _str(json['areaID']),
        suburbName: _str(json['suburbName']),
        municipalityName: _str(json['municipalityName']),
      );
}

class OutageStatus {
  const OutageStatus._();
  static const scheduled = 'Scheduled';
  static const active = 'Active';
  static const completed = 'Completed';
  static const cancelled = 'Cancelled';
  static const all = [scheduled, active, completed, cancelled];
}

class OutageSchedule {
  final String scheduleID;
  final String areaID;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? description;
  final String status;
  final String createdBy;

  const OutageSchedule({
    required this.scheduleID,
    required this.areaID,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.status,
    required this.createdBy,
  });

  bool get isClosed =>
      status == OutageStatus.completed || status == OutageStatus.cancelled;

  bool get isOngoing {
    final now = DateTime.now();
    return !isClosed &&
        startTime != null &&
        endTime != null &&
        !now.isBefore(startTime!) &&
        !now.isAfter(endTime!);
  }

  bool get isUpcoming =>
      !isClosed && startTime != null && startTime!.isAfter(DateTime.now());

  factory OutageSchedule.fromJson(Map<String, dynamic> json) => OutageSchedule(
        scheduleID: _str(json['scheduleID']),
        areaID: _str(json['areaID']),
        startTime: parseApiDateTime(json['startTime']),
        endTime: parseApiDateTime(json['endTime']),
        description: json['description'] as String?,
        status: _str(json['status']),
        createdBy: _str(json['createdBy']),
      );
}

class ReportStatus {
  const ReportStatus._();
  static const submitted = 'Submitted';
  static const underReview = 'Under Review';
  static const assigned = 'Assigned';
  static const inProgress = 'In Progress';
  static const resolved = 'Resolved';
  static const rejected = 'Rejected';
  static const all = [
    submitted,
    underReview,
    assigned,
    inProgress,
    resolved,
    rejected,
  ];
  static const open = [submitted, underReview];
}

class FaultReport {
  final String reportID;
  final String title;
  final String residentID;
  final String areaID;
  final String description;
  final String status;
  final String location;
  final DateTime? timestamp;
  final String? residentName;
  final String? areaName;
  final List<String> photos;

  const FaultReport({
    required this.reportID,
    required this.title,
    required this.residentID,
    required this.areaID,
    required this.description,
    required this.status,
    required this.location,
    required this.timestamp,
    this.residentName,
    this.areaName,
    this.photos = const [],
  });

  String get shortId =>
      reportID.length > 8 ? reportID.substring(0, 8).toUpperCase() : reportID;

  String get displayTitle =>
      title.isEmpty || title == 'Untitled' ? 'Fault report $shortId' : title;

  factory FaultReport.fromJson(Map<String, dynamic> json) => FaultReport(
        reportID: _str(json['reportID']),
        title: _str(json['title']),
        residentID: _str(json['residentID']),
        areaID: _str(json['areaID']),
        description: _str(json['description']),
        status: _str(json['status']),
        location: _str(json['location']),
        timestamp: parseApiDateTime(json['timestamp']),
        residentName: json['residentName'] as String?,
        areaName: json['areaName'] as String?,
        photos: (json['photos'] as List?)?.map((e) => '$e').toList() ??
            const [],
      );
}

class ReportHistoryEntry {
  final String? previousStatus;
  final String newStatus;
  final String changedBy;
  final DateTime? changedAt;

  const ReportHistoryEntry({
    required this.previousStatus,
    required this.newStatus,
    required this.changedBy,
    required this.changedAt,
  });

  factory ReportHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ReportHistoryEntry(
        previousStatus: json['previousStatus'] as String?,
        newStatus: _str(json['newStatus']),
        changedBy: _str(json['changedBy']),
        changedAt: parseApiDateTime(
          json['changedAt'] ?? json['timestamp'] ?? json['changeDate'],
        ),
      );
}

class Assignment {
  final String teamID;
  final DateTime? assignedAt;

  const Assignment({required this.teamID, required this.assignedAt});

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        teamID: _str(json['teamID']),
        assignedAt: parseApiDateTime(json['assignedAt']),
      );
}

class MaintenanceTeam {
  final String teamID;
  final String name;
  final String email;
  final String phoneNumber;
  final int activeAssignments;

  const MaintenanceTeam({
    required this.teamID,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.activeAssignments,
  });

  factory MaintenanceTeam.fromJson(Map<String, dynamic> json) =>
      MaintenanceTeam(
        teamID: _str(json['teamID']),
        name: _str(json['name']),
        email: _str(json['email']),
        phoneNumber: _str(json['phoneNumber']),
        activeAssignments: _int(json['activeAssignments']),
      );
}

class EmergencyAlert {
  final String alertID;
  final String areaID;
  final String? areaName;
  final String alertType;
  final String message;
  final String? estimatedDuration;
  final List<String> channels;
  final int recipientCount;
  final DateTime? createdAt;

  const EmergencyAlert({
    required this.alertID,
    required this.areaID,
    required this.areaName,
    required this.alertType,
    required this.message,
    required this.estimatedDuration,
    required this.channels,
    required this.recipientCount,
    required this.createdAt,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) => EmergencyAlert(
        alertID: _str(json['alertID']),
        areaID: _str(json['areaID']),
        areaName: json['areaName'] as String?,
        alertType: _str(json['alertType']),
        message: _str(json['message']),
        estimatedDuration: json['estimatedDuration'] as String?,
        channels:
            (json['channels'] as List?)?.map((e) => '$e').toList() ?? const [],
        recipientCount: _int(json['recipientCount']),
        createdAt: parseApiDateTime(json['createdAt']),
      );
}

class DashboardSummary {
  final int totalReports;
  final Map<String, int> reportsByStatus;
  final int totalSchedules;
  final int ongoingOutages;
  final int upcomingOutages;
  final int areas;
  final int maintenanceTeams;
  final int alertsSent;

  const DashboardSummary({
    required this.totalReports,
    required this.reportsByStatus,
    required this.totalSchedules,
    required this.ongoingOutages,
    required this.upcomingOutages,
    required this.areas,
    required this.maintenanceTeams,
    required this.alertsSent,
  });

  int reportsWith(List<String> statuses) =>
      statuses.fold(0, (sum, s) => sum + (reportsByStatus[s] ?? 0));

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        totalReports: _int(json['totalReports']),
        reportsByStatus: (json['reportsByStatus'] as Map? ?? {})
            .map((k, v) => MapEntry('$k', _int(v))),
        totalSchedules: _int(json['totalSchedules']),
        ongoingOutages: _int(json['ongoingOutages']),
        upcomingOutages: _int(json['upcomingOutages']),
        areas: _int(json['areas']),
        maintenanceTeams: _int(json['maintenanceTeams']),
        alertsSent: _int(json['alertsSent']),
      );
}
