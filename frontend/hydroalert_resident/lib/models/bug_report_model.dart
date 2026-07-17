class BugReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final int reportedById;
  final DateTime createdAt;

  BugReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.reportedById,
    required this.createdAt,
  });

  factory BugReportModel.fromJson(Map<String, dynamic> json) {
    return BugReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      reportedById: json['reported_by_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'reported_by_id': reportedById,
      'created_at': createdAt.toIso8601String(),
    };
  }
}