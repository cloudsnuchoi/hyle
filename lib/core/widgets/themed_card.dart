import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class ThemedCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  
  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(themePresetProvider);
    
    Widget content = child;
    
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    
    // 테마별 특별한 스타일
    switch (preset.name) {
      case 'Colorful Fun':
        return _ColorfulFunCard(
          onTap: onTap,
          color: color,
          elevation: elevation,
          child: content,
        );
      
      case 'Pastel Soft':
        return _PastelSoftCard(
          onTap: onTap,
          color: color,
          elevation: elevation,
          child: content,
        );
      
      case 'Modern Dark':
        return _ModernDarkCard(
          onTap: onTap,
          color: color,
          elevation: elevation,
          child: content,
        );
      
      default:
        // 기본 카드
        return Card(
          color: color,
          elevation: elevation,
          child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(preset.borderRadius ?? 12),
                child: content,
              )
            : content,
        );
    }
  }
}

// 컬러풀한 스타일 카드
class _ColorfulFunCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  
  const _ColorfulFunCard({
    required this.child,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color ?? Theme.of(context).cardColor,
            (color ?? Theme.of(context).cardColor).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: elevation != null && elevation! > 0
          ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }
}

// 파스텔 스타일 카드
class _PastelSoftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  
  const _PastelSoftCard({
    required this.child,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: elevation != null && elevation! > 0
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: child,
        ),
      ),
    );
  }
}

// 모던 다크 스타일 카드
class _ModernDarkCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  
  const _ModernDarkCard({
    required this.child,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? Theme.of(context).cardColor).withOpacity(0.9),
            (color ?? Theme.of(context).cardColor),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

