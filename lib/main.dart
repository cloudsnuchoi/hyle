import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  await LocalStorageService.init();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found. Running in development mode.');
  }
  
  // Initialize Supabase if credentials are available
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl != null && supabaseAnonKey != null) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
    print('✅ Supabase initialized');
  } else {
    print('⚠️ Running without Supabase (development mode)');
  }
  
  runApp(const ProviderScope(child: HyleApp()));
}

class HyleApp extends ConsumerWidget {
  const HyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if we're in development mode
    final isDevelopment = dotenv.env['SUPABASE_URL'] == null;
    
    return MaterialApp.router(
      title: 'HYLE - AI Learning Assistant',
      debugShowCheckedModeBanner: isDevelopment,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}