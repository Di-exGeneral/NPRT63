import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock login - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = User(
        id: '1',
        email: email,
        name: 'Admin User',
        phone: '+27712345678',
        role: UserRole.admin,
        municipality: 'Johannesburg',
        createdAt: DateTime.now(),
      );
      _authToken = 'mock_token_12345';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    _error = null;
    notifyListeners();
  }
}

class OutageProvider extends ChangeNotifier {
  final HydroAlertApiService _apiService = HydroAlertApiService();
  
  List<WaterOutage> _outages = [];
  bool _isLoading = false;
  String? _error;

  List<WaterOutage> get outages => _outages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOutages({String? areaId, OutageStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _outages = await _apiService.getWaterOutages(
        areaId: areaId,
        status: status,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOutage({
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
      final newOutage = await _apiService.createWaterOutage(
        area: area,
        areaId: areaId,
        reason: reason,
        scheduledStartTime: scheduledStartTime,
        scheduledEndTime: scheduledEndTime,
        description: description,
        affectedAreas: affectedAreas,
        estimatedAffectedResidents: estimatedAffectedResidents,
      );
      _outages.add(newOutage);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOutage({
    required String id,
    OutageStatus? status,
    String? description,
    DateTime? scheduledEndTime,
  }) async {
    try {
      final updatedOutage = await _apiService.updateWaterOutage(
        id: id,
        status: status,
        description: description,
        scheduledEndTime: scheduledEndTime,
      );
      final index = _outages.indexWhere((o) => o.id == id);
      if (index != -1) {
        _outages[index] = updatedOutage;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

class FaultReportProvider extends ChangeNotifier {
  final HydroAlertApiService _apiService = HydroAlertApiService();
  
  List<FaultReport> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<FaultReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReports({
    ReportStatus? status,
    String? areaId,
    int? priority,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _apiService.getFaultReports(
        status: status,
        areaId: areaId,
        priority: priority,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reviewReport({
    required String id,
    required String reviewNotes,
    required int priority,
  }) async {
    try {
      final updatedReport = await _apiService.reviewFaultReport(
        id: id,
        reviewNotes: reviewNotes,
        priority: priority,
      );
      final index = _reports.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> assignReport({
    required String reportId,
    required String teamId,
  }) async {
    try {
      final updatedReport = await _apiService.assignFaultReport(
        reportId: reportId,
        teamId: teamId,
      );
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resolveReport({
    required String id,
    required String resolutionNotes,
  }) async {
    try {
      final updatedReport = await _apiService.resolveFaultReport(
        id: id,
        resolutionNotes: resolutionNotes,
      );
      final index = _reports.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

class MaintenanceTeamProvider extends ChangeNotifier {
  final HydroAlertApiService _apiService = HydroAlertApiService();
  
  List<MaintenanceTeam> _teams = [];
  bool _isLoading = false;
  String? _error;

  List<MaintenanceTeam> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTeams({String? areaId, TeamStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teams = await _apiService.getMaintenanceTeams(
        areaId: areaId,
        status: status,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

class EmergencyAlertProvider extends ChangeNotifier {
  final HydroAlertApiService _apiService = HydroAlertApiService();
  
  List<EmergencyAlert> _alerts = [];
  bool _isLoading = false;
  String? _error;

  List<EmergencyAlert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAlerts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alerts = await _apiService.getEmergencyAlerts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    required List<String> targetAreas,
    required int estimatedAffectedResidents,
  }) async {
    try {
      final newAlert = await _apiService.sendEmergencyAlert(
        title: title,
        message: message,
        severity: severity,
        targetAreas: targetAreas,
        estimatedAffectedResidents: estimatedAffectedResidents,
      );
      _alerts.add(newAlert);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
