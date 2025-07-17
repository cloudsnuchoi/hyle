import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateStream;
});

// Current User Provider
final currentUserProvider = FutureProvider<AuthUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

class AuthService {
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _authStateController.stream;

  // Initialize auth state listener
  void initializeAuthListener() {
    Amplify.Hub.listen(HubChannel.Auth, (event) {
      switch (event.eventName) {
        case 'SIGNED_IN':
          _authStateController.add(AuthState.authenticated);
          break;
        case 'SIGNED_OUT':
          _authStateController.add(AuthState.unauthenticated);
          break;
        case 'SESSION_EXPIRED':
          _authStateController.add(AuthState.sessionExpired);
          break;
        case 'USER_DELETED':
          _authStateController.add(AuthState.unauthenticated);
          break;
      }
    });

    // Check initial auth state
    _checkAuthState();
  }

  // Check current auth state
  Future<void> _checkAuthState() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        _authStateController.add(AuthState.authenticated);
      } else {
        _authStateController.add(AuthState.unauthenticated);
      }
    } catch (e) {
      _authStateController.add(AuthState.unauthenticated);
    }
  }

  // Sign up with email
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final userAttributes = <CognitoUserAttributeKey, String>{
        CognitoUserAttributeKey.email: email,
        CognitoUserAttributeKey.nickname: nickname,
        CognitoUserAttributeKey.preferredUsername: nickname,
      };

      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
          pluginOptions: CognitoSignUpPluginOptions(),
        ),
      );

      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Confirm sign up
  Future<SignUpResult> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );

      if (result.isSignUpComplete) {
        // Auto sign in after confirmation
        await signInWithEmail(
          email: email,
          password: '', // Password needs to be stored temporarily or re-entered
        );
      }

      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email
  Future<SignInResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (result.isSignedIn) {
        _authStateController.add(AuthState.authenticated);
      }

      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with social provider
  Future<SignInResult> signInWithSocialProvider(AuthProvider provider) async {
    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: provider,
        options: const SignInWithWebUIOptions(
          pluginOptions: CognitoSignInWithWebUIPluginOptions(
            isPreferPrivateSession: true,
          ),
        ),
      );

      if (result.isSignedIn) {
        _authStateController.add(AuthState.authenticated);
      }

      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      _authStateController.add(AuthState.unauthenticated);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get current user
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } on AuthException {
      return null;
    }
  }

  // Get user attributes
  Future<Map<String, String>> getUserAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final Map<String, String> attributeMap = {};
      
      for (final attribute in attributes) {
        attributeMap[attribute.userAttributeKey.key] = attribute.value;
      }
      
      return attributeMap;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user attribute
  Future<UpdateUserAttributeResult> updateUserAttribute({
    required CognitoUserAttributeKey key,
    required String value,
  }) async {
    try {
      final result = await Amplify.Auth.updateUserAttribute(
        userAttributeKey: key,
        value: value,
      );
      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<ResetPasswordResult> resetPassword({
    required String email,
  }) async {
    try {
      final result = await Amplify.Auth.resetPassword(
        username: email,
      );
      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Confirm reset password
  Future<ResetPasswordResult> confirmResetPassword({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Resend confirmation code
  Future<ResendSignUpCodeResult> resendConfirmationCode({
    required String email,
  }) async {
    try {
      final result = await Amplify.Auth.resendSignUpCode(
        username: email,
      );
      return result;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      await Amplify.Auth.deleteUser();
      _authStateController.add(AuthState.unauthenticated);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get ID token
  Future<String?> getIdToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(),
      ) as CognitoAuthSession;
      
      return session.userPoolTokensResult.value.idToken.raw;
    } on AuthException {
      return null;
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(),
      ) as CognitoAuthSession;
      
      return session.userPoolTokensResult.value.accessToken.raw;
    } on AuthException {
      return null;
    }
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } on AuthException {
      return false;
    }
  }

  // Handle auth exceptions
  String _handleAuthException(AuthException e) {
    if (e is UserNotFoundException) {
      return 'User not found. Please check your email.';
    } else if (e is NotAuthorizedServiceException) {
      return 'Incorrect password. Please try again.';
    } else if (e is InvalidPasswordException) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and numbers.';
    } else if (e is CodeMismatchException) {
      return 'Invalid confirmation code. Please try again.';
    } else if (e is ExpiredCodeException) {
      return 'Confirmation code has expired. Please request a new one.';
    } else if (e is LimitExceededException) {
      return 'Too many attempts. Please try again later.';
    } else if (e is UsernameExistsException) {
      return 'An account with this email already exists.';
    } else if (e is InvalidParameterException) {
      return 'Invalid input. Please check your information.';
    } else if (e is NetworkException) {
      return 'Network error. Please check your connection.';
    } else {
      return e.message;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}

// Auth state enum
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  sessionExpired,
}

// Auth exceptions
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}