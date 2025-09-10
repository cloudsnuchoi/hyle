# 📚 HYLE 종합 스타일 가이드 v2.1
*최종 업데이트: 2025년 9월 8일*
*Claude Code 최적화 버전 - 즉시 구현 가능한 완전한 가이드*

## 🎯 프로젝트 개요
**HYLE** - AI 기반 개인 맞춤형 학습 동반자 앱
- **비전**: 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로
- **타겟**: 중고등학생, 대학생, 취업 준비생
- **플랫폼**: Flutter (iOS, Android, Web)
- **디자인 철학**: 모던 미니멀리즘 + 차분한 학습 환경

---

## 📦 프로젝트 구조 가이드

### 권장 폴더 구조
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # ColorTokens 정의
│   │   ├── app_spacing.dart     # SpacingTokens 정의
│   │   ├── app_typography.dart  # Typography 정의
│   │   ├── app_radius.dart      # RadiusTokens 정의
│   │   ├── app_elevation.dart   # ElevationTokens 정의
│   │   ├── app_animation.dart   # AnimationTokens 정의
│   │   └── app_theme.dart       # ThemeData 통합
│   └── widgets/
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   └── text_button.dart
│       ├── cards/
│       │   ├── glass_card.dart
│       │   ├── neumorphic_card.dart
│       │   └── gradient_card.dart
│       ├── inputs/
│       │   ├── text_field.dart
│       │   └── search_field.dart
│       └── study/
│           ├── pomodoro_timer.dart
│           ├── flashcard.dart
│           └── mission_card.dart
├── features/
│   ├── home/
│   ├── study/
│   ├── calendar/
│   └── profile/
└── main.dart
```

### Import 템플릿
```dart
// 모든 위젯 파일 상단에 추가
import 'package:flutter/material.dart';
import 'dart:ui' as ui; // ImageFilter, blur 효과용
import 'dart:math' as math; // pi, 수학 계산용

// 테마 관련 imports
import 'package:hyle/core/theme/app_colors.dart';
import 'package:hyle/core/theme/app_spacing.dart';
import 'package:hyle/core/theme/app_typography.dart';
import 'package:hyle/core/theme/app_radius.dart';
import 'package:hyle/core/theme/app_elevation.dart';
import 'package:hyle/core/theme/app_animation.dart';

// 상태 관리 (Riverpod 사용 시)
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

---

## 🎨 디자인 토큰 시스템

### Color Tokens
```dart
class ColorTokens {
  // Primary Palette
  static const primary50 = Color(0xFFF0F3FA);
  static const primary100 = Color(0xFFD5DEEF);
  static const primary200 = Color(0xFFB1C9EF);
  static const primary300 = Color(0xFF8AAEE0);
  static const primary400 = Color(0xFF638ECB);
  static const primary500 = Color(0xFF395886);
  
  // Neutral Palette
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFE5E5E5);
  static const gray300 = Color(0xFFD4D4D4);
  static const gray400 = Color(0xFFA3A3A3);
  static const gray500 = Color(0xFF737373);
  static const gray600 = Color(0xFF525252);
  static const gray700 = Color(0xFF404040);
  static const gray800 = Color(0xFF262626);
  static const gray900 = Color(0xFF171717);
  
  // Semantic Colors
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);
  static const warning = Color(0xFFFFA726);
  static const warningLight = Color(0xFFFFF3E0);
  static const error = Color(0xFFEF5350);
  static const errorLight = Color(0xFFFFEBEE);
  static const info = Color(0xFF29B6F6);
  static const infoLight = Color(0xFFE1F5FE);
  
  // Special Purpose
  static const gold = Color(0xFFFFB300);
  static const silver = Color(0xFF9E9E9E);
  static const bronze = Color(0xFF8D6E63);
}
```

### Spacing Tokens
```dart
class SpacingTokens {
  static const space0 = 0.0;
  static const space1 = 2.0;  // xxs
  static const space2 = 4.0;  // xs
  static const space3 = 8.0;  // sm
  static const space4 = 12.0; // md
  static const space5 = 16.0; // lg
  static const space6 = 20.0; // xl
  static const space7 = 24.0; // 2xl
  static const space8 = 32.0; // 3xl
  static const space9 = 40.0; // 4xl
  static const space10 = 48.0; // 5xl
  static const space11 = 64.0; // 6xl
  static const space12 = 80.0; // 7xl
}
```

### Radius Tokens
```dart
class RadiusTokens {
  static const none = 0.0;
  static const xs = 2.0;
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
  static const pill = 999.0;
}
```

### Elevation Tokens
```dart
class ElevationTokens {
  static const elevation0 = []; // 평면
  static const elevation1 = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  static const elevation2 = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  static const elevation3 = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  static const elevation4 = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
  static const elevation5 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

### Animation Tokens
```dart
class AnimationTokens {
  static const durationInstant = Duration(milliseconds: 100);
  static const durationFast = Duration(milliseconds: 200);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);
  static const durationVerySlow = Duration(milliseconds: 800);
  
  static const curveDefault = Curves.easeInOut;
  static const curveEmphasized = Curves.easeOutCubic;
  static const curveDecelerated = Curves.decelerate;
  static const curveAccelerated = Curves.fastOutSlowIn;
}
```

---

## ✏️ 타이포그래피 시스템

### Font Scale
```dart
class Typography {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.33,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}
```

---

## 🧩 컴포넌트 라이브러리

### 1. Buttons
```dart
// Primary Button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isLoading ? ColorTokens.primary200 : ColorTokens.primary400,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        boxShadow: ElevationTokens.elevation2,
      ),
      child: isLoading 
        ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        : Text(text, style: Typography.labelLarge.copyWith(color: Colors.white)),
    );
  }
}

// Secondary Button
class SecondaryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        border: Border.all(color: ColorTokens.primary300, width: 2),
      ),
    );
  }
}

// Text Button
class TextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      child: Text(
        'Learn More',
        style: Typography.labelLarge.copyWith(
          color: ColorTokens.primary400,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// Icon Button
class IconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: ColorTokens.gray50,
        shape: BoxShape.circle,
        border: Border.all(color: ColorTokens.gray200),
      ),
    );
  }
}

// FAB (Floating Action Button)
class FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: ColorTokens.primary400,
        shape: BoxShape.circle,
        boxShadow: ElevationTokens.elevation3,
      ),
    );
  }
}
```

### 2. Input Fields
```dart
// Text Field
class TextField extends StatelessWidget {
  final bool isFocused;
  final bool hasError;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(
          color: hasError 
            ? ColorTokens.error 
            : isFocused 
              ? ColorTokens.primary400 
              : Colors.transparent,
          width: isFocused || hasError ? 2 : 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: SpacingTokens.space5),
    );
  }
}

