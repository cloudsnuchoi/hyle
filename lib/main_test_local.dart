import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/home/screens/home_screen_minimal.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'services/web_notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // LocalStorageService 초기화
  await LocalStorageService.init();
  
  // 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);
  
  // Notification Service 초기화
  await NotificationService().initialize();
  
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
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'Hyle - AI Learning Companion',
      theme: AppTheme.lightTheme(preset: themePreset),
      darkTheme: AppTheme.darkTheme(preset: themePreset),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      home: const HomeScreenMinimal(),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: WebNotificationService.scaffoldMessengerKey,
    );
  }
}