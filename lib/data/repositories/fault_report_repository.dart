import 'package:hydroalert_reports/domain/models/fault_report.dart';
import 'package:hydroalert_reports/services/api_service.dart';

abstract class FaultReportRepository {
  ApiService get apiService;
  List<FaultReport> getReports();
  FaultReport? getReportById(String id);
  void updateReportStatus(String id, ReportStatus newStatus);
  void verifyReport(String id);
  void addReport(FaultReport report);
  void deleteReport(String id);

  Future<List<FaultReport>> fetchReportsFromApi();
  Future<FaultReport> createReportOnApi(FaultReport report);
  Future<FaultReport?> updateReportStatusOnApi(String id, ReportStatus newStatus, {required String changedBy});
}

class InMemoryFaultReportRepository implements FaultReportRepository {
  final ApiService _apiService;

  InMemoryFaultReportRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  ApiService get apiService => _apiService;

  final List<FaultReport> _reports = [
    const FaultReport(
      id: 'REP-101',
      title: 'Water Pump Inspection',
      location: 'Sector A - Building 3',
      description:
          'Routine inspection of water pump to ensure proper functioning. Check for unusual noises, vibrations, and leaks.',
      reportedBy: 'System Administrator',
      reportedDate: '2026-05-06',
      dueDate: '2026-05-08',
      status: ReportStatus.pending,
      priority: ReportPriority.high,
    ),
    const FaultReport(
      id: 'REP-102',
      title: 'Pipe Leak Repair',
      location: 'Sector B - Building 7',
      description:
          'Detected minor water leakage near main supply valve B7-02. Requires seal tightening and pipe joint replacement.',
      reportedBy: 'Facility Operations Team',
      reportedDate: '2026-05-05',
      dueDate: '2026-05-07',
      status: ReportStatus.inProgress,
      priority: ReportPriority.urgent,
    ),
    const FaultReport(
      id: 'REP-103',
      title: 'Filter Replacement',
      location: 'Sector C - Building 2',
      description:
          'Scheduled quarterly filtration mesh change for secondary reservoir water intake unit.',
      reportedBy: 'System Administrator',
      reportedDate: '2026-05-04',
      dueDate: '2026-05-06',
      status: ReportStatus.completed,
      priority: ReportPriority.medium,
    ),
    const FaultReport(
      id: 'REP-104',
      title: 'Pressure Valve Check',
      location: 'Sector A - Building 5',
      description:
          'Calibrate pressure relief valve on booster station 3 to maintain baseline psi within safety threshold.',
      reportedBy: 'Quality Assurance Inspector',
      reportedDate: '2026-05-07',
      dueDate: '2026-05-10',
      status: ReportStatus.pending,
      priority: ReportPriority.low,
    ),
  ];

  @override
  List<FaultReport> getReports() {
    return List.unmodifiable(_reports);
  }

  @override
  FaultReport? getReportById(String id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void updateReportStatus(String id, ReportStatus newStatus) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: newStatus);
    }
  }

  @override
  void verifyReport(String id) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: ReportStatus.verified);
    }
  }

  @override
  void addReport(FaultReport report) {
    _reports.insert(0, report);
  }

  @override
  void deleteReport(String id) {
    _reports.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<FaultReport>> fetchReportsFromApi() async {
    try {
      final response = await _apiService.get('/fault-reports/');
      if (response is List) {
        final fetched = response
            .map((item) => FaultReport.fromJson(item as Map<String, dynamic>))
            .toList();
        _reports.clear();
        _reports.addAll(fetched);
        return List.unmodifiable(_reports);
      }
    } catch (_) {
      // Return cached reports on network issue
    }
    return getReports();
  }

  @override
  Future<FaultReport> createReportOnApi(FaultReport report) async {
    final response = await _apiService.post('/fault-reports/', body: report.toJson());
    final created = response is Map<String, dynamic>
        ? FaultReport.fromJson(response)
        : report;
    addReport(created);
    return created;
  }

  @override
  Future<FaultReport?> updateReportStatusOnApi(
    String id,
    ReportStatus newStatus, {
    required String changedBy,
  }) async {
    try {
      final response = await _apiService.patch(
        '/fault-reports/$id/status',
        queryParameters: {'changedBy': changedBy},
        body: {'status': newStatus.label},
      );
      updateReportStatus(id, newStatus);
      if (response is Map<String, dynamic>) {
        return FaultReport.fromJson(response);
      }
    } catch (_) {
      // In offline / in-memory mode fallback to local status update
      updateReportStatus(id, newStatus);
    }
    return getReportById(id);
  }
}

class ApiFaultReportRepository implements FaultReportRepository {
  final ApiService _apiService;
  final List<FaultReport> _cachedReports = [];

  ApiFaultReportRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  ApiService get apiService => _apiService;

  @override
  List<FaultReport> getReports() => List.unmodifiable(_cachedReports);

  @override
  FaultReport? getReportById(String id) {
    try {
      return _cachedReports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void updateReportStatus(String id, ReportStatus newStatus) {
    final index = _cachedReports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cachedReports[index] = _cachedReports[index].copyWith(status: newStatus);
    }
  }

  @override
  void verifyReport(String id) {
    final index = _cachedReports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cachedReports[index] = _cachedReports[index].copyWith(status: ReportStatus.verified);
    }
  }

  @override
  void addReport(FaultReport report) {
    _cachedReports.insert(0, report);
  }

  @override
  void deleteReport(String id) {
    _cachedReports.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<FaultReport>> fetchReportsFromApi() async {
    final response = await _apiService.get('/fault-reports/');
    if (response is List) {
      final fetched = response
          .map((item) => FaultReport.fromJson(item as Map<String, dynamic>))
          .toList();
      _cachedReports.clear();
      _cachedReports.addAll(fetched);
    }
    return List.unmodifiable(_cachedReports);
  }

  @override
  Future<FaultReport> createReportOnApi(FaultReport report) async {
    final response = await _apiService.post('/fault-reports/', body: report.toJson());
    final created = response is Map<String, dynamic>
        ? FaultReport.fromJson(response)
        : report;
    addReport(created);
    return created;
  }

  @override
  Future<FaultReport?> updateReportStatusOnApi(
    String id,
    ReportStatus newStatus, {
    required String changedBy,
  }) async {
    final response = await _apiService.patch(
      '/fault-reports/$id/status',
      queryParameters: {'changedBy': changedBy},
      body: {'status': newStatus.label},
    );
    updateReportStatus(id, newStatus);
    if (response is Map<String, dynamic>) {
      final updated = FaultReport.fromJson(response);
      final idx = _cachedReports.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _cachedReports[idx] = updated;
      }
      return updated;
    }
    return getReportById(id);
  }
}
