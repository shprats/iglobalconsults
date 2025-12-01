/// Main Entry Point
/// GlobalHealth Connect Mobile App

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GlobalHealthConnectApp(),
    ),
  );
}

class GlobalHealthConnectApp extends StatelessWidget {
  const GlobalHealthConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobalHealth Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Auth Wrapper
/// Shows login screen if not authenticated, otherwise shows home
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = ref.read(authServiceProvider);
    final isLoggedIn = await authService.isLoggedIn();
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Show loading while checking auth state
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // User is logged in
    if (user != null) {
      return const HomeScreen();
    }

    // User is not logged in
    return const LoginScreen();
  }
}
