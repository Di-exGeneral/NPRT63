import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this.api) {
    api.onUnauthorized = () => logout(message: 'Your session has expired.');
  }

  static const _tokenKey = 'auth_token';
  final ApiService api;

  AdminUser? currentUser;
  bool isLoading = false;
  bool isRestoring = true;
  String? error;

  bool get isAuthenticated => currentUser != null && api.token != null;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      api.token = token;
      try {
        final user = await api.getMe();
        if (user.role == Constants.adminRole) {
          currentUser = user;
        } else {
          await _clear();
        }
      } catch (_) {
        await _clear();
      }
    }
    isRestoring = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await api.login(email.trim(), password);
      if (result.role != Constants.adminRole) {
        error = 'This portal is for municipal administrators only.';
        return false;
      }
      api.token = result.token;
      currentUser = await api.getMe();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token);
      return true;
    } catch (e) {
      api.token = null;
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout({String? message}) async {
    await _clear();
    error = message;
    notifyListeners();
  }

  Future<void> _clear() async {
    api.token = null;
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

/// Holds all data shown in the admin portal and the actions that change it.
class AdminProvider extends ChangeNotifier {
  AdminProvider(this.api);

  final ApiService api;

  DashboardSummary? summary;
  List<Area> areas = [];
  List<OutageSchedule> schedules = [];
  List<FaultReport> reports = [];
  List<MaintenanceTeam> teams = [];
  List<EmergencyAlert> alerts = [];
  bool isLoading = false;
  String? error;

  Area? areaById(String id) {
    for (final a in areas) {
      if (a.areaID == id) return a;
    }
    return null;
  }

  String areaName(String id) => areaById(id)?.label ?? id;

  MaintenanceTeam? teamById(String id) {
    for (final t in teams) {
      if (t.teamID == id) return t;
    }
    return null;
  }

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        api.getSummary(),
        api.getAreas(),
        api.getSchedules(),
        api.getReports(),
        api.getTeams(),
        api.getAlerts(),
      ]);
      summary = results[0] as DashboardSummary;
      areas = results[1] as List<Area>;
      schedules = results[2] as List<OutageSchedule>;
      reports = results[3] as List<FaultReport>;
      teams = results[4] as List<MaintenanceTeam>;
      alerts = results[5] as List<EmergencyAlert>;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refresh() async {
    try {
      final results = await Future.wait([
        api.getSummary(),
        api.getSchedules(),
        api.getReports(),
        api.getTeams(),
      ]);
      summary = results[0] as DashboardSummary;
      schedules = results[1] as List<OutageSchedule>;
      reports = results[2] as List<FaultReport>;
      teams = results[3] as List<MaintenanceTeam>;
    } catch (_) {
      // Keep the current data; the next full reload will surface errors.
    }
    notifyListeners();
  }

  Future<void> saveArea({
    String? existingId,
    required String areaID,
    required String suburb,
    required String municipality,
  }) async {
    if (existingId == null) {
      await api.createArea(areaID, suburb, municipality);
    } else {
      await api.updateArea(existingId, suburb, municipality);
    }
    areas = await api.getAreas();
    await _refresh();
  }

  Future<void> createSchedule({
    required String areaID,
    required DateTime start,
    required DateTime end,
    required String createdBy,
    String? description,
  }) async {
    await api.createSchedule(
      areaID: areaID,
      start: start,
      end: end,
      createdBy: createdBy,
      description: description,
    );
    await _refresh();
  }

  Future<void> updateSchedule(
    String scheduleID, {
    required String areaID,
    required DateTime start,
    required DateTime end,
    String? description,
  }) async {
    await api.updateSchedule(
      scheduleID,
      areaID: areaID,
      start: start,
      end: end,
      description: description,
    );
    await _refresh();
  }

  Future<void> setScheduleStatus(String scheduleID, String status) async {
    await api.setScheduleStatus(scheduleID, status);
    await _refresh();
  }

  Future<void> deleteSchedule(String scheduleID) async {
    await api.deleteSchedule(scheduleID);
    await _refresh();
  }

  Future<void> updateReportStatus(
    String reportID,
    String status,
    String changedBy,
  ) async {
    await api.updateReportStatus(reportID, status, changedBy);
    await _refresh();
  }

  Future<void> assignTeam(String reportID, String teamID) async {
    await api.assignTeam(reportID, teamID);
    await _refresh();
  }

  Future<EmergencyAlert> sendAlert({
    required String areaID,
    required String alertType,
    required String message,
    String? estimatedDuration,
    required List<String> channels,
  }) async {
    final alert = await api.sendAlert(
      areaID: areaID,
      alertType: alertType,
      message: message,
      estimatedDuration: estimatedDuration,
      channels: channels,
    );
    alerts = [alert, ...alerts];
    await _refresh();
    return alert;
  }
}
