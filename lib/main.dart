import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'services/amplify_service.dart';
import 'services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting
  await initializeDateFormatting('ko_KR', null);
  
  // Initialize LocalStorageService first
  await LocalStorageService.init();
  
  try {
    await AmplifyService().configureAmplify();
  } catch (e) {
    print('Amplify configuration error: $e');
  }
  
  runApp(const ProviderScope(child: HyleApp()));
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