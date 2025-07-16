import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Skin type provider
final skinTypeProvider = StateNotifierProvider<SkinTypeNotifier, String>((ref) {
  return SkinTypeNotifier();
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

class SkinTypeNotifier extends StateNotifier<String> {
  static const String _skinKey = 'theme_skin';
  
  SkinTypeNotifier() : super('default') {
    _loadSkinFromPrefs();
  }
  
  Future<void> _loadSkinFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSkin = prefs.getString(_skinKey);
    
    if (savedSkin != null) {
      state = savedSkin;
    }
  }
  
  Future<void> setSkin(String skin) async {
    if (state == skin) return;
    
    state = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skinKey, skin);
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

// Available skins
final availableSkinsProvider = Provider<List<String>>((ref) {
  return [
    'default',
    'ocean',
    'forest',
    'sunset',
    'midnight',
  ];
});

// Skin display names
String getSkinDisplayName(String skin) {
  switch (skin) {
    case 'default':
      return 'Classic';
    case 'ocean':
      return 'Ocean Blue';
    case 'forest':
      return 'Forest Green';
    case 'sunset':
      return 'Sunset Orange';
    case 'midnight':
      return 'Midnight Purple';
    default:
      return skin;
  }
}

// Skin preview colors
List<Color> getSkinPreviewColors(String skin) {
  switch (skin) {
    case 'default':
      return [
        const Color(0xFF2196F3),
        const Color(0xFF1976D2),
        const Color(0xFF0D47A1),
      ];
    case 'ocean':
      return [
        const Color(0xFF00BCD4),
        const Color(0xFF0097A7),
        const Color(0xFF006064),
      ];
    case 'forest':
      return [
        const Color(0xFF4CAF50),
        const Color(0xFF388E3C),
        const Color(0xFF1B5E20),
      ];
    case 'sunset':
      return [
        const Color(0xFFFF9800),
        const Color(0xFFF57C00),
        const Color(0xFFE65100),
      ];
    case 'midnight':
      return [
        const Color(0xFF9C27B0),
        const Color(0xFF7B1FA2),
        const Color(0xFF4A148C),
      ];
    default:
      return [Colors.grey];
  }
}