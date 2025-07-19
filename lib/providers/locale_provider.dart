import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  LocaleNotifier() : super(const Locale('ko')) {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'ko';
    state = Locale(localeCode);
  }
  
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
  
  void toggleLocale() {
    setLocale(state.languageCode == 'ko' ? const Locale('en') : const Locale('ko'));
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Helper to get current locale display name
final currentLocaleNameProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'ko' ? '한국어' : 'English';
});