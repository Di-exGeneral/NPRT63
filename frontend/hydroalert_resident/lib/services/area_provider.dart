import 'package:flutter/material.dart';
import '../models/area_model.dart';
import 'area_service.dart';

class AreaProvider extends ChangeNotifier {
  final AreaService _service = AreaService();
  List<AreaModel> _areas = [];
  AreaModel? _selectedArea;
  bool _isLoading = false;
  String? _error;

  List<AreaModel> get areas => _areas;
  AreaModel? get selectedArea => _selectedArea;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAreas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _areas = await _service.getAreas();
    } catch (e) {
      _error = 'Failed to load areas';
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectArea(AreaModel area) {
    _selectedArea = area;
    notifyListeners();
  }
}