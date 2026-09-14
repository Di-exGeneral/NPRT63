enum ReportStatus {
  pending('pending', 'Pending'),
  inProgress('in progress', 'In Progress'),
  completed('completed', 'Completed'),
  verified('verified', 'Verified');

  final String key;
  final String label;
  const ReportStatus(this.key, this.label);

  static ReportStatus fromString(String val) {
    for (final s in ReportStatus.values) {
      if (s.key.toLowerCase() == val.toLowerCase() ||
          s.name.toLowerCase() == val.toLowerCase() ||
          s.label.toLowerCase() == val.toLowerCase()) {
        return s;
      }
    }
    return ReportStatus.pending;
  }
}

enum ReportPriority {
  urgent('urgent', 'Urgent'),
  high('high', 'High'),
  medium('medium', 'Medium'),
  low('low', 'Low');

  final String key;
  final String label;
  const ReportPriority(this.key, this.label);

  static ReportPriority fromString(String val) {
    for (final p in ReportPriority.values) {
      if (p.key.toLowerCase() == val.toLowerCase() ||
          p.name.toLowerCase() == val.toLowerCase() ||
          p.label.toLowerCase() == val.toLowerCase()) {
        return p;
      }
    }
    return ReportPriority.medium;
  }
}

class FaultReport {
  final String id;
  final String title;
  final String location;
  final String description;
  final String reportedBy;
  final String reportedDate;
  final String dueDate;
  final ReportStatus status;
  final ReportPriority priority;

  const FaultReport({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.reportedBy,
    required this.reportedDate,
    required this.dueDate,
    required this.status,
    required this.priority,
  });

  FaultReport copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    String? reportedBy,
    String? reportedDate,
    String? dueDate,
    ReportStatus? status,
    ReportPriority? priority,
  }) {
    return FaultReport(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedDate: reportedDate ?? this.reportedDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }

  factory FaultReport.fromJson(Map<String, dynamic> json) {
    return FaultReport(
      id: json['id']?.toString() ?? json['reportID']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Fault Report',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reportedBy: json['reportedBy']?.toString() ?? json['residentID']?.toString() ?? 'Maintenance User',
      reportedDate: json['reportedDate']?.toString() ?? json['timestamp']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      status: ReportStatus.fromString(json['status']?.toString() ?? 'pending'),
      priority: ReportPriority.fromString(json['priority']?.toString() ?? 'medium'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportID': id,
      'title': title,
      'location': location,
      'description': description,
      'reportedBy': reportedBy,
      'reportedDate': reportedDate,
      'dueDate': dueDate,
      'status': status.key,
      'priority': priority.key,
    };
  }
}