// Search Field
class SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ColorTokens.gray100,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
      ),
      padding: EdgeInsets.symmetric(horizontal: SpacingTokens.space5),
      child: Row(
        children: [
          Icon(Icons.search, color: ColorTokens.gray400, size: 20),
          SizedBox(width: SpacingTokens.space3),
          // Input area
        ],
      ),
    );
  }
}

// Text Area
class TextArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      minHeight: 120,
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: Colors.transparent),
      ),
      padding: EdgeInsets.all(SpacingTokens.space5),
    );
  }
}
```

### 3. Selection Controls
```dart
// Checkbox
class Checkbox extends StatelessWidget {
  final bool isChecked;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isChecked ? ColorTokens.primary400 : Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        border: Border.all(
          color: isChecked ? ColorTokens.primary400 : ColorTokens.gray300,
          width: 2,
        ),
      ),
      child: isChecked 
        ? Icon(Icons.check, color: Colors.white, size: 16)
        : null,
    );
  }
}

// Radio Button
class RadioButton extends StatelessWidget {
  final bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? ColorTokens.primary400 : ColorTokens.gray300,
          width: 2,
        ),
      ),
      child: isSelected 
        ? Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ColorTokens.primary400,
                shape: BoxShape.circle,
              ),
            ),
          )
        : null,
    );
  }
}

// Switch
class Switch extends StatelessWidget {
  final bool isOn;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 32,
      decoration: BoxDecoration(
        color: isOn ? ColorTokens.primary400 : ColorTokens.gray300,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
      ),
      padding: EdgeInsets.all(2),
      child: AnimatedAlign(
        duration: AnimationTokens.durationFast,
        curve: AnimationTokens.curveDefault,
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: ElevationTokens.elevation1,
          ),
        ),
      ),
    );
  }
}

// Slider
class Slider extends StatelessWidget {
  final double value; // 0.0 to 1.0
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: ColorTokens.gray200,
        borderRadius: BorderRadius.circular(RadiusTokens.xs),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: ColorTokens.primary400,
            borderRadius: BorderRadius.circular(RadiusTokens.xs),
          ),
        ),
      ),
    );
  }
}
```

### 4. Cards & Containers (Modern Design)
```dart
// Glass Morphism Card - 모던한 글래스 효과
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorTokens.primary300.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.all(SpacingTokens.space6),
          child: child,
        ),
      ),
    );
  }
}

// Neumorphic Card - 부드러운 뉴모피즘 효과
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AnimationTokens.durationFast,
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPressed ? [
          // Inner shadow for pressed state
          BoxShadow(
            color: ColorTokens.primary200.withOpacity(0.5),
            offset: Offset(2, 2),
            blurRadius: 5,
            spreadRadius: -3,
          ),
        ] : [
          // Outer shadows for elevated state
          BoxShadow(
            color: ColorTokens.primary200.withOpacity(0.3),
            offset: Offset(5, 5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: Offset(-5, -5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.all(SpacingTokens.space5),
      child: child,
    );
  }
}

// Gradient Card - 그라디언트 배경
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [
            ColorTokens.primary200.withOpacity(0.8),
            ColorTokens.primary400.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors?.first.withOpacity(0.3) ?? ColorTokens.primary300.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(SpacingTokens.space6),
      child: child,
    );
  }
}

// List Item
class ListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space5,
        vertical: SpacingTokens.space4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: ColorTokens.gray100),
        ),
      ),
    );
  }
}
```

### 5. Navigation
```dart
// Tab Bar
class TabBar extends StatelessWidget {
  final int selectedIndex;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          // Tab items with animated container for selection
        ],
      ),
    );
  }
}

// Bottom Navigation
class BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ElevationTokens.elevation2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Nav items
        ],
      ),
    );
  }
}

// Breadcrumb
class Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      child: Row(
        children: [
          Text('Home', style: Typography.bodyMedium),
          Icon(Icons.chevron_right, size: 16, color: ColorTokens.gray400),
          Text('Category', style: Typography.bodyMedium),
          Icon(Icons.chevron_right, size: 16, color: ColorTokens.gray400),
          Text('Current', style: Typography.bodyMedium.copyWith(
            color: ColorTokens.primary400,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

// Stepper
class Stepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? ColorTokens.primary400 : ColorTokens.gray200,
                borderRadius: BorderRadius.circular(RadiusTokens.xs),
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

### 6. Feedback Components
```dart
// Toast
class Toast extends StatelessWidget {
  final String message;
  final ToastType type;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space5,
        vertical: SpacingTokens.space4,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.gray800,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Text(
        message,
        style: Typography.bodyMedium.copyWith(color: Colors.white),
      ),
    );
  }
}

// Snackbar
class Snackbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SpacingTokens.space5),
      decoration: BoxDecoration(
        color: ColorTokens.gray900,
        boxShadow: ElevationTokens.elevation3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Action completed successfully',
              style: Typography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'UNDO',
              style: Typography.labelLarge.copyWith(color: ColorTokens.primary300),
            ),
          ),
        ],
      ),
    );
  }
}

// Alert Dialog
class AlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: EdgeInsets.all(SpacingTokens.space7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        boxShadow: ElevationTokens.elevation5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Confirm Action', style: Typography.headlineSmall),
          SizedBox(height: SpacingTokens.space5),
          Text(
            'Are you sure you want to proceed?',
            style: Typography.bodyMedium.copyWith(color: ColorTokens.gray600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SpacingTokens.space7),
          Row(
            children: [
              Expanded(child: SecondaryButton()),
              SizedBox(width: SpacingTokens.space4),
              Expanded(child: PrimaryButton()),
            ],
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet
class BottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RadiusTokens.xxl),
          topRight: Radius.circular(RadiusTokens.xxl),
        ),
        boxShadow: ElevationTokens.elevation5,
      ),
      padding: EdgeInsets.all(SpacingTokens.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorTokens.gray300,
              borderRadius: BorderRadius.circular(RadiusTokens.xs),
            ),
          ),
          SizedBox(height: SpacingTokens.space6),
          // Content
        ],
      ),
    );
  }
}
```

### 7. Data Display
```dart
// Badge
class Badge extends StatelessWidget {
  final String text;
  final BadgeType type;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space1,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.primary100,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
      ),
      child: Text(
        text,
        style: Typography.labelSmall.copyWith(color: ColorTokens.primary500),
      ),
    );
  }
}

// Chip
class Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space3,
      ),
      decoration: BoxDecoration(
        color: isSelected ? ColorTokens.primary400 : ColorTokens.gray100,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        border: Border.all(
          color: isSelected ? ColorTokens.primary400 : ColorTokens.gray300,
        ),
      ),
      child: Text(
        label,
        style: Typography.labelMedium.copyWith(
          color: isSelected ? Colors.white : ColorTokens.gray700,
        ),
      ),
    );
  }
}

// Avatar
class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorTokens.primary200,
        shape: BoxShape.circle,
        image: imageUrl != null 
          ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
          : null,
      ),
      child: imageUrl == null 
        ? Center(
            child: Text(
              initials,
              style: Typography.labelLarge.copyWith(color: ColorTokens.primary500),
            ),
          )
        : null,
    );
  }
}

// Progress Bar
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: ColorTokens.gray200,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorTokens.primary300, ColorTokens.primary400],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
        ),
      ),
    );
  }
}

// Circular Progress
class CircularProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorTokens.gray200, width: 8),
            ),
          ),
          // Progress arc
          CustomPaint(
            painter: CircularProgressPainter(
              progress: progress,
              color: ColorTokens.primary400,
            ),
          ),
          // Center text
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: Typography.headlineMedium.copyWith(color: ColorTokens.primary500),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 8. Loading States
```dart
// Skeleton
class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorTokens.gray100,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: AnimatedContainer(
        duration: AnimationTokens.durationVerySlow,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorTokens.gray100,
              ColorTokens.gray200,
              ColorTokens.gray100,
            ],
            stops: [0.4, 0.5, 0.6],
          ),
        ),
      ),
    );
  }
}

