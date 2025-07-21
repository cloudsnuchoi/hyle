import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:flutter/material.dart';
import '../../models/ModelProvider.dart';
import '../../amplifyconfiguration.dart';

class AmplifyService {
  static final AmplifyService _instance = AmplifyService._internal();
  factory AmplifyService() => _instance;
  AmplifyService._internal();

  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  // Initialize Amplify
  Future<void> configureAmplify() async {
    if (_isConfigured) {
      return;
    }

    try {
      // Add Amplify plugins
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance)),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
        AmplifyStorageS3(),
        AmplifyAnalyticsPinpoint(),
      ]);

      // Configure Amplify
      await Amplify.configure(amplifyConfig);
      
      _isConfigured = true;
      safePrint('Successfully configured Amplify');
    } on AmplifyAlreadyConfiguredException {
      safePrint('Amplify was already configured');
      _isConfigured = true;
    } catch (e) {
      safePrint('Error configuring Amplify: $e');
      rethrow;
    }
  }

  // Auth Methods
  Future<AuthUser> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } catch (e) {
      safePrint('Error getting current user: $e');
      rethrow;
    }
  }

  Future<bool> isUserSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      safePrint('Error checking sign in status: $e');
      return false;
    }
  }

  Future<SignUpResult> signUp({
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
    } catch (e) {
      safePrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<SignUpResult> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      return result;
    } catch (e) {
      safePrint('Error confirming sign up: $e');
      rethrow;
    }
  }

  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      return result;
    } catch (e) {
      safePrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      safePrint('Error signing out: $e');
      rethrow;
    }
  }

  Future<ResetPasswordResult> resetPassword({required String email}) async {
    try {
      final result = await Amplify.Auth.resetPassword(username: email);
      return result;
    } catch (e) {
      safePrint('Error resetting password: $e');
      rethrow;
    }
  }

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
    } catch (e) {
      safePrint('Error confirming password reset: $e');
      rethrow;
    }
  }

  // Storage Methods
  Future<String> uploadFile({
    required String key,
    required String filePath,
    required String contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final file = AWSFile.fromPath(filePath);
      
      final result = await Amplify.Storage.uploadFile(
        localFile: file,
        path: StoragePath.fromString(key),
        options: StorageUploadFileOptions(
          metadata: metadata ?? {},
        ),
      ).result;

      return key; // Return the key as path is not available in v2
    } catch (e) {
      safePrint('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> getDownloadUrl({required String key}) async {
    try {
      final result = await Amplify.Storage.getUrl(path: StoragePath.fromString(key)).result;
      return result.url.toString();
    } catch (e) {
      safePrint('Error getting download URL: $e');
      rethrow;
    }
  }

  Future<void> deleteFile({required String key}) async {
    try {
      await Amplify.Storage.remove(path: StoragePath.fromString(key)).result;
    } catch (e) {
      safePrint('Error deleting file: $e');
      rethrow;
    }
  }

  // Analytics Methods
  Future<void> recordEvent({
    required String name,
    Map<String, Object>? properties,
  }) async {
    try {
      // For now, just record the event name without properties
      // as the API has changed in v2
      final event = AnalyticsEvent(name);
      await Amplify.Analytics.recordEvent(event: event);
      
      // TODO: Implement custom properties when API documentation is available
      if (properties != null) {
        safePrint('Custom properties not yet implemented in v2: $properties');
      }
    } catch (e) {
      safePrint('Error recording event: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    Map<String, Object>? attributes,
  }) async {
    try {
      // For now, just identify the user without custom properties
      // as the API has changed in v2
      final userProfile = UserProfile();
      
      await Amplify.Analytics.identifyUser(
        userId: userId,
        userProfile: userProfile,
      );
      
      // TODO: Implement custom properties when API documentation is available
      if (attributes != null) {
        safePrint('User attributes not yet implemented in v2: $attributes');
      }
    } catch (e) {
      safePrint('Error updating user profile: $e');
    }
  }

  // Session Management
  Future<void> startSession() async {
    try {
      // Session management is now automatic in Amplify v2
      // Recording a session start event instead
      await recordEvent(name: 'session_start');
    } catch (e) {
      safePrint('Error starting session: $e');
    }
  }

  Future<void> stopSession() async {
    try {
      // Session management is now automatic in Amplify v2
      // Recording a session stop event instead
      await recordEvent(name: 'session_stop');
    } catch (e) {
      safePrint('Error stopping session: $e');
    }
  }

  // DataStore Sync
  Future<void> startDataStoreSync() async {
    try {
      await Amplify.DataStore.start();
    } catch (e) {
      safePrint('Error starting DataStore sync: $e');
    }
  }

  Future<void> stopDataStoreSync() async {
    try {
      await Amplify.DataStore.stop();
    } catch (e) {
      safePrint('Error stopping DataStore sync: $e');
    }
  }

  Future<void> clearDataStore() async {
    try {
      await Amplify.DataStore.clear();
    } catch (e) {
      safePrint('Error clearing DataStore: $e');
    }
  }

  // Hub Events
  StreamSubscription<AuthHubEvent> listenToAuthEvents(
    Function(AuthHubEvent) onEvent,
  ) {
    return Amplify.Hub.listen(
      HubChannel.Auth,
      (event) {
        if (event is AuthHubEvent) {
          onEvent(event);
        }
      },
    );
  }

  StreamSubscription<DataStoreHubEvent> listenToDataStoreEvents(
    Function(DataStoreHubEvent) onEvent,
  ) {
    return Amplify.Hub.listen(
      HubChannel.DataStore,
      (event) {
        if (event is DataStoreHubEvent) {
          onEvent(event);
        }
      },
    );
  }
}


