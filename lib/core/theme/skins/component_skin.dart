import 'package:flutter/material.dart';

/// Base class for component skins
abstract class ComponentSkin {
  final String name;
  final String displayName;
  
  const ComponentSkin({
    required this.name,
    required this.displayName,
  });
  
  /// Get the primary color for this skin
  Color getPrimaryColor(BuildContext context);
  
  /// Get the secondary color for this skin
  Color getSecondaryColor(BuildContext context);
  
  /// Get the accent color for this skin
  Color getAccentColor(BuildContext context);
  
  /// Get the background color for this skin
  Color getBackgroundColor(BuildContext context);
  
  /// Get the surface color for this skin
  Color getSurfaceColor(BuildContext context);
  
  /// Get the error color for this skin
  Color getErrorColor(BuildContext context);
  
  /// Get the success color for this skin
  Color getSuccessColor(BuildContext context);
  
  /// Get the warning color for this skin
  Color getWarningColor(BuildContext context);
  
  /// Get the info color for this skin
  Color getInfoColor(BuildContext context);
  
  /// Get text colors for this skin
  TextTheme getTextTheme(BuildContext context);
  
  /// Get elevation shadows for this skin
  List<BoxShadow> getElevationShadows(int elevation);
  
  /// Get button style for this skin
  ButtonStyle getButtonStyle(BuildContext context);
  
  /// Get input decoration theme for this skin
  InputDecorationTheme getInputDecorationTheme(BuildContext context);
  
  /// Get card theme for this skin
  CardTheme getCardTheme(BuildContext context);
  
  /// Get app bar theme for this skin
  AppBarTheme getAppBarTheme(BuildContext context);
  
  /// Get bottom navigation bar theme for this skin
  BottomNavigationBarThemeData getBottomNavigationBarTheme(BuildContext context);
  
  /// Get dialog theme for this skin
  DialogTheme getDialogTheme(BuildContext context);
  
  /// Get snackbar theme for this skin
  SnackBarThemeData getSnackBarTheme(BuildContext context);
  
  /// Get chip theme for this skin
  ChipThemeData getChipTheme(BuildContext context);
  
  /// Get floating action button theme for this skin
  FloatingActionButtonThemeData getFloatingActionButtonTheme(BuildContext context);
  
  /// Get icon theme for this skin
  IconThemeData getIconTheme(BuildContext context);
  
  /// Get tooltip theme for this skin
  TooltipThemeData getTooltipTheme(BuildContext context);
  
  /// Get divider theme for this skin
  DividerThemeData getDividerTheme(BuildContext context);
  
  /// Get progress indicator theme for this skin
  ProgressIndicatorThemeData getProgressIndicatorTheme(BuildContext context);
  
  /// Get switch theme for this skin
  SwitchThemeData getSwitchTheme(BuildContext context);
  
  /// Get checkbox theme for this skin
  CheckboxThemeData getCheckboxTheme(BuildContext context);
  
  /// Get radio theme for this skin
  RadioThemeData getRadioTheme(BuildContext context);
  
  /// Get slider theme for this skin
  SliderThemeData getSliderTheme(BuildContext context);
  
  /// Get tab bar theme for this skin
  TabBarTheme getTabBarTheme(BuildContext context);
  
  /// Get drawer theme for this skin
  DrawerThemeData getDrawerTheme(BuildContext context);
  
  /// Get bottom sheet theme for this skin
  BottomSheetThemeData getBottomSheetTheme(BuildContext context);
  
  /// Get popup menu theme for this skin
  PopupMenuThemeData getPopupMenuTheme(BuildContext context);
  
  /// Get banner theme for this skin
  MaterialBannerThemeData getBannerTheme(BuildContext context);
  
  /// Get navigation rail theme for this skin
  NavigationRailThemeData getNavigationRailTheme(BuildContext context);
  
  /// Get time picker theme for this skin
  TimePickerThemeData getTimePickerTheme(BuildContext context);
  
  /// Get date picker theme for this skin
  DatePickerThemeData getDatePickerTheme(BuildContext context);
}

/// Factory for creating component skins
class ComponentSkinFactory {
  static final Map<String, ComponentSkin> _skins = {};
  
  /// Register a skin
  static void registerSkin(ComponentSkin skin) {
    _skins[skin.name] = skin;
  }
  
  /// Get a skin by name
  static ComponentSkin? getSkin(String name) {
    return _skins[name];
  }
  
  /// Get all available skins
  static List<ComponentSkin> getAllSkins() {
    return _skins.values.toList();
  }
  
  /// Get all skin names
  static List<String> getAllSkinNames() {
    return _skins.keys.toList();
  }
  
  /// Check if a skin exists
  static bool hasSkin(String name) {
    return _skins.containsKey(name);
  }
  
  /// Remove a skin
  static void removeSkin(String name) {
    _skins.remove(name);
  }
  
  /// Clear all skins
  static void clearSkins() {
    _skins.clear();
  }
}