// Spinner
class Spinner extends StatelessWidget {
  final double size;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary400),
        strokeWidth: 3,
      ),
    );
  }
}

// Loading Overlay
class LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(RadiusTokens.lg),
            boxShadow: ElevationTokens.elevation3,
          ),
          child: Center(
            child: Spinner(size: 32),
          ),
        ),
      ),
    );
  }
}
```

### 9. Dialogs & Modals
```dart
// Alert Dialog
class AlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryAction;
  final String? secondaryAction;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: EdgeInsets.all(SpacingTokens.space6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        boxShadow: ElevationTokens.elevation4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Typography.titleLarge.copyWith(color: ColorTokens.gray900),
          ),
          SizedBox(height: SpacingTokens.space4),
          Text(
            message,
            style: Typography.bodyMedium.copyWith(color: ColorTokens.gray600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SpacingTokens.space6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (secondaryAction != null) ...[
                TextButton(
                  onPressed: () {},
                  child: Text(secondaryAction!),
                ),
                SizedBox(width: SpacingTokens.space3),
              ],
              PrimaryButton(text: primaryAction),
            ],
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet
class BottomSheet extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RadiusTokens.xxl),
          topRight: Radius.circular(RadiusTokens.xxl),
        ),
        boxShadow: ElevationTokens.elevation4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            margin: EdgeInsets.only(top: SpacingTokens.space4),
            decoration: BoxDecoration(
              color: ColorTokens.gray300,
              borderRadius: BorderRadius.circular(RadiusTokens.xs),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SpacingTokens.space6),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Modal
