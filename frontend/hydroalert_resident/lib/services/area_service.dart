import '../models/area_model.dart';
import 'api_service.dart';

class AreaService {
  final ApiService _api = ApiService();

  Future<List<AreaModel>> getAreas() async {
    final response = await _api.get('/areas');
    return (response.data as List)
        .map((e) => AreaModel.fromJson(e))
        .toList();
  }

  Future<AreaModel> getAreaById(int id) async {
    final response = await _api.get('/areas/$id');
    return AreaModel.fromJson(response.data);
  }
}