class FaultReportModel {
  final String id;
  final String residentID;
  final String areaID;
  final String title;
  final String description;
  final String status;
  final String location;
  final DateTime timestamp;

  FaultReportModel({
    required this.id,
    required this.residentID,
    required this.areaID,
    required this.title,
    required this.description,
    required this.status,
    required this.location,
    required this.timestamp,
  });

  factory FaultReportModel.fromJson(Map<String, dynamic> json) {
    return FaultReportModel(
      id: json['reportID'] ?? '',
      residentID: json['residentID'] ?? '',
      areaID: json['areaID'] ?? '',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Submitted',
      location: json['location'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportID': id,
      'residentID': residentID,
      'areaID': areaID,
      'title': title,
      'description': description,
      'status': status,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}