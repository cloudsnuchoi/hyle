import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/home/screens/home_screen_mobile.dart';
import 'services/local_storage_service.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // LocalStorageService 초기화
  await LocalStorageService.init();
  
  // 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themePreset = ref.watch(themePresetProvider);
    
    return MaterialApp(
      title: 'Hyle - AI Learning Companion',
      theme: AppTheme.lightTheme(preset: themePreset),
      darkTheme: AppTheme.darkTheme(preset: themePreset),
      themeMode: themeMode,
      home: const HomeScreenMobile(),
      debugShowCheckedModeBanner: false,
    );
  }
}