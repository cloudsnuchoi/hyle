import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6B46C1);
  static const Color primaryLight = Color(0xFF9F7AEA);
  static const Color primaryDark = Color(0xFF553C9A);
  
  static const Color secondary = Color(0xFF38B2AC);
  static const Color secondaryLight = Color(0xFF4FD1C5);
  static const Color secondaryDark = Color(0xFF319795);
  
  static const Color accent = Color(0xFFED8936);
  static const Color accentLight = Color(0xFFF6AD55);
  static const Color accentDark = Color(0xFFDD6B20);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF1F2937);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  static const Color textDisabledDark = Color(0xFF4B5563);
  
  // Special Colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);
  
  static const Color overlay = Color(0x1A000000);
  static const Color overlayDark = Color(0x1AFFFFFF);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryDark],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accentDark],
  );
  
  // Theme-specific color getters
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryLight
        : primary;
  }
  
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimary;
  }
  
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
  
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }
}

// Theme Presets
class ThemePreset {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color? background;
  final Color? surface;
  final double? borderRadius;
  final String? fontFamily;
  final double? elevation;
  final bool? useShadows;
  
  const ThemePreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.background,
    this.surface,
    this.borderRadius,
    this.fontFamily,
    this.elevation,
    this.useShadows,
  });
}

class ThemePresets {
  // 노션 + 애플 스타일 (기본)
  static const ThemePreset notionApple = ThemePreset(
    name: 'Notion + Apple',
    primary: Color(0xFF0066CC),  // iOS 블루
    secondary: Color(0xFF5E72E4), // 노션 블루
    accent: Color(0xFF2DCE89),   // 성공 그린
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    borderRadius: 8.0,
    fontFamily: 'SF Pro Display',
    elevation: 0,
    useShadows: false,
  );
  
  // 컬러풀 & 재미있는
  static const ThemePreset colorfulFun = ThemePreset(
    name: 'Colorful Fun',
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFF4ECDC4),
    accent: Color(0xFFFFE66D),
    background: Color(0xFFF7FFF7),
    surface: Color(0xFFFFFFFF),
    borderRadius: 20.0,
    fontFamily: 'Poppins',
    elevation: 4,
    useShadows: true,
  );
  
  // 차분한 학구적
  static const ThemePreset studyFocus = ThemePreset(
    name: 'Study Focus',
    primary: Color(0xFF5E72E4),
    secondary: Color(0xFF2DCE89),
    accent: Color(0xFFFB6340),
    background: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    borderRadius: 12.0,
    fontFamily: 'Inter',
    elevation: 1,
    useShadows: true,
  );
  
  // 모던 다크
  static const ThemePreset modernDark = ThemePreset(
    name: 'Modern Dark',
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFFFF6584),
    accent: Color(0xFF4FD1C5),
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    borderRadius: 16.0,
    fontFamily: 'Roboto',
    elevation: 0,
    useShadows: false,
  );
  
  // 파스텔 소프트
  static const ThemePreset pastelSoft = ThemePreset(
    name: 'Pastel Soft',
    primary: Color(0xFFB794F4),
    secondary: Color(0xFFF687B3),
    accent: Color(0xFF4FD1C5),
    background: Color(0xFFFAF5FF),
    surface: Color(0xFFFFFFFF),
    borderRadius: 24.0,
    fontFamily: 'Quicksand',
    elevation: 2,
    useShadows: true,
  );
  
  // 기존 테마들도 유지 (호환성)
  static const ThemePreset purple = ThemePreset(
    name: 'Purple',
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
  );
  
  static const ThemePreset blue = ThemePreset(
    name: 'Blue',
    primary: Color(0xFF3B82F6),
    secondary: Color(0xFF10B981),
    accent: Color(0xFFF59E0B),
  );
  
  static const ThemePreset green = ThemePreset(
    name: 'Green',
    primary: Color(0xFF10B981),
    secondary: Color(0xFF3B82F6),
    accent: Color(0xFFEF4444),
  );
  
  static const ThemePreset pink = ThemePreset(
    name: 'Pink',
    primary: Color(0xFFEC4899),
    secondary: Color(0xFF8B5CF6),
    accent: Color(0xFFF59E0B),
  );
  
  static const List<ThemePreset> all = [
    notionApple,
    colorfulFun,
    studyFocus,
    modernDark,
    pastelSoft,
    purple,
    blue,
    green,
    pink,
  ];
}