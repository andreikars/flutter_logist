import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/declaration.dart';
import '../models/payment.dart';
import '../models/vehicle.dart';
import '../models/activity.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://10.0.2.2:8080/api';

  // Получаем базовый URL из настроек или используем значение по умолчанию
  Future<String> get apiBaseUrl async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('backend_ip');
    if (savedIp != null && savedIp.isNotEmpty) {
      // Если IP указан без http://, добавляем его
      String ip = savedIp.trim();
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      // Если порт не указан, добавляем :8080
      if (!ip.contains(':')) {
        ip = '$ip:8080';
      }
      // Добавляем /api если его нет
      if (!ip.endsWith('/api')) {
        ip = '$ip/api';
      }
      return ip;
    }
    return defaultBaseUrl;
  }

  // Обновляет базовый URL
  Future<void> updateBaseUrl(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_ip', ip.trim());
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    }
    return response;
  }

  // Auth API
  Future<Map<String, dynamic>> login(String username, String password) async {
    final baseUrl = await apiBaseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['accessToken']);
      final userData = Map<String, dynamic>.from(responseData);
      userData.remove('accessToken');
      await prefs.setString('user', jsonEncode(userData));
      return {'success': true, 'data': userData};
    } else {
      return {
        'success': false,
        'error': responseData['error'] ?? 'Ошибка авторизации',
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final baseUrl = await apiBaseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'error': responseData['error'] ?? 'Ошибка регистрации',
      };
    }
  }

  // User API
  Future<User> getCurrentUser() async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get current user');
  }

  Future<List<User>> getAllUsers() async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to get users');
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: headers,
      body: jsonEncode(userData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create user');
  }

  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
      body: jsonEncode(userData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update user');
  }

  Future<void> deleteUser(int id) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // Declaration API
  Future<List<Declaration>> getAllDeclarations() async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/declarations'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Declaration.fromJson(json)).toList();
    }
    throw Exception('Failed to get declarations');
  }

  Future<List<Declaration>> getDeclarationsByClient(int clientId) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/declarations/client/$clientId'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Declaration.fromJson(json)).toList();
    }
    throw Exception('Failed to get declarations');
  }

  Future<Declaration> createDeclaration(Map<String, dynamic> declarationData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/declarations'),
      headers: headers,
      body: jsonEncode(declarationData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Declaration.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create declaration');
  }

  Future<Declaration> updateDeclaration(int id, Map<String, dynamic> declarationData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/declarations/$id'),
      headers: headers,
      body: jsonEncode(declarationData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      return Declaration.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update declaration');
  }

  Future<void> deleteDeclaration(int id) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/declarations/$id'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete declaration');
    }
  }

  Future<void> updateDeclarationStatus(int id, String status) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/declarations/$id/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update declaration status');
    }
  }

  // Payment API
  Future<List<Payment>> getAllPayments() async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/payments'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    }
    throw Exception('Failed to get payments');
  }

  Future<List<Payment>> getPaymentsByClient(int clientId) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/payments/client/$clientId'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    }
    throw Exception('Failed to get payments');
  }

  Future<Payment> createPayment(Map<String, dynamic> paymentData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: headers,
      body: jsonEncode(paymentData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Payment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create payment');
  }

  Future<Payment> updatePayment(int id, Map<String, dynamic> paymentData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/payments/$id'),
      headers: headers,
      body: jsonEncode(paymentData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update payment');
  }

  Future<void> deletePayment(int id) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/payments/$id'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete payment');
    }
  }

  Future<void> updatePaymentStatus(int id, String status) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/payments/$id/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update payment status');
    }
  }

  // Vehicle API
  Future<List<Vehicle>> getAllVehicles() async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    }
    throw Exception('Failed to get vehicles');
  }

  Future<List<Vehicle>> getAvailableVehicles() async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/available'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    }
    throw Exception('Failed to get available vehicles');
  }

  Future<List<Vehicle>> getRentedVehiclesByDriver(int driverId) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/driver/$driverId/rented'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    }
    throw Exception('Failed to get rented vehicles');
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles'),
      headers: headers,
      body: jsonEncode(vehicleData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Vehicle.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create vehicle');
  }

  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> vehicleData) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/vehicles/$id'),
      headers: headers,
      body: jsonEncode(vehicleData),
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update vehicle');
  }

  Future<void> deleteVehicle(int id) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/vehicles/$id'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete vehicle');
    }
  }

  Future<void> rentVehicle(int vehicleId, int days) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles/$vehicleId/rent'),
      headers: headers,
      body: jsonEncode({'days': days}),
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to rent vehicle');
    }
  }

  Future<void> returnVehicle(int vehicleId) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles/$vehicleId/return'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to return vehicle');
    }
  }

  // Activity API
  Future<List<Activity>> getRecentActivitiesByUser(int userId, {int limit = 20}) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/activities/user/$userId/recent?limit=$limit'),
      headers: headers,
    );
    await _handleResponse(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Activity.fromJson(json)).toList();
    }
    return []; // Возвращаем пустой список при ошибке
  }

  Future<void> createActivityForUser(String username, String description) async {
    final baseUrl = await apiBaseUrl;
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/activities/user/$username'),
      headers: headers,
      body: jsonEncode({'description': description}),
    );
    await _handleResponse(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create activity');
    }
  }
}

