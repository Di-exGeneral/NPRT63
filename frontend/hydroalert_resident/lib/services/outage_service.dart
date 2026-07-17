import '../models/outage_schedule_model.dart';
import 'api_service.dart';

class OutageService {
  final ApiService _api = ApiService();

  Future<List<OutageScheduleModel>> getOutages() async {
    final response = await _api.get('/outage-schedules');
    return (response.data as List)
        .map((e) => OutageScheduleModel.fromJson(e))
        .toList();
  }

  Future<OutageScheduleModel> getOutageById(int id) async {
    final response = await _api.get('/outage-schedules/$id');
    return OutageScheduleModel.fromJson(response.data);
  }
}