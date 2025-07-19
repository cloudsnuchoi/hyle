import 'package:flutter/material.dart';

class AppSpacing {
  // Base unit
  static const double unit = 8.0;
  
  // Spacing values
  static const double xxs = unit * 0.25; // 2
  static const double xs = unit * 0.5;   // 4
  static const double sm = unit * 1;     // 8
  static const double md = unit * 2;     // 16
  static const double lg = unit * 3;     // 24
  static const double xl = unit * 4;     // 32
  static const double xxl = unit * 5;    // 40
  static const double xxxl = unit * 6;   // 48
  static const double xxxxl = unit * 8;  // 64
  
  // Padding helpers
  static const EdgeInsets paddingAllXxs = EdgeInsets.all(xxs);
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXxl = EdgeInsets.all(xxl);
  
  // Legacy names for compatibility
  static const EdgeInsets paddingXS = paddingAllXs;
  static const EdgeInsets paddingSM = paddingAllSm;
  static const EdgeInsets paddingMD = paddingAllMd;
  static const EdgeInsets paddingLG = paddingAllLg;
  static const EdgeInsets paddingXL = paddingAllXl;
  
  // Horizontal padding
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);
  
  // Vertical padding
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);
  
  // Common padding combinations
  static const EdgeInsets paddingPageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingPageVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingPage = EdgeInsets.all(md);
  
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingButtonLarge = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  
  static const EdgeInsets paddingListItem = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingListItemLarge = EdgeInsets.symmetric(horizontal: md, vertical: md);
  
  // SizedBox helpers
  static const SizedBox spaceXxs = SizedBox(width: xxs, height: xxs);
  static const SizedBox spaceXs = SizedBox(width: xs, height: xs);
  static const SizedBox spaceSm = SizedBox(width: sm, height: sm);
  static const SizedBox spaceMd = SizedBox(width: md, height: md);
  static const SizedBox spaceLg = SizedBox(width: lg, height: lg);
  static const SizedBox spaceXl = SizedBox(width: xl, height: xl);
  static const SizedBox spaceXxl = SizedBox(width: xxl, height: xxl);
  
  // Horizontal space
  static const SizedBox horizontalXxs = SizedBox(width: xxs);
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);
  
  // Legacy names for compatibility
  static const SizedBox horizontalGapMD = horizontalMd;
  static const SizedBox horizontalGapLG = horizontalLg;
  
  // Vertical space
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  
  // Legacy names for compatibility
  static const SizedBox verticalGapXS = verticalXs;
  static const SizedBox verticalGapSM = verticalSm;
  static const SizedBox verticalGapMD = verticalMd;
  static const SizedBox verticalGapLG = verticalLg;
  static const SizedBox verticalGapXL = verticalXl;
  static const SizedBox horizontalGapSM = horizontalSm;
  
  // Border Radius
  static const double radiusXs = xs;
  static const double radiusSm = sm;
  static const double radiusMd = 12.0;
  static const double radiusLg = md;
  static const double radiusXl = lg;
  static const double radiusXxl = xl;
  static const double radiusFull = 9999.0;
  
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));
  
  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;
  
  // Helper methods
  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    );
  }
  
  static EdgeInsets symmetric({
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }
  
  static SizedBox width(double value) => SizedBox(width: value);
  static SizedBox height(double value) => SizedBox(height: value);
  
  static BorderRadius circular(double radius) {
    return BorderRadius.circular(radius);
  }
}