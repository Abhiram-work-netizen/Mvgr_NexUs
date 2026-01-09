import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_screen.dart';

/// Auth Wrapper - Shows loading, auth screen, or main app based on auth state
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final authService = AuthService.instance;

        // Show loading while checking auth state
        if (authService.isLoading) {
          return _LoadingScreen();
        }

        // Show auth screen if not logged in
        if (!authService.isLoggedIn) {
          return const AuthScreen();
        }

        // Show main app if logged in
        return child;
      },
    );
  }
}

/// Loading Screen
class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hub_rounded,
                size: 72,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'MVGR NEXUS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
