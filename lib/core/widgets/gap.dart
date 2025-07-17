import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class Gap extends StatelessWidget {
  final double size;
  
  const Gap(this.size, {super.key});
  
  static const Gap xxs = Gap(AppSpacing.xxs);
  static const Gap xs = Gap(AppSpacing.xs);
  static const Gap sm = Gap(AppSpacing.sm);
  static const Gap md = Gap(AppSpacing.md);
  static const Gap lg = Gap(AppSpacing.lg);
  static const Gap xl = Gap(AppSpacing.xl);
  static const Gap xxl = Gap(AppSpacing.xxl);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
    );
  }
}