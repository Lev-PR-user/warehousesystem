import 'apiservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final ApiService _api = ApiService();
  String? _token;

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> getAuthHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> login(String email, String password) async {
    final response = await _api.post('/user/login', {
      'email': email,
      'hashed_password': password,
    });

    if (response['token'] != null) {
      await saveToken(response['token']);
    }

    return response;
  }

  Future<dynamic> register({
    required String login,
    required String email,
    required String password,
    required String phone,
    String? avatarUrl,
  }) async {
    final data = {
      'login': login,
      'email': email,
      'hashed_password': password,
      'phone': phone,
      'avatar_url': avatarUrl ?? '',
    };

    final response = await _api.post('/user/register', data);

    if (response['token'] != null) {
      await saveToken(response['token']);
    }

    return response;
  }

  Future<dynamic> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await _api.put('/user/update', data);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<dynamic> getUserProfile(String userId) async {
    return await _api.get('/user/profile');
  }
}
