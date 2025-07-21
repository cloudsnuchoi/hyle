import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

// amplify_outputs.json 내용을 문자열로 포함
import '../amplify_outputs.dart';

class AmplifyService {
  static final AmplifyService _instance = AmplifyService._internal();
  factory AmplifyService() => _instance;
  AmplifyService._internal();

  bool _isConfigured = false;

  Future<void> configureAmplify() async {
    if (_isConfigured) return;

    try {
      // Amplify 플러그인 추가
      final auth = AmplifyAuthCognito();
      final api = AmplifyAPI();
      final storage = AmplifyStorageS3();

      await Amplify.addPlugins([auth, api, storage]);

      // amplify_outputs.json 설정 적용
      await Amplify.configure(amplifyConfig);

      _isConfigured = true;
      debugPrint('Successfully configured Amplify');
    } on AmplifyAlreadyConfiguredException {
      debugPrint('Amplify was already configured. Skipping configuration.');
    } catch (e) {
      debugPrint('Error configuring Amplify: $e');
      rethrow;
    }
  }

  // 인증 관련 메서드들
  Future<bool> isUserSignedIn() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      return result.isSignedIn;
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      return false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.email: email,
        AuthUserAttributeKey.preferredUsername: name,
      };

      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      debugPrint('Error confirming sign up: $e');
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.userId;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<Map<String, String>> getUserAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      return Map.fromEntries(
        attributes.map((attr) => MapEntry(attr.userAttributeKey.key, attr.value)),
      );
    } catch (e) {
      debugPrint('Error fetching user attributes: $e');
      return {};
    }
  }
}