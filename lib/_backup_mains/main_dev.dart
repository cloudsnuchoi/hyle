import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await initializeDateFormatting('ko_KR', null); // 한국어 날짜 포맷 초기화
  runApp(const ProviderScope(child: HyleApp()));
}

// Simple router - 바로 홈으로 이동
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

class HyleApp extends ConsumerWidget {
  const HyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themePreset = ref.watch(themePresetProvider);
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Hyle Dev',
      theme: AppTheme.lightTheme(preset: themePreset),
      darkTheme: AppTheme.darkTheme(preset: themePreset),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}