class Modal extends StatelessWidget {
  final String title;
  final Widget content;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        boxShadow: ElevationTokens.elevation4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(SpacingTokens.space6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ColorTokens.gray100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Typography.titleLarge.copyWith(color: ColorTokens.gray900),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SpacingTokens.space6),
            child: content,
          ),
        ],
      ),
    );
  }
}
```

### 10. Badges & Tags
```dart
// Badge
class Badge extends StatelessWidget {
  final String text;
  final BadgeType type;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
      ),
      child: Text(
        text,
        style: Typography.labelSmall.copyWith(
          color: getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color getBackgroundColor() {
    switch (type) {
      case BadgeType.primary: return ColorTokens.primary100;
      case BadgeType.success: return ColorTokens.successLight;
      case BadgeType.warning: return ColorTokens.warningLight;
      case BadgeType.error: return ColorTokens.errorLight;
      case BadgeType.info: return ColorTokens.infoLight;
      default: return ColorTokens.gray100;
    }
  }
  
  Color getTextColor() {
    switch (type) {
      case BadgeType.primary: return ColorTokens.primary500;
      case BadgeType.success: return ColorTokens.success;
      case BadgeType.warning: return ColorTokens.warning;
      case BadgeType.error: return ColorTokens.error;
      case BadgeType.info: return ColorTokens.info;
      default: return ColorTokens.gray700;
    }
  }
}

// Tag
class Tag extends StatelessWidget {
  final String text;
  final bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space3,
      ),
      decoration: BoxDecoration(
        color: isSelected ? ColorTokens.primary400 : Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(
          color: isSelected ? ColorTokens.primary400 : ColorTokens.gray300,
        ),
      ),
      child: Text(
        text,
        style: Typography.bodySmall.copyWith(
          color: isSelected ? Colors.white : ColorTokens.gray700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Notification Badge
class NotificationBadge extends StatelessWidget {
  final int count;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space2),
      constraints: BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.error,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: Typography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

### 11. Timer & Study Components
```dart
// Modern Pomodoro Timer - 시각적 강조된 타이머
class ModernPomodoroTimer extends StatelessWidget {
  final int minutes;
  final int seconds;
  final bool isRunning;
  final double progress; // 0.0 to 1.0
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Progress Ring
          CustomPaint(
            size: Size(320, 320),
            painter: CircularProgressPainter(
              progress: progress,
              gradient: LinearGradient(
                colors: [
                  ColorTokens.primary300,
                  ColorTokens.primary500,
                ],
              ),
              strokeWidth: 12,
              backgroundColor: ColorTokens.primary100.withOpacity(0.3),
            ),
          ),
          // Glass effect center
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorTokens.primary50.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorTokens.primary300.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: -10,
                  offset: Offset(-10, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated time display
                AnimatedDefaultTextStyle(
                  duration: AnimationTokens.durationFast,
                  style: Typography.displayLarge.copyWith(
                    color: isRunning ? ColorTokens.primary500 : ColorTokens.gray500,
                    fontWeight: FontWeight.w700,
                    fontSize: 64,
                    letterSpacing: 2,
                  ),
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  ),
                ),
                SizedBox(height: SpacingTokens.space4),
                // Status with animation
                AnimatedContainer(
                  duration: AnimationTokens.durationNormal,
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacingTokens.space5,
                    vertical: SpacingTokens.space3,
                  ),
                  decoration: BoxDecoration(
                    color: isRunning 
                      ? ColorTokens.primary400.withOpacity(0.1)
                      : ColorTokens.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  ),
                  child: Text(
                    isRunning ? '집중 시간' : '일시 정지',
                    style: Typography.labelLarge.copyWith(
                      color: isRunning ? ColorTokens.primary500 : ColorTokens.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Study Session Card
class StudySessionCard extends StatelessWidget {
  final String subject;
  final String time;
  final double progress;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        border: Border.all(color: ColorTokens.gray100),
        boxShadow: ElevationTokens.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: Typography.titleMedium.copyWith(color: ColorTokens.gray900),
              ),
              Badge(text: time, type: BadgeType.primary),
            ],
          ),
          SizedBox(height: SpacingTokens.space4),
          ProgressBar(progress: progress),
        ],
      ),
    );
  }
}

// D-Day Counter
class DDayCounter extends StatelessWidget {
  final String title;
  final int daysLeft;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space5,
        vertical: SpacingTokens.space4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorTokens.primary300, ColorTokens.primary400],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Typography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: SpacingTokens.space2),
              Text(
                'D-${daysLeft}',
                style: Typography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }
}
```

### 12. Todo & Task Components
```dart
// Todo Item
class TodoItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final Priority priority;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space4),
      decoration: BoxDecoration(
        color: isCompleted ? ColorTokens.gray50 : Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(
          color: isCompleted ? ColorTokens.gray200 : getPriorityColor(),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) {},
            activeColor: ColorTokens.primary400,
          ),
          SizedBox(width: SpacingTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Typography.bodyLarge.copyWith(
                    color: isCompleted ? ColorTokens.gray500 : ColorTokens.gray900,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: SpacingTokens.space2),
                  Text(
                    subtitle!,
                    style: Typography.bodySmall.copyWith(
                      color: ColorTokens.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: getPriorityColor(),
              borderRadius: BorderRadius.circular(RadiusTokens.xs),
            ),
          ),
        ],
      ),
    );
  }
  
  Color getPriorityColor() {
    switch (priority) {
      case Priority.high: return ColorTokens.error;
      case Priority.medium: return ColorTokens.warning;
      case Priority.low: return ColorTokens.success;
      default: return ColorTokens.gray300;
    }
  }
}

// Task Card
class TaskCard extends StatelessWidget {
  final String title;
  final String category;
  final int subtasks;
  final int completedSubtasks;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        boxShadow: ElevationTokens.elevation2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Badge(text: category, type: BadgeType.primary),
              Text(
                '$completedSubtasks/$subtasks',
                style: Typography.labelMedium.copyWith(color: ColorTokens.gray600),
              ),
            ],
          ),
          SizedBox(height: SpacingTokens.space4),
          Text(
            title,
            style: Typography.titleMedium.copyWith(color: ColorTokens.gray900),
          ),
          SizedBox(height: SpacingTokens.space4),
          ProgressBar(progress: completedSubtasks / subtasks),
        ],
      ),
    );
  }
}
```

### 13. Calendar Components
```dart
// Calendar Day
class CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasEvents;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected 
          ? ColorTokens.primary400 
          : isToday 
            ? ColorTokens.primary100 
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            day.toString(),
            style: Typography.bodyMedium.copyWith(
              color: isSelected 
                ? Colors.white 
                : isToday 
                  ? ColorTokens.primary500 
                  : ColorTokens.gray700,
              fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (hasEvents)
            Positioned(
              bottom: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : ColorTokens.primary400,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Modern Event Card - 컬러 코딩된 이벤트 카드
class ModernEventCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final String subject;
  final bool isCompleted;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacingTokens.space3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(SpacingTokens.space4),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        color: color,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: SpacingTokens.space3),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Typography.bodyMedium.copyWith(
                              color: ColorTokens.gray900,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            ),
                          ),
                          SizedBox(height: SpacingTokens.space1),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: ColorTokens.gray500,
                              ),
                              SizedBox(width: SpacingTokens.space1),
                              Text(
                                time,
                                style: Typography.labelSmall.copyWith(
                                  color: ColorTokens.gray500,
                                ),
                              ),
                              SizedBox(width: SpacingTokens.space3),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SpacingTokens.space2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(RadiusTokens.xs),
                                ),
                                child: Text(
                                  subject,
                                  style: Typography.labelSmall.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Checkbox
                    if (isCompleted != null)
                      Checkbox(
                        value: isCompleted,
                        onChanged: (value) {},
                        activeColor: color,
                        shape: CircleBorder(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case '수학': return Icons.calculate;
      case '영어': return Icons.language;
      case '과학': return Icons.science;
      case '국어': return Icons.menu_book;
      case '운동': return Icons.fitness_center;
      default: return Icons.school;
    }
  }
}
```

### 14. Flashcard Components
```dart
// Modern Flashcard - 스와이프 가능한 대형 카드
class ModernFlashcard extends StatelessWidget {
  final String question;
  final String answer;
  final bool isFlipped;
  final String category;
  final int difficulty; // 1-5
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Flip animation
      child: AnimatedContainer(
        duration: AnimationTokens.durationNormal,
        width: double.infinity,
        height: 400,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(isFlipped ? pi : 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorTokens.primary100,
                ColorTokens.primary300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: ColorTokens.primary400.withOpacity(0.2),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(SpacingTokens.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SpacingTokens.space4,
                            vertical: SpacingTokens.space2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(RadiusTokens.pill),
                          ),
                          child: Text(
                            category,
                            style: Typography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Difficulty stars
                        Row(
                          children: List.generate(5, (index) => Icon(
                            index < difficulty ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          )),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          isFlipped ? answer : question,
                          style: Typography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Swipe hint
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swipe,
                            color: Colors.white.withOpacity(0.5),
                            size: 20,
                          ),
                          SizedBox(width: SpacingTokens.space2),
                          Text(
                            '옆으로 스와이프',
                            style: Typography.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Lesson Card
class LessonCard extends StatelessWidget {
  final String level;
  final String title;
  final int completed;
  final int total;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(color: ColorTokens.gray100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ColorTokens.primary100,
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
            child: Center(
              child: Text(
                level,
                style: Typography.titleMedium.copyWith(
                  color: ColorTokens.primary500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: SpacingTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Typography.bodyLarge.copyWith(color: ColorTokens.gray900),
                ),
                SizedBox(height: SpacingTokens.space2),
                Row(
                  children: [
                    Expanded(
                      child: ProgressBar(progress: completed / total),
                    ),
                    SizedBox(width: SpacingTokens.space3),
                    Text(
                      '$completed/$total Stars',
                      style: Typography.labelSmall.copyWith(color: ColorTokens.gray600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 15. Mission & Quest Components
```dart
// Modern Mission Card - Duolingo 스타일 미션 카드
class ModernMissionCard extends StatelessWidget {
  final String title;
  final String description;
  final int points;
  final String progress;
  final MissionType type;
  final IconData icon;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.all(SpacingTokens.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            getTypeColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: getTypeColor().withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: getTypeColor().withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: getTypeColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getTypeIcon(),
              color: getTypeColor(),
              size: 24,
            ),
          ),
          SizedBox(width: SpacingTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Typography.titleSmall.copyWith(color: ColorTokens.gray900),
                ),
                SizedBox(height: SpacingTokens.space2),
                Text(
                  description,
                  style: Typography.bodySmall.copyWith(color: ColorTokens.gray600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: ColorTokens.gold, size: 16),
                  SizedBox(width: SpacingTokens.space1),
                  Text(
                    '+$points',
                    style: Typography.labelMedium.copyWith(
                      color: ColorTokens.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.space2),
              Text(
                progress,
                style: Typography.labelSmall.copyWith(color: ColorTokens.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color getTypeColor() {
    switch (type) {
      case MissionType.daily: return ColorTokens.primary400;
      case MissionType.weekly: return ColorTokens.success;
      case MissionType.special: return ColorTokens.gold;
      default: return ColorTokens.gray400;
    }
  }
  
  IconData getTypeIcon() {
    switch (type) {
      case MissionType.daily: return Icons.today;
      case MissionType.weekly: return Icons.date_range;
      case MissionType.special: return Icons.emoji_events;
      default: return Icons.flag;
    }
  }
}

// Modern Achievement Badge - 레벨업 애니메이션 효과
class ModernAchievementBadge extends StatelessWidget {
  final String icon;
  final String title;
  final bool isUnlocked;
  final int level;
  final bool isNew;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AnimationTokens.durationNormal,
      width: 100,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              // Badge with glow effect
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked ? RadialGradient(
                    colors: [
                      ColorTokens.gold,
                      ColorTokens.gold.withOpacity(0.6),
                    ],
                  ) : null,
                  color: !isUnlocked ? ColorTokens.gray200 : null,
                  boxShadow: isUnlocked ? [
                    BoxShadow(
                      color: ColorTokens.gold.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: ColorTokens.gold.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ] : [],
                  border: Border.all(
                    color: isUnlocked ? Colors.white : ColorTokens.gray300,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: 40,
                      shadows: isUnlocked ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ] : [],
                    ),
                  ),
                ),
              ),
              SizedBox(height: SpacingTokens.space3),
              // Title with level
              Text(
                title,
                style: Typography.labelMedium.copyWith(
                  color: isUnlocked ? ColorTokens.gray900 : ColorTokens.gray500,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              if (level > 0) ..[
                SizedBox(height: SpacingTokens.space1),
                Text(
                  'Lv.$level',
                  style: Typography.labelSmall.copyWith(
                    color: ColorTokens.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          // NEW badge
          if (isNew && isUnlocked)
            Positioned(
              top: 0,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SpacingTokens.space2,
                  vertical: SpacingTokens.space1,
                ),
                decoration: BoxDecoration(
                  color: ColorTokens.error,
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                ),
                child: Text(
                  'NEW',
                  style: Typography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Level Up Popup - 레벨업 팝업
class LevelUpPopup extends StatelessWidget {
  final int newLevel;
  final String reward;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(SpacingTokens.space8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTokens.gold.withOpacity(0.95),
            ColorTokens.warning,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.gold.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎉',
            style: TextStyle(fontSize: 60),
          ),
          SizedBox(height: SpacingTokens.space4),
          Text(
            'LEVEL UP!',
            style: Typography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: SpacingTokens.space3),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SpacingTokens.space5,
              vertical: SpacingTokens.space3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(RadiusTokens.pill),
            ),
            child: Text(
              'Level $newLevel 달성!',
              style: Typography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: SpacingTokens.space5),
          Text(
            '🎁 $reward',
            style: Typography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎭 상태 디자인 시스템

### Component States
```dart
enum ComponentState {
  idle,       // 기본 상태
  hover,      // 마우스 오버
  pressed,    // 클릭/탭
  focused,    // 포커스
  disabled,   // 비활성화
  loading,    // 로딩 중
  error,      // 에러
  success,    // 성공
}

// State 별 스타일 적용 예시
class StateButton extends StatelessWidget {
  final ComponentState state;
  
  Color getBackgroundColor() {
    switch (state) {
      case ComponentState.idle:
        return ColorTokens.primary400;
      case ComponentState.hover:
        return ColorTokens.primary500;
      case ComponentState.pressed:
        return ColorTokens.primary300;
      case ComponentState.focused:
        return ColorTokens.primary400;
      case ComponentState.disabled:
        return ColorTokens.gray300;
      case ComponentState.loading:
        return ColorTokens.primary200;
      case ComponentState.error:
        return ColorTokens.error;
      case ComponentState.success:
        return ColorTokens.success;
    }
  }
}
```

### Empty States
```dart
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionLabel;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: ColorTokens.gray100,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: SpacingTokens.space7),
          Text(
            title,
            style: Typography.headlineSmall.copyWith(color: ColorTokens.gray800),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SpacingTokens.space4),
          Text(
            description,
            style: Typography.bodyMedium.copyWith(color: ColorTokens.gray600),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null) ...[
            SizedBox(height: SpacingTokens.space7),
            PrimaryButton(text: actionLabel!),
          ],
        ],
      ),
    );
  }
}
```

### Error States
```dart
class ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space6),
      decoration: BoxDecoration(
        color: ColorTokens.errorLight,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(color: ColorTokens.error),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: ColorTokens.error, size: 48),
          SizedBox(height: SpacingTokens.space5),
          Text(
            'Something went wrong',
            style: Typography.titleMedium.copyWith(color: ColorTokens.error),
          ),
          SizedBox(height: SpacingTokens.space3),
          Text(
            errorMessage,
            style: Typography.bodySmall.copyWith(color: ColorTokens.gray700),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: SpacingTokens.space5),
            TextButton(
              onPressed: onRetry,
              child: Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 🎬 인터랙션 & 모션 디자인

### Micro Interactions
```dart
class MicroInteractions {
  // Button Press Animation
  static Widget buttonPress(Widget child) {
    return AnimatedScale(
      scale: 0.95,
      duration: AnimationTokens.durationInstant,
      curve: AnimationTokens.curveDefault,
      child: child,
    );
  }
  
  // Ripple Effect
  static Widget ripple(Widget child) {
    return InkWell(
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      splashColor: ColorTokens.primary100,
      highlightColor: ColorTokens.primary50,
      child: child,
    );
  }
  
  // Hover Elevation
  static Widget hoverElevation(Widget child, bool isHovered) {
    return AnimatedContainer(
      duration: AnimationTokens.durationFast,
      decoration: BoxDecoration(
        boxShadow: isHovered 
          ? ElevationTokens.elevation3 
          : ElevationTokens.elevation1,
      ),
      child: child,
    );
  }
}
```

### Page Transitions
```dart
class PageTransitions {
  // Slide from Right
  static Route slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = AnimationTokens.curveDefault;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: AnimationTokens.durationNormal,
    );
  }
  
  // Fade
  static Route fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: AnimationTokens.durationNormal,
    );
  }
  
  // Scale
  static Route scale(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: AnimationTokens.durationFast,
    );
  }
}
```

### Gesture Animations
```dart
class GestureAnimations {
  // Swipe to Delete
  static Widget swipeToDelete(Widget child) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: ColorTokens.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: SpacingTokens.space6),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      child: child,
    );
  }
  
  // Pull to Refresh
  static Widget pullToRefresh(Widget child, VoidCallback onRefresh) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: ColorTokens.primary400,
      backgroundColor: Colors.white,
      child: child,
    );
  }
  
  // Long Press Menu
  static Widget longPressMenu(Widget child, List<PopupMenuItem> items) {
    return GestureDetector(
      onLongPress: () {
        // Show context menu
      },
      child: child,
    );
  }
}
```

---

## 📱 반응형 디자인 시스템

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 0;      // 0 - 599
  static const double tablet = 600;    // 600 - 1023
  static const double desktop = 1024;  // 1024 - 1439
  static const double large = 1440;    // 1440+
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### Grid System
```dart
class GridSystem {
  static int getColumns(double width) {
    if (width >= Breakpoints.desktop) return 12;
    if (width >= Breakpoints.tablet) return 8;
    return 4;
  }
  
  static double getMargin(double width) {
    if (width >= Breakpoints.desktop) return 32;
    if (width >= Breakpoints.tablet) return 24;
    return 16;
  }
  
  static double getGutter(double width) {
    if (width >= Breakpoints.desktop) return 24;
    if (width >= Breakpoints.tablet) return 16;
    return 8;
  }
}
```

---

## 🌙 다크모드 시스템

### Dark Theme Colors
```dart
class DarkColorTokens {
  // Primary Palette (Inverted)
  static const primary50 = Color(0xFF1A1F2E);
  static const primary100 = Color(0xFF23293A);
  static const primary200 = Color(0xFF2C3347);
  static const primary300 = Color(0xFF3E4A63);
  static const primary400 = Color(0xFF8AAEE0);
  static const primary500 = Color(0xFFB1C9EF);
  
  // Neutral Palette (Inverted)
  static const gray50 = Color(0xFF171717);
  static const gray100 = Color(0xFF262626);
  static const gray200 = Color(0xFF404040);
  static const gray300 = Color(0xFF525252);
  static const gray400 = Color(0xFF737373);
  static const gray500 = Color(0xFFA3A3A3);
  static const gray600 = Color(0xFFD4D4D4);
  static const gray700 = Color(0xFFE5E5E5);
  static const gray800 = Color(0xFFF5F5F5);
  static const gray900 = Color(0xFFFAFAFA);
  
  // Surface Colors
  static const surface = Color(0xFF1E1E1E);
  static const surfaceVariant = Color(0xFF2A2A2A);
  static const background = Color(0xFF121212);
}
```

---

## ♿ 접근성 가이드라인

### Touch Targets
```dart
class AccessibilityGuidelines {
  // Minimum touch target size
  static const double minTouchTarget = 48.0; // Material Design guideline
  
  // Focus indicators
  static BoxDecoration focusIndicator = BoxDecoration(
    border: Border.all(
      color: ColorTokens.primary400,
      width: 3,
    ),
    borderRadius: BorderRadius.circular(RadiusTokens.md),
  );
  
  // Screen reader labels
  static String getButtonLabel(String text, bool isLoading) {
    if (isLoading) return '$text, loading';
    return text;
  }
  
  // Contrast ratios (WCAG AA)
  // Normal text: 4.5:1
  // Large text: 3:1
  // UI components: 3:1
}
```

### Semantic Labels
```dart
class SemanticLabels {
  static const String closeButton = 'Close';
  static const String menuButton = 'Open menu';
  static const String backButton = 'Go back';
  static const String moreButton = 'More options';
  static const String deleteButton = 'Delete';
  static const String editButton = 'Edit';
  static const String saveButton = 'Save';
  static const String cancelButton = 'Cancel';
}
```

---

## 🎮 게이미피케이션 컴포넌트

### Achievement Badge
```dart
class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final bool isUnlocked;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isUnlocked ? ColorTokens.gold : ColorTokens.gray200,
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked ? ColorTokens.gold : ColorTokens.gray300,
          width: 3,
        ),
        boxShadow: isUnlocked ? ElevationTokens.elevation2 : [],
      ),
      child: Icon(
        Icons.star,
        color: isUnlocked ? Colors.white : ColorTokens.gray400,
        size: 40,
      ),
    );
  }
}
```

### Modern Streak Counter - 애니메이션 스트릭 카운터
```dart
class ModernStreakCounter extends StatelessWidget {
  final int days;
  final bool isToday;
  final int milestone; // 7, 30, 100 days etc
  
