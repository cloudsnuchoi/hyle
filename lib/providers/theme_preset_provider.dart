import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_presets.dart';
import '../services/local_storage_service.dart';

final themePresetProvider = StateNotifierProvider<ThemePresetNotifier, ThemePreset>((ref) {
  return ThemePresetNotifier();
});

class ThemePresetNotifier extends StateNotifier<ThemePreset> {
  ThemePresetNotifier() : super(ThemePreset.notionApple) {
    _loadThemePreset();
  }
  
  static const String _themePresetKey = 'theme_preset';
  
  Future<void> _loadThemePreset() async {
    final presetIndex = LocalStorageService.getInt(_themePresetKey) ?? 0;
    if (presetIndex >= 0 && presetIndex < ThemePreset.values.length) {
      state = ThemePreset.values[presetIndex];
    }
  }
  
  Future<void> setThemePreset(ThemePreset preset) async {
    state = preset;
    await LocalStorageService.setInt(_themePresetKey, preset.index);
  }
  
  ThemePresetData get currentPresetData => ThemePresets.presets[state]!;
}