import 'package:flutter/material.dart';
import '../models/outage_schedule_model.dart';
import 'outage_service.dart';

class OutageProvider extends ChangeNotifier {
  final OutageService _service = OutageService();
  List<OutageScheduleModel> _outages = [];
  OutageScheduleModel? _selectedOutage;
  bool _isLoading = false;
  String? _error;

  List<OutageScheduleModel> get outages => _outages;
  OutageScheduleModel? get selectedOutage => _selectedOutage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOutages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _outages = await _service.getOutages();
    } catch (e) {
      _error = 'Failed to load outages';
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectOutage(OutageScheduleModel outage) {
    _selectedOutage = outage;
    notifyListeners();
  }
}