import 'package:dio/dio.dart';
import '../models/fault_report_model.dart';
import 'api_service.dart';
import 'dart:math';

class FaultReportService {
  final ApiService _api = ApiService();

  Future<List<FaultReportModel>> getMyReports(String residentID) async {
    final response = await _api.get('/fault-reports/resident/$residentID');
    return (response.data as List)
        .map((e) => FaultReportModel.fromJson(e))
        .toList();
  }

  Future<FaultReportModel> getReportById(String id) async {
    final response = await _api.get('/fault-reports/$id');
    return FaultReportModel.fromJson(response.data);
  }

  Future<FaultReportModel> submitReport({
    required String residentID,
    required String areaID,
    required String title,
    required String description,
    required String location,
  }) async {
    final response = await _api.post('/fault-reports/', data: {
      'reportID': _generateID(),
      'residentID': residentID,
      'areaID': areaID,
      'title': title,
      'description': description,
      'location': location,
    });
    return FaultReportModel.fromJson(response.data);
  }

  String _generateID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(36, (i) {
      if (i == 8 || i == 13 || i == 18 || i == 23) return '-';
      return chars[rand.nextInt(chars.length)];
    }).join();
  }
}