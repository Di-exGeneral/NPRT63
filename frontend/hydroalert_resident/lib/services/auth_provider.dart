import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  ResidentModel? _resident;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  ResidentModel? get resident => _resident;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.login(email, password);
      final userData = await _authService.getMe();
      _user = UserModel.fromJson(userData);
      final residentData = await _authService.getMyResidentProfile();
      if (residentData != null) {
        _resident = ResidentModel.fromJson(residentData);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.register(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Register error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _resident = null;
    notifyListeners();
  }

  Future<void> refreshResident() async {
    final residentData = await _authService.getMyResidentProfile();
    if (residentData != null) {
      _resident = ResidentModel.fromJson(residentData);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}