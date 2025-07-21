import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final attributes = await Amplify.Auth.fetchUserAttributes();
        final email = attributes.firstWhere((attr) => attr.userAttributeKey.key == 'email').value;
        final name = attributes.firstWhere(
          (attr) => attr.userAttributeKey.key == 'name',
          orElse: () => const AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.preferredUsername,
            value: 'User',
          ),
        ).value;
        
        // Get user ID from current user
        final currentUser = await Amplify.Auth.getCurrentUser();
        
        // TODO: Fetch full user data from API
        _user = User(
          id: currentUser.userId,
          email: email,
          name: name,
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      
      if (result.isSignedIn) {
        await _checkAuthStatus();
        return true;
      }
      
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
            CognitoUserAttributeKey.preferredUsername: name,
          },
        ),
      );
      
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> confirmSignUp(String email, String confirmationCode) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      
      return result.isSignUpComplete;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
  
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}