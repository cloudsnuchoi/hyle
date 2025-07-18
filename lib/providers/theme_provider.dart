import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Theme preset provider
final themePresetProvider = StateNotifierProvider<ThemePresetNotifier, ThemePreset>((ref) {
  return ThemePresetNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeFromPrefs();
  }
  
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeKey);
    
    if (savedThemeMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }
  
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

class ThemePresetNotifier extends StateNotifier<ThemePreset> {
  static const String _presetKey = 'theme_preset';
  
  ThemePresetNotifier() : super(ThemePresets.notionApple) {
    _loadPresetFromPrefs();
  }
  
  Future<void> _loadPresetFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPresetIndex = prefs.getInt(_presetKey) ?? 0;
    
    if (savedPresetIndex >= 0 && savedPresetIndex < ThemePresets.all.length) {
      state = ThemePresets.all[savedPresetIndex];
    }
  }
  
  Future<void> setThemePreset(ThemePreset preset) async {
    if (state == preset) return;
    
    state = preset;
    final prefs = await SharedPreferences.getInstance();
    final index = ThemePresets.all.indexOf(preset);
    if (index != -1) {
      await prefs.setInt(_presetKey, index);
    }
  }
}

// Helper providers
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  
  if (themeMode == ThemeMode.system) {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
        Brightness.dark;
  }
  return themeMode == ThemeMode.dark;
});

// Available theme presets
final availablePresetsProvider = Provider<List<ThemePreset>>((ref) {
  return ThemePresets.all;
});

// Get preset description
String getPresetDescription(ThemePreset preset) {
  switch (preset.name) {
    case 'Notion + Apple':
      return '깔끔하고 집중하기 좋은 미니멀 디자인';
    case 'Colorful Fun':
      return '듀오링고처럼 밝고 재미있는 스타일';
    case 'Study Focus':
      return '집중력을 높이는 차분한 학구적 스타일';
    case 'Modern Dark':
      return 'Discord처럼 모던한 다크 테마';
    case 'Pastel Soft':
      return '파스텔톤의 부드럽고 편안한 스타일';
    default:
      return preset.name;
  }
}

// Get preset preview colors
List<Color> getPresetPreviewColors(ThemePreset preset) {
  return [
    preset.primary,
    preset.secondary,
    preset.accent,
  ];
}