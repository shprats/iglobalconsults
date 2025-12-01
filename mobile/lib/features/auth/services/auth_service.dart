/// Authentication Service
/// Handles user authentication (login, register, logout)

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/user.dart';
import '../../../core/config/app_config.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Register a new user
  Future<User> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authBase}/register',
        data: {
          'email': email,
          'password': password,
          'role': role,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.statusCode == 201) {
        // Backend returns user object directly, not wrapped
        final userData = response.data as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      throw Exception('Registration failed');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authBase}/login',
        data: {
          'username': email, // FastAPI OAuth2 uses 'username'
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tokens = {
          'access_token': data['access_token'] as String,
          'refresh_token': data['refresh_token'] as String,
          'token_type': data['token_type'] as String,
        };

        // Store tokens
        await _apiClient.setTokens(
          tokens['access_token']!,
          tokens['refresh_token']!,
        );

        // Get user info
        final userResponse = await _apiClient.get('${AppConfig.authBase}/me');
        final user = User.fromJson(userResponse.data);

        return {
          'user': user,
          'tokens': tokens,
        };
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('${AppConfig.authBase}/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Error: ${error.response?.statusCode}';
    }
    return error.message ?? 'Network error';
  }
}

