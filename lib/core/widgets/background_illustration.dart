import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundIllustration extends StatelessWidget {
  final int imageIndex;
  final double opacity;
  final bool useGradientOverlay;
  
  const BackgroundIllustration({
    super.key,
    this.imageIndex = 20,
    this.opacity = 0.3,
    this.useGradientOverlay = true,
  });

  static const List<int> availableImages = [
    13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
  ];

  // Get random image for variety
  static int getRandomImageIndex() {
    final random = math.Random();
    return availableImages[random.nextInt(availableImages.length)];
  }

  // Get image by screen type for consistency
  static int getImageForScreen(String screenName) {
    switch (screenName) {
      case 'login':
        return 20;
      case 'home':
        return 21;
      case 'todo':
        return 15;
      case 'timer':
        return 18;
      case 'notes':
        return 19;
      case 'profile':
        return 22;
      case 'missions':
        return 16;
      case 'ai':
        return 17;
      default:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/Abstract background gradient $imageIndex - 7000x4000.jpg',
            fit: BoxFit.cover,
            opacity: AlwaysStoppedAnimation(opacity),
          ),
        ),
        // Gradient Overlay
        if (useGradientOverlay)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
      ],
    );
  }
}