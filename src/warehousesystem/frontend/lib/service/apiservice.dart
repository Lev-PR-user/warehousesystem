import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': 'http://localhost:3000',
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print('⚠️ No token found in SharedPreferences');
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';

      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final url = '$baseUrl$endpoint';

      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final url = '$baseUrl$endpoint';

      final response = await _client.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';

      final response = await _client.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }

  void close() {
    _client.close();
  }
}
