import 'package:flutter/material.dart';
import 'component_skin.dart';

/// Timer skin specifically for timer components
abstract class TimerSkin extends ComponentSkin {
  const TimerSkin({
    required super.name,
    required super.displayName,
  });
  
  /// Get the timer background gradient
  Gradient getTimerBackgroundGradient(BuildContext context);
  
  /// Get the timer ring color
  Color getTimerRingColor(BuildContext context);
  
  /// Get the timer progress color
  Color getTimerProgressColor(BuildContext context);
  
  /// Get the timer text color
  Color getTimerTextColor(BuildContext context);
  
  /// Get the timer button color
  Color getTimerButtonColor(BuildContext context);
  
  /// Get the timer icon color
  Color getTimerIconColor(BuildContext context);
  
  /// Get the timer shadow
  List<BoxShadow> getTimerShadow(BuildContext context);
  
  /// Get the timer border
  Border? getTimerBorder(BuildContext context);
  
  /// Get the timer animation curve
  Curve getTimerAnimationCurve();
  
  /// Get the timer animation duration
  Duration getTimerAnimationDuration();
}

/// Default timer skin
class DefaultTimerSkin extends TimerSkin {
  const DefaultTimerSkin() : super(
    name: 'default',
    displayName: 'Classic Timer',
  );
  
  @override
  Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
  
  @override
  Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
  
  @override
  Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }
  
  @override
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }
  
  @override
  Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  @override
  Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }
  
  @override
  Color getSuccessColor(BuildContext context) {
    return const Color(0xFF4CAF50);
  }
  
  @override
  Color getWarningColor(BuildContext context) {
    return const Color(0xFFFF9800);
  }
  
  @override
  Color getInfoColor(BuildContext context) {
    return const Color(0xFF2196F3);
  }
  
  @override
  Gradient getTimerBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
          : [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
    );
  }
  
  @override
  Color getTimerRingColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white24 : Colors.black12;
  }
  
  @override
  Color getTimerProgressColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
  
  @override
  Color getTimerTextColor(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!.color!;
  }
  
  @override
  Color getTimerButtonColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
  
  @override
  Color getTimerIconColor(BuildContext context) {
    return Colors.white;
  }
  
  @override
  List<BoxShadow> getTimerShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black45 : Colors.black12,
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ];
  }
  
  @override
  Border? getTimerBorder(BuildContext context) {
    return null;
  }
  
  @override
  Curve getTimerAnimationCurve() {
    return Curves.easeInOut;
  }
  
  @override
  Duration getTimerAnimationDuration() {
    return const Duration(milliseconds: 300);
  }
  
  // Implement remaining abstract methods with default implementations
  @override
  TextTheme getTextTheme(BuildContext context) => Theme.of(context).textTheme;
  
  @override
  List<BoxShadow> getElevationShadows(int elevation) => [];
  
  @override
  ButtonStyle getButtonStyle(BuildContext context) => ElevatedButton.styleFrom();
  
  @override
  InputDecorationTheme getInputDecorationTheme(BuildContext context) => 
      const InputDecorationTheme();
  
  @override
  CardTheme getCardTheme(BuildContext context) => const CardTheme();
  
  @override
  AppBarTheme getAppBarTheme(BuildContext context) => const AppBarTheme();
  
  @override
  BottomNavigationBarThemeData getBottomNavigationBarTheme(BuildContext context) => 
      const BottomNavigationBarThemeData();
  
  @override
  DialogTheme getDialogTheme(BuildContext context) => const DialogTheme();
  
  @override
  SnackBarThemeData getSnackBarTheme(BuildContext context) => 
      const SnackBarThemeData();
  
  @override
  ChipThemeData getChipTheme(BuildContext context) => const ChipThemeData();
  
  @override
  FloatingActionButtonThemeData getFloatingActionButtonTheme(BuildContext context) => 
      const FloatingActionButtonThemeData();
  
  @override
  IconThemeData getIconTheme(BuildContext context) => const IconThemeData();
  
  @override
  TooltipThemeData getTooltipTheme(BuildContext context) => 
      const TooltipThemeData();
  
  @override
  DividerThemeData getDividerTheme(BuildContext context) => 
      const DividerThemeData();
  
  @override
  ProgressIndicatorThemeData getProgressIndicatorTheme(BuildContext context) => 
      const ProgressIndicatorThemeData();
  
  @override
  SwitchThemeData getSwitchTheme(BuildContext context) => const SwitchThemeData();
  
  @override
  CheckboxThemeData getCheckboxTheme(BuildContext context) => 
      const CheckboxThemeData();
  
  @override
  RadioThemeData getRadioTheme(BuildContext context) => const RadioThemeData();
  
  @override
  SliderThemeData getSliderTheme(BuildContext context) => const SliderThemeData();
  
  @override
  TabBarTheme getTabBarTheme(BuildContext context) => const TabBarTheme();
  
  @override
  DrawerThemeData getDrawerTheme(BuildContext context) => const DrawerThemeData();
  
  @override
  BottomSheetThemeData getBottomSheetTheme(BuildContext context) => 
      const BottomSheetThemeData();
  
  @override
  PopupMenuThemeData getPopupMenuTheme(BuildContext context) => 
      const PopupMenuThemeData();
  
  @override
  MaterialBannerThemeData getBannerTheme(BuildContext context) => 
      const MaterialBannerThemeData();
  
  @override
  NavigationRailThemeData getNavigationRailTheme(BuildContext context) => 
      const NavigationRailThemeData();
  
  @override
  TimePickerThemeData getTimePickerTheme(BuildContext context) => 
      const TimePickerThemeData();
  
  @override
  DatePickerThemeData getDatePickerTheme(BuildContext context) => 
      const DatePickerThemeData();
}

