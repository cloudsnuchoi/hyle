import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_model.dart';

final authStateProvider = ChangeNotifierProvider<AuthState>((ref) {
  return AuthState();
});

class AuthState extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  
  AuthState() {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      // TODO: Implement Supabase auth check when initialized
      // final supabase = sb.Supabase.instance.client;
      // final session = supabase.auth.currentSession;
      // if (session != null) {
      //   final user = supabase.auth.currentUser;
      //   if (user != null) {
      //     _user = User(
      //       id: user.id,
      //       email: user.email ?? '',
      //       name: user.userMetadata?['name'] ?? 'User',
      //     );
      //   }
      // }
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // TODO: Implement Supabase sign in
      // final supabase = sb.Supabase.instance.client;
      // final response = await supabase.auth.signInWithPassword(
      //   email: email,
      //   password: password,
      // );
      
      // For now, use mock authentication
      _user = User(
        id: 'mock-user-id',
        email: email,
        name: 'Test User',
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // TODO: Implement Supabase sign up
      // final supabase = sb.Supabase.instance.client;
      // final response = await supabase.auth.signUp(
      //   email: email,
      //   password: password,
      //   data: {'name': name},
      // );
      
      // For now, use mock authentication
      _user = User(
        id: 'mock-user-id',
        email: email,
        name: name,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    try {
      // TODO: Implement Supabase sign out
      // final supabase = sb.Supabase.instance.client;
      // await supabase.auth.signOut();
      
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }
  
  Future<bool> confirmSignUp(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // TODO: Implement Supabase email confirmation
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      // TODO: Implement Supabase password reset
      // final supabase = sb.Supabase.instance.client;
      // await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}