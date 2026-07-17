import 'package:flutter/material.dart';
import '../models/fault_report_model.dart';
import 'fault_report_service.dart';

class FaultReportProvider extends ChangeNotifier {
  final FaultReportService _service = FaultReportService();
  List<FaultReportModel> _reports = [];
  FaultReportModel? _selectedReport;
  bool _isLoading = false;
  String? _error;

  List<FaultReportModel> get reports => _reports;
  FaultReportModel? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyReports(String residentID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _reports = await _service.getMyReports(residentID);
    } catch (e) {
      _error = 'Failed to load reports';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReportById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedReport = await _service.getReportById(id);
    } catch (e) {
      _error = 'Failed to load report';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitReport({
    required String residentID,
    required String areaID,
    required String title,
    required String description,
    required String location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final report = await _service.submitReport(
        residentID: residentID,
        areaID: areaID,
        title: title,
        description: description,
        location: location,
      );
      _reports.insert(0, report);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Submit report error: $e');
      _error = 'Failed to submit report: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}