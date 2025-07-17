import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:flutter/material.dart';
import '../../models/ModelProvider.dart';

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
        AmplifyAPI(modelProvider: ModelProvider.instance),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
        AmplifyStorageS3(),
        AmplifyAnalyticsPinpoint(),
      ]);

      // Configure Amplify
      await Amplify.configure(amplifyconfig);
      
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

  Future<UpdatePasswordResult> confirmResetPassword({
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

      return result.path;
    } catch (e) {
      safePrint('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> getDownloadUrl({required String key}) async {
    try {
      final result = await Amplify.Storage.getUrl(key: key).result;
      return result.url.toString();
    } catch (e) {
      safePrint('Error getting download URL: $e');
      rethrow;
    }
  }

  Future<void> deleteFile({required String key}) async {
    try {
      await Amplify.Storage.remove(key: key).result;
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
      final event = AnalyticsEvent(name);
      
      if (properties != null) {
        properties.forEach((key, value) {
          if (value is String) {
            event.properties.addStringProperty(key, value);
          } else if (value is int) {
            event.properties.addIntProperty(key, value);
          } else if (value is double) {
            event.properties.addDoubleProperty(key, value);
          } else if (value is bool) {
            event.properties.addBoolProperty(key, value);
          }
        });
      }

      await Amplify.Analytics.recordEvent(event: event);
    } catch (e) {
      safePrint('Error recording event: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    Map<String, Object>? attributes,
  }) async {
    try {
      final userProfile = UserProfile();
      
      if (attributes != null) {
        attributes.forEach((key, value) {
          userProfile.properties.addStringProperty(key, value.toString());
        });
      }

      await Amplify.Analytics.updateUserProfile(
        userProfile: userProfile,
      );
    } catch (e) {
      safePrint('Error updating user profile: $e');
    }
  }

  // Session Management
  Future<void> startSession() async {
    try {
      await Amplify.Analytics.startSession();
    } catch (e) {
      safePrint('Error starting session: $e');
    }
  }

  Future<void> stopSession() async {
    try {
      await Amplify.Analytics.stopSession();
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
  StreamSubscription<HubEvent> listenToAuthEvents(
    Function(AuthHubEvent) onEvent,
  ) {
    return Amplify.Hub.listen(
      HubChannel.Auth,
      (hubEvent) {
        switch (hubEvent.eventName) {
          case 'SIGNED_IN':
            onEvent(AuthHubEvent.signedIn);
            break;
          case 'SIGNED_OUT':
            onEvent(AuthHubEvent.signedOut);
            break;
          case 'SESSION_EXPIRED':
            onEvent(AuthHubEvent.sessionExpired);
            break;
          case 'USER_DELETED':
            onEvent(AuthHubEvent.userDeleted);
            break;
        }
      },
    );
  }

  StreamSubscription<HubEvent> listenToDataStoreEvents(
    Function(DataStoreHubEvent) onEvent,
  ) {
    return Amplify.Hub.listen(
      HubChannel.DataStore,
      (hubEvent) {
        switch (hubEvent.eventName) {
          case 'networkStatus':
            final networkStatus = hubEvent.payload as NetworkStatusEvent?;
            if (networkStatus?.active ?? false) {
              onEvent(DataStoreHubEvent.networkStatusActive);
            } else {
              onEvent(DataStoreHubEvent.networkStatusInactive);
            }
            break;
          case 'syncQueriesStarted':
            onEvent(DataStoreHubEvent.syncQueriesStarted);
            break;
          case 'syncQueriesReady':
            onEvent(DataStoreHubEvent.syncQueriesReady);
            break;
          case 'ready':
            onEvent(DataStoreHubEvent.ready);
            break;
        }
      },
    );
  }
}

// Hub Event Enums
enum AuthHubEvent {
  signedIn,
  signedOut,
  sessionExpired,
  userDeleted,
}

enum DataStoreHubEvent {
  networkStatusActive,
  networkStatusInactive,
  syncQueriesStarted,
  syncQueriesReady,
  ready,
}

// Placeholder for amplifyconfig
const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify/cli",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "YOUR_USER_POOL_ID",
            "AppClientId": "YOUR_APP_CLIENT_ID",
            "Region": "YOUR_REGION"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": [],
            "usernameAttributes": ["EMAIL"],
            "signupAttributes": ["EMAIL", "NICKNAME"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": ["REQUIRES_LOWERCASE", "REQUIRES_UPPERCASE", "REQUIRES_NUMBERS"]
            },
            "mfaConfiguration": "OPTIONAL",
            "mfaTypes": ["SMS_MFA"],
            "verificationMechanisms": ["EMAIL"]
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "hyle": {
          "endpointType": "GraphQL",
          "endpoint": "YOUR_GRAPHQL_ENDPOINT",
          "region": "YOUR_REGION",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "YOUR_S3_BUCKET",
        "region": "YOUR_REGION",
        "defaultAccessLevel": "guest"
      }
    }
  },
  "analytics": {
    "plugins": {
      "awsPinpointAnalyticsPlugin": {
        "pinpointAnalytics": {
          "appId": "YOUR_PINPOINT_APP_ID",
          "region": "YOUR_REGION"
        },
        "pinpointTargeting": {
          "region": "YOUR_REGION"
        }
      }
    }
  }
}
''';