/// Ocean themed timer skin
class OceanTimerSkin extends DefaultTimerSkin {
  const OceanTimerSkin() : super();
  
  @override
  String get name => 'ocean';
  
  @override
  String get displayName => 'Ocean Timer';
  
  @override
  Color getPrimaryColor(BuildContext context) {
    return const Color(0xFF00BCD4);
  }
  
  @override
  Color getSecondaryColor(BuildContext context) {
    return const Color(0xFF0097A7);
  }
  
  @override
  Gradient getTimerBackgroundGradient(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00ACC1), Color(0xFF0097A7)],
    );
  }
  
  @override
  Color getTimerProgressColor(BuildContext context) {
    return const Color(0xFF00E5FF);
  }
}

/// Forest themed timer skin
class ForestTimerSkin extends DefaultTimerSkin {
  const ForestTimerSkin() : super();
  
  @override
  String get name => 'forest';
  
  @override
  String get displayName => 'Forest Timer';
  
  @override
  Color getPrimaryColor(BuildContext context) {
    return const Color(0xFF4CAF50);
  }
  
  @override
  Color getSecondaryColor(BuildContext context) {
    return const Color(0xFF388E3C);
  }
  
  @override
  Gradient getTimerBackgroundGradient(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    );
  }
  
  @override
  Color getTimerProgressColor(BuildContext context) {
    return const Color(0xFF69F0AE);
  }
}

/// Sunset themed timer skin
class SunsetTimerSkin extends DefaultTimerSkin {
  const SunsetTimerSkin() : super();
  
  @override
  String get name => 'sunset';
  
  @override
  String get displayName => 'Sunset Timer';
  
  @override
  Color getPrimaryColor(BuildContext context) {
    return const Color(0xFFFF9800);
  }
  
  @override
  Color getSecondaryColor(BuildContext context) {
    return const Color(0xFFF57C00);
  }
  
  @override
  Gradient getTimerBackgroundGradient(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
    );
  }
  
  @override
  Color getTimerProgressColor(BuildContext context) {
    return const Color(0xFFFFD54F);
  }
}

/// Midnight themed timer skin
class MidnightTimerSkin extends DefaultTimerSkin {
  const MidnightTimerSkin() : super();
  
  @override
  String get name => 'midnight';
  
  @override
  String get displayName => 'Midnight Timer';
  
  @override
  Color getPrimaryColor(BuildContext context) {
    return const Color(0xFF9C27B0);
  }
  
  @override
  Color getSecondaryColor(BuildContext context) {
    return const Color(0xFF7B1FA2);
  }
  
  @override
  Gradient getTimerBackgroundGradient(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
    );
  }
  
  @override
  Color getTimerProgressColor(BuildContext context) {
    return const Color(0xFFE040FB);
  }
}

/// Register all timer skins
void registerTimerSkins() {
  ComponentSkinFactory.registerSkin(const DefaultTimerSkin());
  ComponentSkinFactory.registerSkin(const OceanTimerSkin());
  ComponentSkinFactory.registerSkin(const ForestTimerSkin());
  ComponentSkinFactory.registerSkin(const SunsetTimerSkin());
  ComponentSkinFactory.registerSkin(const MidnightTimerSkin());
}