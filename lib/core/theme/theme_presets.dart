import 'package:flutter/material.dart';

enum ThemePreset {
  notionApple,  // 노션 + 애플 (기본)
  colorfulFun,  // 컬러풀 & 재미있는
  modernDark,   // 모던 다크모드
  pastelSoft,   // 파스텔 & 부드러운
  studyFocus,   // 차분한 학구적
}

class ThemePresetData {
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color errorColor;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final bool isDark;
  final String fontFamily;
  
  const ThemePresetData({
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.isDark,
    this.fontFamily = 'Pretendard',
  });
}

class ThemePresets {
  static const Map<ThemePreset, ThemePresetData> presets = {
    // 노션 + 애플 스타일 (기본)
    ThemePreset.notionApple: ThemePresetData(
      name: 'Notion + Apple',
      description: '깔끔하고 집중하기 좋은 미니멀 디자인',
      primaryColor: Color(0xFF0066CC),  // iOS 블루
      secondaryColor: Color(0xFF5E72E4), // 노션 블루
      accentColor: Color(0xFF2DCE89),   // 성공 그린
      backgroundColor: Color(0xFFFAFAFA), // 거의 흰색
      surfaceColor: Color(0xFFFFFFFF),
      errorColor: Color(0xFFFF3B30),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF1D1D1F),
      onSurface: Color(0xFF1D1D1F),
      isDark: false,
    ),
    
    // 컬러풀 & 재미있는
    ThemePreset.colorfulFun: ThemePresetData(
      name: 'Colorful Fun',
      description: '듀오링고처럼 밝고 재미있는 스타일',
      primaryColor: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFF4ECDC4),
      accentColor: Color(0xFFFFE66D),
      backgroundColor: Color(0xFFF7FFF7),
      surfaceColor: Color(0xFFFFFFFF),
      errorColor: Color(0xFFFF006E),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF2D3436),
      onSurface: Color(0xFF2D3436),
      isDark: false,
    ),
    
    // 모던 다크모드
    ThemePreset.modernDark: ThemePresetData(
      name: 'Modern Dark',
      description: 'Discord처럼 모던한 다크 테마',
      primaryColor: Color(0xFF6C63FF),
      secondaryColor: Color(0xFFFF6584),
      accentColor: Color(0xFF4FD1C5),
      backgroundColor: Color(0xFF1A202C),
      surfaceColor: Color(0xFF2D3748),
      errorColor: Color(0xFFFC8181),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFFE2E8F0),
      onSurface: Color(0xFFE2E8F0),
      isDark: true,
    ),
    
    // 파스텔 & 부드러운
    ThemePreset.pastelSoft: ThemePresetData(
      name: 'Pastel Soft',
      description: '파스텔톤의 부드럽고 편안한 스타일',
      primaryColor: Color(0xFFB794F4),
      secondaryColor: Color(0xFFF687B3),
      accentColor: Color(0xFF4FD1C5),
      backgroundColor: Color(0xFFFAF5FF),
      surfaceColor: Color(0xFFFFFFFF),
      errorColor: Color(0xFFFC8181),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF2D3748),
      onSurface: Color(0xFF2D3748),
      isDark: false,
    ),
    
    // 차분한 학구적
    ThemePreset.studyFocus: ThemePresetData(
      name: 'Study Focus',
      description: '집중력을 높이는 차분한 학구적 스타일',
      primaryColor: Color(0xFF5E72E4),
      secondaryColor: Color(0xFF2DCE89),
      accentColor: Color(0xFFFB6340),
      backgroundColor: Color(0xFFF4F5F7),
      surfaceColor: Color(0xFFFFFFFF),
      errorColor: Color(0xFFF5365C),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF32325D),
      onSurface: Color(0xFF32325D),
      isDark: false,
    ),
  };
  
  static ThemeData generateTheme(ThemePreset preset) {
    final data = presets[preset]!;
    
    return ThemeData(
      useMaterial3: true,
      brightness: data.isDark ? Brightness.dark : Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme(
        brightness: data.isDark ? Brightness.dark : Brightness.light,
        primary: data.primaryColor,
        onPrimary: data.onPrimary,
        secondary: data.secondaryColor,
        onSecondary: data.onSecondary,
        error: data.errorColor,
        onError: Colors.white,
        surface: data.surfaceColor,
        onSurface: data.onSurface,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: data.backgroundColor,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: data.backgroundColor,
        foregroundColor: data.onBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: data.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: data.fontFamily,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: data.surfaceColor,
        elevation: data.isDark ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: data.isDark 
            ? BorderSide.none 
            : BorderSide(color: data.onBackground.withValues(alpha: 0.08)),
        ),
      ),
      
      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: data.surfaceColor,
        indicatorColor: data.primaryColor.withValues(alpha: 0.1),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: data.primaryColor);
          }
          return IconThemeData(color: data.onSurface.withValues(alpha: 0.6));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: data.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: data.onSurface.withOpacity(0.6),
            fontSize: 12,
          );
        }),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: data.primaryColor,
          foregroundColor: data.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: data.primaryColor,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: data.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: data.onBackground.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: data.onBackground.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: data.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: data.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: data.surfaceColor,
        selectedColor: data.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: data.onSurface,
          fontSize: 14,
        ),
        side: BorderSide(color: data.onBackground.withOpacity(0.1)),
      ),
      
      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: null, // Will use surface color from theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: data.onBackground.withOpacity(0.08),
        thickness: 1,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: data.primaryColor,
        linearTrackColor: data.primaryColor.withOpacity(0.2),
      ),
    );
  }
}