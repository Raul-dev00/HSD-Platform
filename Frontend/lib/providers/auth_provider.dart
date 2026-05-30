import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/auth_manager.dart';
import '../core/constants.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _initialized = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get initialized => _initialized;

  Future<void> init() async {
    _token = await AuthManager.getToken();
    final userId = await AuthManager.getUserId();
    if (_token != null && userId != null) {
      try {
        final data = await ApiService.get('${AppConstants.users}/$userId');
        _currentUser = User.fromJson(data);
      } catch (_) {
        // Token geçersizse temizle
        await logout();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService.post(
      AppConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
    await _saveAuthData(data);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    int? universityId,
    int? departmentId,
    int? yearLevel,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      if (universityId != null) 'universityId': universityId,
      if (departmentId != null) 'departmentId': departmentId,
      if (yearLevel != null) 'yearLevel': yearLevel,
    };
    final data = await ApiService.post(AppConstants.register, body, auth: false);
    await _saveAuthData(data);
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    _token = data['token'];
    _currentUser = User.fromJson(data['user']);
    await AuthManager.saveToken(_token!);
    await AuthManager.saveUserInfo(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await AuthManager.clear();
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
