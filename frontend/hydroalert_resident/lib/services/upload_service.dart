import 'package:dio/dio.dart';
import 'api_service.dart';

class UploadService {
  final ApiService _api = ApiService();

  Future<String> uploadPhoto(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _api.post('/upload', data: formData);
    return response.data['url'];
  }
}