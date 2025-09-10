import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final bool showWaves;
  final bool showGradient;
  
  const AnimatedBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.showWaves = true,
    this.showGradient = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> 
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  
  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Animated Gradient Background
        if (widget.showGradient)
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_gradientController.value * 2 * math.pi),
                      math.sin(_gradientController.value * 2 * math.pi),
                    ),
                    end: Alignment(
                      -math.cos(_gradientController.value * 2 * math.pi),
                      -math.sin(_gradientController.value * 2 * math.pi),
                    ),
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                      AppColors.tertiary.withOpacity(0.08),
                      AppColors.accent.withOpacity(0.05),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              );
            },
          ),
        
        // Wave Pattern
        if (widget.showWaves)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animation: _waveController.value,
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                );
              },
            ),
          ),
        
        // Floating Particles
        if (widget.showParticles)
          ...List.generate(20, (index) {
            final random = math.Random(index);
            final startX = random.nextDouble() * size.width;
            final startY = random.nextDouble() * size.height;
            final duration = 10 + random.nextInt(10);
            final delay = random.nextInt(5);
            
            return Positioned(
              left: startX,
              top: startY,
              child: Container(
                width: 6 + random.nextDouble() * 4,
                height: 6 + random.nextDouble() * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.3),
                    AppColors.tertiary.withOpacity(0.3),
                    AppColors.accent.withOpacity(0.3),
                  ][index % 4],
                  boxShadow: [
                    BoxShadow(
                      color: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.2),
                        AppColors.tertiary.withOpacity(0.2),
                        AppColors.accent.withOpacity(0.2),
                      ][index % 4],
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
                delay: Duration(seconds: delay),
              ).moveY(
                begin: 0,
                end: -size.height - 50,
                duration: Duration(seconds: duration),
                curve: Curves.linear,
              ).fadeIn(
                duration: 1.seconds,
              ).then(
                delay: Duration(seconds: duration - 1),
              ).fadeOut(
                duration: 1.seconds,
              ),
            );
          }),
        
        // Geometric Shapes
        Positioned(
          right: -50,
          top: 100,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 2,
                ),
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).rotate(
            duration: 30.seconds,
            begin: 0,
            end: 2,
          ),
        ),
        
        Positioned(
          left: -30,
          bottom: 150,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.1),
                width: 2,
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).scale(
            duration: 4.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            curve: Curves.easeInOut,
          ).then().scale(
            duration: 4.seconds,
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
            curve: Curves.easeInOut,
          ),
        ),
        
        // Main Content
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  
  WavePainter({
    required this.animation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 3;
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height - 50 + 
          math.sin((x / waveLength + animation * 2 * math.pi)) * waveHeight;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Second wave
    final path2 = Path();
    final paint2 = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    path2.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height - 30 + 
          math.sin((x / waveLength + animation * 2 * math.pi + math.pi / 2)) * waveHeight;
      path2.lineTo(x, y);
    }
    
    path2.lineTo(size.width, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }
  
  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}