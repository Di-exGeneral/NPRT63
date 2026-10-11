import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';

class HydroAlertApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  late final Dio _dio;
  final Logger _logger = Logger();

  HydroAlertApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ============ WATER OUTAGES ============

  Future<List<WaterOutage>> getWaterOutages({
    String? areaId,
    OutageStatus? status,
  }) async {
    try {
      final response = await _dio.get(
        '/outages',
        queryParameters: {
          if (areaId != null) 'area_id': areaId,
          if (status != null)
            'status': status.toString().split('.').last,
        },
      );
      return (response.data as List)
          .map((outage) => _parseWaterOutage(outage))
          .toList();
    } catch (e) {
      _logger.e('Error fetching water outages: $e');
      rethrow;
    }
  }

  Future<WaterOutage> getWaterOutageById(String id) async {
    try {
      final response = await _dio.get('/outages/$id');
      return _parseWaterOutage(response.data);
    } catch (e) {
      _logger.e('Error fetching water outage: $e');
      rethrow;
    }
  }

  Future<WaterOutage> createWaterOutage({
    required String area,
    required String areaId,
    required String reason,
    required DateTime scheduledStartTime,
    required DateTime scheduledEndTime,
    String? description,
    required List<String> affectedAreas,
    required int estimatedAffectedResidents,
  }) async {
    try {
      final response = await _dio.post(
        '/outages',
        data: {
          'area': area,
          'area_id': areaId,
          'reason': reason,
          'scheduled_start_time': scheduledStartTime.toIso8601String(),
          'scheduled_end_time': scheduledEndTime.toIso8601String(),
          'description': description,
          'affected_areas': affectedAreas,
          'estimated_affected_residents': estimatedAffectedResidents,
        },
      );
      return _parseWaterOutage(response.data);
    } catch (e) {
      _logger.e('Error creating water outage: $e');
      rethrow;
    }
  }

  Future<WaterOutage> updateWaterOutage({
    required String id,
    OutageStatus? status,
    String? description,
    DateTime? scheduledEndTime,
  }) async {
    try {
      final response = await _dio.put(
        '/outages/$id',
        data: {
          if (status != null) 'status': status.toString().split('.').last,
          if (description != null) 'description': description,
          if (scheduledEndTime != null)
            'scheduled_end_time': scheduledEndTime.toIso8601String(),
        },
      );
      return _parseWaterOutage(response.data);
    } catch (e) {
      _logger.e('Error updating water outage: $e');
      rethrow;
    }
  }

  // ============ FAULT REPORTS ============

  Future<List<FaultReport>> getFaultReports({
    ReportStatus? status,
    String? areaId,
    int? priority,
  }) async {
    try {
      final response = await _dio.get(
        '/fault-reports',
        queryParameters: {
          if (status != null) 'status': status.toString().split('.').last,
          if (areaId != null) 'area_id': areaId,
          if (priority != null) 'priority': priority,
        },
      );
      return (response.data as List)
          .map((report) => _parseFaultReport(report))
          .toList();
    } catch (e) {
      _logger.e('Error fetching fault reports: $e');
      rethrow;
    }
  }

  Future<FaultReport> getFaultReportById(String id) async {
    try {
      final response = await _dio.get('/fault-reports/$id');
      return _parseFaultReport(response.data);
    } catch (e) {
      _logger.e('Error fetching fault report: $e');
      rethrow;
    }
  }

  Future<FaultReport> reviewFaultReport({
    required String id,
    required String reviewNotes,
    required int priority,
  }) async {
    try {
      final response = await _dio.post(
        '/fault-reports/$id/review',
        data: {
          'review_notes': reviewNotes,
          'priority': priority,
        },
      );
      return _parseFaultReport(response.data);
    } catch (e) {
      _logger.e('Error reviewing fault report: $e');
      rethrow;
    }
  }

  Future<FaultReport> assignFaultReport({
    required String reportId,
    required String teamId,
  }) async {
    try {
      final response = await _dio.post(
        '/fault-reports/$reportId/assign',
        data: {
          'team_id': teamId,
        },
      );
      return _parseFaultReport(response.data);
    } catch (e) {
      _logger.e('Error assigning fault report: $e');
      rethrow;
    }
  }

  Future<FaultReport> resolveFaultReport({
    required String id,
    required String resolutionNotes,
  }) async {
    try {
      final response = await _dio.post(
        '/fault-reports/$id/resolve',
        data: {
          'resolution_notes': resolutionNotes,
        },
      );
      return _parseFaultReport(response.data);
    } catch (e) {
      _logger.e('Error resolving fault report: $e');
      rethrow;
    }
  }

  // ============ MAINTENANCE TEAMS ============

  Future<List<MaintenanceTeam>> getMaintenanceTeams({
    String? areaId,
    TeamStatus? status,
  }) async {
    try {
      final response = await _dio.get(
        '/maintenance-teams',
        queryParameters: {
          if (areaId != null) 'area_id': areaId,
          if (status != null) 'status': status.toString().split('.').last,
        },
      );
      return (response.data as List)
          .map((team) => _parseMaintenanceTeam(team))
          .toList();
    } catch (e) {
      _logger.e('Error fetching maintenance teams: $e');
      rethrow;
    }
  }

  Future<MaintenanceTeam> getMaintenanceTeamById(String id) async {
    try {
      final response = await _dio.get('/maintenance-teams/$id');
      return _parseMaintenanceTeam(response.data);
    } catch (e) {
      _logger.e('Error fetching maintenance team: $e');
      rethrow;
    }
  }

  // ============ EMERGENCY ALERTS ============

  Future<EmergencyAlert> sendEmergencyAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    required List<String> targetAreas,
    required int estimatedAffectedResidents,
  }) async {
    try {
      final response = await _dio.post(
        '/emergency-alerts',
        data: {
          'title': title,
          'message': message,
          'severity': severity.toString().split('.').last,
          'target_areas': targetAreas,
          'estimated_affected_residents': estimatedAffectedResidents,
        },
      );
      return _parseEmergencyAlert(response.data);
    } catch (e) {
      _logger.e('Error sending emergency alert: $e');
      rethrow;
    }
  }

  Future<List<EmergencyAlert>> getEmergencyAlerts() async {
    try {
      final response = await _dio.get('/emergency-alerts');
      return (response.data as List)
          .map((alert) => _parseEmergencyAlert(alert))
          .toList();
    } catch (e) {
      _logger.e('Error fetching emergency alerts: $e');
      rethrow;
    }
  }

  // ============ PARSERS ============

  WaterOutage _parseWaterOutage(Map<String, dynamic> json) {
    return WaterOutage(
      id: json['id'] as String,
      area: json['area'] as String,
      areaId: json['area_id'] as String,
      reason: json['reason'] as String,
      scheduledStartTime:
          DateTime.parse(json['scheduled_start_time'] as String),
      scheduledEndTime: DateTime.parse(json['scheduled_end_time'] as String),
      status: OutageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String),
      ),
      description: json['description'] as String?,
      affectedAreas: List<String>.from(json['affected_areas'] as List),
      estimatedAffectedResidents:
          json['estimated_affected_residents'] as int,
      notificationSent: json['notification_sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String,
    );
  }

  FaultReport _parseFaultReport(Map<String, dynamic> json) {
    return FaultReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reporterName: json['reporter_name'] as String,
      reporterPhone: json['reporter_phone'] as String,
      address: json['address'] as String,
      area: json['area'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      faultType: FaultType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['fault_type'] as String),
      ),
      description: json['description'] as String,
      photoUrls: List<String>.from(json['photo_urls'] as List? ?? []),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String),
      ),
      reportedAt: DateTime.parse(json['reported_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewedBy: json['reviewed_by'] as String?,
      reviewNotes: json['review_notes'] as String?,
      assignedTeamId: json['assigned_team_id'] as String?,
      assignedTeamName: json['assigned_team_name'] as String?,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolutionNotes: json['resolution_notes'] as String?,
      priority: json['priority'] as int? ?? 3,
    );
  }

  MaintenanceTeam _parseMaintenanceTeam(Map<String, dynamic> json) {
    return MaintenanceTeam(
      id: json['id'] as String,
      name: json['name'] as String,
      leadName: json['lead_name'] as String,
      leadPhone: json['lead_phone'] as String,
      memberIds: List<String>.from(json['member_ids'] as List),
      memberNames: List<String>.from(json['member_names'] as List),
      area: json['area'] as String,
      specialization: json['specialization'] as String,
      status: TeamStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String),
      ),
      activeTaskCount: json['active_task_count'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      lastLocationUpdate:
          DateTime.parse(json['last_location_update'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  EmergencyAlert _parseEmergencyAlert(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == (json['severity'] as String),
      ),
      targetAreas: List<String>.from(json['target_areas'] as List),
      estimatedAffectedResidents:
          json['estimated_affected_residents'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      smsSentCount: json['sms_sent_count'] as int? ?? 0,
      smsDeliveredCount: json['sms_delivered_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
