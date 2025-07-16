import 'package:flutter/material.dart';

class AppShadows {
  // Extra Small Shadow
  static const BoxShadow xs = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );
  
  // Small Shadow
  static const BoxShadow sm = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );
  
  // Medium Shadow
  static const BoxShadow md = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -1,
  );
  
  // Large Shadow
  static const BoxShadow lg = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
  );
  
  // Extra Large Shadow
  static const BoxShadow xl = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 20),
    blurRadius: 25,
    spreadRadius: -5,
  );
  
  // 2XL Shadow
  static const BoxShadow xxl = BoxShadow(
    color: Color(0x24000000),
    offset: Offset(0, 25),
    blurRadius: 50,
    spreadRadius: -12,
  );
  
  // Elevation Shadows (Material Design inspired)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 8),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 3),
      blurRadius: 5,
      spreadRadius: 0,
    ),
  ];
  
  // Special Shadows
  static const BoxShadow card = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );
  
  static const BoxShadow button = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );
  
  static const BoxShadow buttonHover = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: -1,
  );
  
  static const BoxShadow dialog = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 10),
    blurRadius: 25,
    spreadRadius: -5,
  );
  
  static const BoxShadow dropdown = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: -2,
  );
  
  // Inner Shadows
  static const BoxShadow innerXs = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: -1,
  );
  
  static const BoxShadow innerSm = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: -2,
  );
  
  // Colored Shadows
  static BoxShadow colored(Color color, {double opacity = 0.2}) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    );
  }
  
  // Helper method to get shadow lists
  static List<BoxShadow> none = const [];
  static List<BoxShadow> xsList = const [xs];
  static List<BoxShadow> smList = const [sm];
  static List<BoxShadow> mdList = const [md];
  static List<BoxShadow> lgList = const [lg];
  static List<BoxShadow> xlList = const [xl];
  static List<BoxShadow> xxlList = const [xxl];
  
  // Dark mode shadows (lighter shadows for dark backgrounds)
  static const BoxShadow xsDark = BoxShadow(
    color: Color(0x1AFFFFFF),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );
  
  static const BoxShadow smDark = BoxShadow(
    color: Color(0x1FFFFFFF),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );
  
  static const BoxShadow mdDark = BoxShadow(
    color: Color(0x24FFFFFF),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -1,
  );
}