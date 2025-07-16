import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            )
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3)),
            
            const SizedBox(height: 24),
            
            Text(
              'Hyle',
              style: AppTypography.display.copyWith(
                color: Colors.white,
                fontSize: 48,
                letterSpacing: -2,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
            
            Text(
              'AI Learning Companion',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 2,
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}