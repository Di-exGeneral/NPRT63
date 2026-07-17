class OutageScheduleModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final int areaId;
  final String areaName;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  OutageScheduleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.areaId,
    required this.areaName,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory OutageScheduleModel.fromJson(Map<String, dynamic> json) {
    return OutageScheduleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      areaId: json['area_id'],
      areaName: json['area_name'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'area_id': areaId,
      'area_name': areaName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}