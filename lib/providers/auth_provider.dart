import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _loading = true;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        final userData = jsonDecode(userJson);
        _user = User.fromJson(userData);
        
        // Проверяем актуальность токена
        try {
          final currentUser = await _apiService.getCurrentUser();
          _user = currentUser;
          await prefs.setString('user', jsonEncode(currentUser.toJson()));
        } catch (e) {
          await logout();
        }
      }
    } catch (e) {
      await logout();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await _apiService.login(username, password);
      if (result['success']) {
        _user = User.fromJson(result['data']);
        notifyListeners();
        return {'success': true, 'user': _user};
      } else {
        return {'success': false, 'error': result['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка авторизации: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final result = await _apiService.register(userData);
      if (result['success']) {
        return {'success': true, 'data': result['data']};
      } else {
        return {'success': false, 'error': result['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка регистрации: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _user = null;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(updatedUser.toJson()));
    notifyListeners();
  }
}

