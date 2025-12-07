/// Authentication Provider
/// Riverpod provider for authentication state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../notifications/services/notification_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = authNotifierProvider;

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = user;
    } catch (e) {
      state = null;
    }
  }

         Future<bool> login(String email, String password) async {
           try {
             final result = await _authService.login(email: email, password: password);
             state = result['user'] as User;
             
             // Initialize notifications after login
             try {
               final notificationService = NotificationService(ApiClient());
               await notificationService.initialize();
             } catch (e) {
               print('Failed to initialize notifications: $e');
               // Don't fail login if notifications fail
             }
             
             return true;
           } catch (e) {
             return false;
           }
         }

  Future<bool> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      await _authService.register(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );
      // Auto-login after registration
      return await login(email, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}