  @override
  Widget build(BuildContext context) {
    final bool isMilestone = days == milestone;
    
    return AnimatedContainer(
      duration: AnimationTokens.durationNormal,
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.space5,
        vertical: SpacingTokens.space4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMilestone ? [
            ColorTokens.gold,
            Color(0xFFFF6B00),
          ] : [
            ColorTokens.warning.withOpacity(0.9),
            ColorTokens.warning,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.warning.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          if (isMilestone) 
            BoxShadow(
              color: ColorTokens.gold.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated fire icon
          AnimatedContainer(
            duration: AnimationTokens.durationFast,
            transform: Matrix4.identity()
              ..scale(isToday ? 1.2 : 1.0),
            child: Text(
              '🔥',
              style: TextStyle(fontSize: isMilestone ? 28 : 24),
            ),
          ),
          SizedBox(width: SpacingTokens.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$days 일 연속',
                style: Typography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isMilestone)
                Text(
                  '🎉 $milestone일 달성!',
                  style: Typography.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Weekly Streak Calendar - 주간 스트릭 캘린더
class WeeklyStreakCalendar extends StatelessWidget {
  final List<bool> weeklyStreak; // 7 days
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space4),
      decoration: BoxDecoration(
        color: ColorTokens.primary50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final bool hasStreak = weeklyStreak[index];
          final bool isToday = index == 6;
          
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hasStreak 
                ? ColorTokens.warning 
                : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isToday 
                  ? ColorTokens.primary400 
                  : hasStreak 
                    ? ColorTokens.warning 
                    : ColorTokens.gray200,
                width: isToday ? 2 : 1,
              ),
              boxShadow: hasStreak ? [
                BoxShadow(
                  color: ColorTokens.warning.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : [],
            ),
            child: Center(
              child: hasStreak 
                ? Text('🔥', style: TextStyle(fontSize: 16))
                : Text(
                    ['월', '화', '수', '목', '금', '토', '일'][index],
                    style: Typography.labelSmall.copyWith(
                      color: ColorTokens.gray500,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
            ),
          );
        }),
      ),
    );
  }
}
```

### Level Indicator
```dart
class LevelIndicator extends StatelessWidget {
  final int level;
  final double progress; // 0.0 to 1.0
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorTokens.primary300, ColorTokens.primary500],
              ),
              shape: BoxShape.circle,
              boxShadow: ElevationTokens.elevation3,
            ),
            child: Center(
              child: Text(
                'Lv.$level',
                style: Typography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: SpacingTokens.space3),
          Container(
            width: 120,
            child: ProgressBar(progress: progress),
          ),
        ],
      ),
    );
  }
}
```

---

## 📐 레이아웃 패턴

### Dashboard Layout
```dart
class DashboardLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (Desktop only)
          if (MediaQuery.of(context).size.width >= Breakpoints.desktop)
            Container(
              width: 280,
              color: ColorTokens.primary500,
              // Sidebar content
            ),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  color: Colors.white,
                  boxShadow: ElevationTokens.elevation1,
                ),
                
                // Content area
                Expanded(
                  child: Container(
                    color: ColorTokens.gray50,
                    padding: EdgeInsets.all(SpacingTokens.space6),
                    // Dashboard widgets
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Form Layout
```dart
class FormLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title
          Text('Create Account', style: Typography.headlineMedium),
          SizedBox(height: SpacingTokens.space3),
          Text(
            'Fill in your details to get started',
            style: Typography.bodyMedium.copyWith(color: ColorTokens.gray600),
          ),
          SizedBox(height: SpacingTokens.space7),
          
          // Form fields
          Column(
            children: [
              TextField(label: 'Full Name'),
              SizedBox(height: SpacingTokens.space5),
              TextField(label: 'Email'),
              SizedBox(height: SpacingTokens.space5),
              TextField(label: 'Password', isPassword: true),
              SizedBox(height: SpacingTokens.space7),
              PrimaryButton(text: 'Create Account'),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 16. Study Progress Components - 학습 진도 시각화
```dart
// Modern Progress Dashboard - 학습 대시보드
class StudyProgressDashboard extends StatelessWidget {
  final int totalHours;
  final int completedTasks;
  final int streak;
  final double weeklyProgress;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTokens.primary50,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.primary200.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer,
                  value: '$totalHours시간',
                  label: '총 학습 시간',
                  color: ColorTokens.primary400,
                ),
              ),
              SizedBox(width: SpacingTokens.space4),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  value: '$completedTasks',
                  label: '완료한 과제',
                  color: ColorTokens.success,
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingTokens.space5),
          // Circular Progress Chart
          Container(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(200, 200),
                  painter: MultiRingProgressPainter(
                    progress1: weeklyProgress,
                    progress2: 0.8,
                    progress3: 0.6,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(weeklyProgress * 100).toInt()}%',
                      style: Typography.displaySmall.copyWith(
                        color: ColorTokens.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '주간 목표',
                      style: Typography.labelMedium.copyWith(
                        color: ColorTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: SpacingTokens.space3),
          Text(
            value,
            style: Typography.titleLarge.copyWith(
              color: ColorTokens.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: SpacingTokens.space1),
          Text(
            label,
            style: Typography.labelSmall.copyWith(
              color: ColorTokens.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

// Study Session Stats - 세션 통계
class StudySessionStats extends StatelessWidget {
  final int focusTime;
  final int breakTime;
  final int sessions;
  final double efficiency;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingTokens.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTokens.primary400.withOpacity(0.9),
            ColorTokens.primary500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.primary400.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 학습 세션',
            style: Typography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SpacingTokens.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SessionStatItem(
                icon: Icons.timer,
                value: '${focusTime}분',
                label: '집중 시간',
              ),
              _SessionStatItem(
                icon: Icons.free_breakfast,
                value: '${breakTime}분',
                label: '휴식 시간',
              ),
              _SessionStatItem(
                icon: Icons.repeat,
                value: '$sessions회',
                label: '세션 수',
              ),
            ],
          ),
          SizedBox(height: SpacingTokens.space5),
          // Efficiency Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '학습 효율',
                    style: Typography.labelMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    '${(efficiency * 100).toInt()}%',
                    style: Typography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.space2),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: efficiency,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 24,
        ),
        SizedBox(height: SpacingTokens.space2),
        Text(
          value,
          style: Typography.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Typography.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
```

### 17. CustomPainter 구현체
```dart
// CircularProgressPainter - 원형 프로그레스 바
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;
  final Gradient? gradient;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    this.backgroundColor,
    this.strokeWidth = 8.0,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    if (backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = backgroundColor!
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      progressPaint.shader = gradient!.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    } else {
      progressPaint.color = color;
    }

    final progressAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

// MultiRingProgressPainter - 다중 링 프로그레스
class MultiRingProgressPainter extends CustomPainter {
  final double progress1;
  final double progress2;
  final double progress3;

  MultiRingProgressPainter({
    required this.progress1,
    required this.progress2,  
    required this.progress3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Outer ring
    _drawRing(
      canvas, 
      center, 
      size.width / 2 - 10, 
      progress1,
      ColorTokens.primary400,
      ColorTokens.primary100.withOpacity(0.3),
    );
    
    // Middle ring
    _drawRing(
      canvas,
      center,
      size.width / 2 - 35,
      progress2,
      ColorTokens.primary300,
      ColorTokens.primary100.withOpacity(0.2),
    );
    
    // Inner ring
    _drawRing(
      canvas,
      center,
      size.width / 2 - 60,
      progress3,
      ColorTokens.primary200,
      ColorTokens.primary100.withOpacity(0.1),
    );
  }

  void _drawRing(Canvas canvas, Offset center, double radius, 
                 double progress, Color color, Color bgColor) {
    // Background
    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(MultiRingProgressPainter oldDelegate) {
    return oldDelegate.progress1 != progress1 ||
           oldDelegate.progress2 != progress2 ||
           oldDelegate.progress3 != progress3;
  }
}
```

---

## 🎨 ThemeData 통합

### main.dart 설정
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    ProviderScope(
      child: HyleApp(),
    ),
  );
}

class HyleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HYLE - 학습 동반자',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
```

### app_theme.dart
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: ColorTokens.primary400,
      primaryContainer: ColorTokens.primary100,
      secondary: ColorTokens.primary300,
      secondaryContainer: ColorTokens.primary50,
      surface: Colors.white,
      background: ColorTokens.gray50,
      error: ColorTokens.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ColorTokens.gray900,
      onBackground: ColorTokens.gray900,
      onError: Colors.white,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ColorTokens.gray900,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: Typography.titleLarge,
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorTokens.primary400,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        textStyle: Typography.labelLarge,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTokens.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorTokens.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorTokens.primary400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorTokens.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ColorTokens.primary400,
      unselectedItemColor: ColorTokens.gray500,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: ColorScheme.dark(
      primary: ColorTokens.primary400,
      primaryContainer: DarkColorTokens.primary200,
      secondary: ColorTokens.primary300,
      secondaryContainer: DarkColorTokens.primary100,
      surface: DarkColorTokens.surface,
      background: DarkColorTokens.background,
      error: ColorTokens.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DarkColorTokens.gray900,
      onBackground: DarkColorTokens.gray900,
      onError: Colors.white,
    ),
    
    // 다크모드 설정...
  );
}
```

---

## 📝 Claude Code 사용 지시사항

### 프로젝트 초기화 명령어
```bash
# Flutter 프로젝트 생성
flutter create hyle --org com.hyle

# 필요한 패키지 추가
flutter pub add flutter_riverpod
flutter pub add google_fonts  # Pretendard 폰트용
flutter pub add flutter_svg    # SVG 아이콘용
```

### Claude Code 전용 가이드라인
```markdown
## Claude Code야, Flutter UI를 생성할 때 다음 규칙을 따라줘:

### 1. 파일 생성 규칙
- 위치: lib/core/theme/에 토큰 파일들 먼저 생성
- 순서: ColorTokens → SpacingTokens → Typography → 컴포넌트
- 네이밍: snake_case로 파일명, PascalCase로 클래스명

### 2. 컴포넌트 생성 규칙
- 반드시 StatelessWidget 우선 사용
- 모든 하드코딩 값 제거 (토큰 사용)
- build 메서드는 단일 책임 원칙 준수
- 복잡한 위젯은 private 메서드로 분리

### 3. 스타일 적용 우선순위
1. Theme.of(context) 사용
2. ColorTokens 직접 참조
3. 절대 하드코딩 금지

### 4. 상태 관리
- Riverpod Provider 사용
- StateNotifier로 복잡한 상태 관리
- Consumer/ConsumerWidget 활용

### 5. 성능 최적화
- const 생성자 최대한 활용
- AnimatedBuilder 대신 AnimatedWidget 사용
- ListView.builder로 긴 리스트 처리

### 6. 접근성
- Semantics 위젯 추가
- 최소 터치 영역 48x48
- 색상 대비 4.5:1 이상

### 7. 테스트 가능한 코드
- 의존성 주입 패턴 사용
- 비즈니스 로직 분리
- Mockable 인터페이스 설계
```

---

## 🎯 디자인 원칙 체크리스트

### 일관성 체크리스트
- [ ] 모든 버튼이 동일한 높이 (56px) 사용
- [ ] 모든 입력 필드가 동일한 스타일 적용
- [ ] 색상이 정의된 토큰만 사용
- [ ] 간격이 8px 베이스 시스템 준수
- [ ] 텍스트 스타일이 Typography 시스템 사용

### 접근성 체크리스트
- [ ] 모든 인터랙티브 요소가 48px 최소 터치 영역 확보
- [ ] 색상 대비가 WCAG AA 기준 충족 (4.5:1)
- [ ] 포커스 인디케이터가 명확하게 표시
- [ ] 스크린 리더를 위한 시맨틱 레이블 제공
- [ ] 키보드 네비게이션 지원

### 성능 체크리스트
- [ ] 애니메이션이 60fps 유지
- [ ] 이미지가 적절한 크기로 최적화
- [ ] 불필요한 리렌더링 방지
- [ ] 레이지 로딩 구현
- [ ] 스켈레톤 UI로 로딩 경험 개선

---

## 📝 구현 우선순위

### Phase 1: Core Foundation (Day 1)
- [x] Design Token System
- [x] Color System
- [x] Typography System
- [ ] Basic Components (Button, Input, Card)

### Phase 2: Component Library (Day 2-3)
- [ ] Navigation Components
- [ ] Form Components
- [ ] Feedback Components
- [ ] Data Display Components

### Phase 3: Screens (Day 4-5)
- [ ] Authentication Screens
- [ ] Home & Dashboard
- [ ] Study Features
- [ ] Profile & Settings

### Phase 4: Advanced Features (Day 6-7)
- [ ] Gamification Components
- [ ] AI Chat Interface
- [ ] Social Features
- [ ] Dark Mode Support

---

**이 문서는 HYLE 앱의 완전한 UI 구현을 위한 100% 개발 가능한 스타일 가이드입니다.**
**모든 컴포넌트는 실제 코드 예제와 함께 제공되어 즉시 구현 가능합니다.**