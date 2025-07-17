import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/confirmation_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learning_type/screens/learning_type_test_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authState,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/confirm',
        name: 'confirm',
        builder: (context, state) {
          final email = state.queryParameters['email'] ?? '';
          return ConfirmationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/learning-type-test',
        name: 'learningTypeTest',
        builder: (context, state) => const LearningTypeTestScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isSplash = state.matchedLocation == '/';
      
      // If still loading auth state, stay on splash
      if (authState.isLoading && isSplash) {
        return null;
      }
      
      // If authenticated but no learning type, go to test
      if (isAuth && authState.user?.learningType.isEmpty == true) {
        return '/learning-type-test';
      }
      
      // If authenticated and has learning type, go to home
      if (isAuth && !isLoggingIn && !isSigningUp) {
        return '/home';
      }
      
      // If not authenticated and not on auth pages, go to login
      if (!isAuth && !isLoggingIn && !isSigningUp && !isSplash) {
        return '/login';
      }
      
      return null;
    },
  );
});