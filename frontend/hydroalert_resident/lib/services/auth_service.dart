import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.write(key: 'token', value: response.data['access_token']);
    await _storage.write(key: 'role', value: response.data['role']);
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      print('Register error: ${e.response?.statusCode}');
      print('Register error body: ${e.response?.data}');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<Map<String, dynamic>> getMe() async {
    final token = await _storage.read(key: 'token');
    final response = await _dio.get(
      '/users/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>?> getMyResidentProfile() async {
    try {
      final token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '/users/me/resident',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

}