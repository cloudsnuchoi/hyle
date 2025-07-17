import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'amplifyconfiguration.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await _configureAmplify();
  } catch (e) {
    print('Amplify configuration error: $e');
  }
  
  runApp(const ProviderScope(child: HyleApp()));
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI();
    final storage = AmplifyStorageS3();
    final analytics = AmplifyAnalyticsPinpoint();
    
    await Amplify.addPlugins([auth, api, storage, analytics]);
    await Amplify.configure(amplifyConfig);
    
    print('Successfully configured Amplify');
  } on AmplifyAlreadyConfiguredException {
    print('Amplify was already configured. Skipping configuration.');
  }
}

class HyleApp extends ConsumerWidget {
  const HyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    
    // Apply theme with skin
    final lightTheme = AppTheme.lightTheme();
    final darkTheme = AppTheme.darkTheme();
    
    return MaterialApp.router(
      title: 'Hyle - AI Learning Companion',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}