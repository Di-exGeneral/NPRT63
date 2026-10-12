import 'package:dio/dio.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class LoginResult {
  final String token;
  final String role;

  const LoginResult(this.token, this.role);
}

class ApiService {
  ApiService({String? baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Constants.baseUrl,
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 60),
                contentType: Headers.jsonContentType,
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = this.token;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  String? token;

  /// Called when an authenticated request is rejected with 401.
  void Function()? onUnauthorized;

  Future<T> _call<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parse,
  ) async {
    try {
      final response = await request();
      return parse(response.data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401 && token != null) onUnauthorized?.call();
    final data = e.response?.data;
    String? message;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      message = detail is List
          ? detail.map((d) => d is Map ? d['msg'] : '$d').join(', ')
          : '$detail';
    }
    message ??= switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'The server took too long to respond. Please try again.',
      DioExceptionType.connectionError =>
        'Could not reach the HydroAlert server. Check your connection.',
      _ => code == 403
          ? 'You do not have permission to do this.'
          : 'Request failed${code != null ? ' ($code)' : ''}.',
    };
    return ApiException(message, statusCode: code);
  }

  static Map<String, dynamic> _map(dynamic d) =>
      Map<String, dynamic>.from(d as Map);

  static List<T> _list<T>(dynamic d, T Function(Map<String, dynamic>) f) =>
      (d as List).map((e) => f(_map(e))).toList();

  // Auth
  Future<LoginResult> login(String email, String password) => _call(
        () => _dio.post('/auth/login',
            data: {'email': email, 'password': password}),
        (d) => LoginResult('${d['access_token']}', '${d['role']}'),
      );

  Future<AdminUser> getMe() =>
      _call(() => _dio.get('/users/me'), (d) => AdminUser.fromJson(_map(d)));

  // Dashboard
  Future<DashboardSummary> getSummary() => _call(
        () => _dio.get('/dashboard/summary'),
        (d) => DashboardSummary.fromJson(_map(d)),
      );

  // Areas
  Future<List<Area>> getAreas() =>
      _call(() => _dio.get('/areas/'), (d) => _list(d, Area.fromJson));

  Future<Area> createArea(String areaID, String suburb, String municipality) =>
      _call(
        () => _dio.post('/areas/', data: {
          'areaID': areaID,
          'suburbName': suburb,
          'municipalityName': municipality,
        }),
        (d) => Area.fromJson(_map(d)),
      );

  Future<Area> updateArea(String areaID, String suburb, String municipality) =>
      _call(
        () => _dio.put('/areas/$areaID', data: {
          'suburbName': suburb,
          'municipalityName': municipality,
        }),
        (d) => Area.fromJson(_map(d)),
      );

  // Outage schedules
  Future<List<OutageSchedule>> getSchedules() => _call(
        () => _dio.get('/outage-schedules/'),
        (d) => _list(d, OutageSchedule.fromJson),
      );

  Future<OutageSchedule> createSchedule({
    required String areaID,
    required DateTime start,
    required DateTime end,
    required String createdBy,
    String? description,
  }) =>
      _call(
        () => _dio.post('/outage-schedules/', data: {
          'scheduleID': '',
          'areaID': areaID,
          'startTime': toApiDateTime(start),
          'endTime': toApiDateTime(end),
          'description': description,
          'status': OutageStatus.scheduled,
          'createdBy': createdBy,
        }),
        (d) => OutageSchedule.fromJson(_map(d)),
      );

  Future<OutageSchedule> updateSchedule(
    String scheduleID, {
    String? areaID,
    DateTime? start,
    DateTime? end,
    String? description,
  }) =>
      _call(
        () => _dio.put('/outage-schedules/$scheduleID', data: {
          'areaID': ?areaID,
          if (start != null) 'startTime': toApiDateTime(start),
          if (end != null) 'endTime': toApiDateTime(end),
          'description': ?description,
        }),
        (d) => OutageSchedule.fromJson(_map(d)),
      );

  Future<OutageSchedule> setScheduleStatus(String scheduleID, String status) =>
      _call(
        () => _dio.patch('/outage-schedules/$scheduleID/status',
            data: {'status': status}),
        (d) => OutageSchedule.fromJson(_map(d)),
      );

  Future<void> deleteSchedule(String scheduleID) =>
      _call(() => _dio.delete('/outage-schedules/$scheduleID'), (_) {});

  // Fault reports
  Future<List<FaultReport>> getReports() => _call(
        () => _dio.get('/fault-reports/'),
        (d) => _list(d, FaultReport.fromJson),
      );

  Future<FaultReport> getReport(String reportID) => _call(
        () => _dio.get('/fault-reports/$reportID'),
        (d) => FaultReport.fromJson(_map(d)),
      );

  Future<List<ReportHistoryEntry>> getReportHistory(String reportID) => _call(
        () => _dio.get('/fault-reports/$reportID/history'),
        (d) => _list(d, ReportHistoryEntry.fromJson),
      );

  Future<FaultReport> updateReportStatus(
    String reportID,
    String status,
    String changedBy,
  ) =>
      _call(
        () => _dio.patch(
          '/fault-reports/$reportID/status',
          queryParameters: {'changedBy': changedBy},
          data: {'status': status},
        ),
        (d) => FaultReport.fromJson(_map(d)),
      );

  Future<Assignment?> getReportAssignment(String reportID) => _call(
        () => _dio.get('/maintenance/report/$reportID'),
        (d) => d is Map ? Assignment.fromJson(_map(d)) : null,
      );

  Future<void> assignTeam(String reportID, String teamID) => _call(
        () => _dio.post('/maintenance/assign',
            queryParameters: {'reportID': reportID, 'teamID': teamID}),
        (_) {},
      );

  // Maintenance teams
  Future<List<MaintenanceTeam>> getTeams() => _call(
        () => _dio.get('/maintenance/teams'),
        (d) => _list(d, MaintenanceTeam.fromJson),
      );

  //Future<List<MaintenanceTeam>> getTeams() async => [];

  // Emergency alerts
 /* Future<List<EmergencyAlert>> getAlerts() => _call(
        () => _dio.get('/alerts/'),
        (d) => _list(d, EmergencyAlert.fromJson),
      );*/

  Future<List<EmergencyAlert>> getAlerts() async => [];

  Future<EmergencyAlert> sendAlert({
    required String areaID,
    required String alertType,
    required String message,
    String? estimatedDuration,
    required List<String> channels,
  }) =>
      _call(
        () => _dio.post('/alerts/', data: {
          'areaID': areaID,
          'alertType': alertType,
          'message': message,
          if (estimatedDuration != null && estimatedDuration.isNotEmpty)
            'estimatedDuration': estimatedDuration,
          'channels': channels,
        }),
        (d) => EmergencyAlert.fromJson(_map(d)),
      );
}
