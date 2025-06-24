import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliverySuccessfullDialog extends StatefulWidget {
  final String? orderId;

  const DeliverySuccessfullDialog({super.key, this.orderId});

  @override
  State<DeliverySuccessfullDialog> createState() => _DeliverySuccessfullDialogState();
}

class _DeliverySuccessfullDialogState extends State<DeliverySuccessfullDialog>
    with TickerProviderStateMixin {
  late AnimationController _fireworksController;
  late AnimationController _handwritingController;
  late Animation<double> _handwritingProgress;
  late List<FireworkParticle> _particles;

  @override
  void initState() {
    super.initState();
    
    // Handwriting animation controller
    _handwritingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _handwritingProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _handwritingController,
      curve: Curves.easeInOut,
    ));
    
    // Fireworks controller - starts after handwriting
    _fireworksController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _particles = _generateFireworkParticles();
    
    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    // Start handwriting animation immediately
    _handwritingController.forward();
    
    // Wait for handwriting to be 60% complete, then start fireworks
    await Future.delayed(const Duration(milliseconds: 1500));
    _fireworksController.repeat();
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    _handwritingController.dispose();
    super.dispose();
  }

  List<FireworkParticle> _generateFireworkParticles() {
    final particles = <FireworkParticle>[];
    final random = math.Random();
    
    // Focused firework bursts around text area (smaller, more focused range)
    for (int burst = 0; burst < 8; burst++) {
      // Constrain to text area: roughly center horizontal, upper portion vertical
      final burstX = 0.15 + (random.nextDouble() * 0.7); // 15% to 85% horizontal
      final burstY = 0.15 + (random.nextDouble() * 0.35); // 15% to 50% vertical (around text)
      final burstDelay = burst * 0.8;
      
      // Smaller main explosion particles - reduced count and velocity for focused effect
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20) * 2 * math.pi;
        final velocity = 30 + random.nextDouble() * 60; // Reduced velocity for smaller spread
        particles.add(
          FireworkParticle(
            startX: burstX,
            startY: burstY,
            velocityX: math.cos(angle) * velocity,
            velocityY: math.sin(angle) * velocity,
            color: _getRandomFireworkColor(),
            delay: burstDelay,
            size: 2.0 + random.nextDouble() * 3.0, // Smaller particles
            life: 1.8 + random.nextDouble() * 1.2,
            particleType: FireworkParticleType.burst,
          ),
        );
      }
      
      // Trailing sparks - reduced count
      for (int i = 0; i < 8; i++) {
        final angle = random.nextDouble() * 2 * math.pi;
        final velocity = 20 + random.nextDouble() * 40;
        particles.add(
          FireworkParticle(
            startX: burstX,
            startY: burstY,
            velocityX: math.cos(angle) * velocity,
            velocityY: math.sin(angle) * velocity,
            color: _getRandomFireworkColor().withOpacity(0.7),
            delay: burstDelay + 0.2,
            size: 1.0 + random.nextDouble() * 2.0,
            life: 2.0 + random.nextDouble() * 1.0,
            particleType: FireworkParticleType.trail,
          ),
        );
      }
      
      // Occasional ring effects - smaller and more focused
      if (burst % 3 == 0) {
        for (int i = 0; i < 12; i++) {
          final angle = (i / 12) * 2 * math.pi;
          final velocity = 40 + random.nextDouble() * 30;
          particles.add(
            FireworkParticle(
              startX: burstX,
              startY: burstY,
              velocityX: math.cos(angle) * velocity,
              velocityY: math.sin(angle) * velocity,
              color: _getGoldenColor(),
              delay: burstDelay + 0.4,
              size: 1.5 + random.nextDouble() * 2.0,
              life: 1.5 + random.nextDouble() * 0.8,
              particleType: FireworkParticleType.ring,
            ),
          );
        }
      }
    }
    
    // Ambient sparkles around text area only
    for (int i = 0; i < 40; i++) {
      particles.add(
        FireworkParticle(
          startX: 0.1 + random.nextDouble() * 0.8, // Text area width
          startY: 0.1 + random.nextDouble() * 0.4, // Text area height
          velocityX: (random.nextDouble() - 0.5) * 20,
          velocityY: (random.nextDouble() - 0.5) * 20,
          color: Colors.white.withOpacity(0.9),
          delay: random.nextDouble() * 5.0,
          size: 0.5 + random.nextDouble() * 1.5,
          life: 1.0 + random.nextDouble() * 1.5,
          particleType: FireworkParticleType.sparkle,
        ),
      );
    }
    
    return particles;
  }

  Color _getRandomFireworkColor() {
    final colors = [
      const Color(0xFFFF4757), // Bright red
      const Color(0xFF2ED573), // Bright green
      const Color(0xFF1E90FF), // Bright blue
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6B35), // Orange
      const Color(0xFF7B68EE), // Purple
      const Color(0xFF00CED1), // Turquoise
      const Color(0xFFFF1493), // Pink
    ];
    return colors[math.Random().nextInt(colors.length)];
  }
  
  Color _getGoldenColor() {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFFA500), // Orange
      const Color(0xFFFFB347), // Peach
      const Color(0xFFFFE135), // Yellow
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Stack(
        children: [
          // Fireworks layer (behind content)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fireworksController,
              builder: (context, child) {
                return IgnorePointer(
                  child: CustomPaint(
                    painter: FireworksPainter(_particles, _fireworksController.value),
                  ),
                );
              },
            ),
          ),
          // Content layer
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDefaults.padding * 3,
              horizontal: AppDefaults.padding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AspectRatio(
                  aspectRatio: 1 / 1,
                  child: NetworkImageWithLoader(
                    'https://i.imgur.com/DQqtvkL.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                // Handwritten Congratulations text
                AnimatedBuilder(
                  animation: _handwritingProgress,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(280, 60),
                      painter: HandwritingPainter(_handwritingProgress.value),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'You got your beloved items!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: AppDefaults.padding * 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.entryPoint,
                        (route) => false,
                      );
                    },
                    child: const Text('Browse Home'),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.orderId != null && widget.orderId!.isNotEmpty) {
                        Navigator.of(context).pushNamed(
                          AppRoutes.orderDetails,
                          arguments: widget.orderId,
                        );
                      } else {
                        Navigator.of(context).pushNamed(AppRoutes.myOrder);
                      }
                    },
                    child: const Text('Track Order'),
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

// Custom painter for handwriting animation
class HandwritingPainter extends CustomPainter {
  final double progress;
  
  HandwritingPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final textSpan = TextSpan(
      text: 'Congratulations!',
      style: GoogleFonts.pacifico(
        fontSize: 36,
        color: const Color(0xFF1976D2),
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width);
    
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    
    // Clip the text based on progress to create writing reveal effect
    final clipRect = Rect.fromLTWH(0, 0, textPainter.width * progress, textPainter.height);
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.clipRect(clipRect);
    
    // Draw shadow for depth
    textPainter.paint(canvas, const Offset(2, 2));
    // Draw main text
    textPainter.paint(canvas, Offset.zero);
    
    canvas.restore();
    
    // Draw blinking cursor at current writing position
    if (progress < 1.0) {
      final cursorX = offset.dx + textPainter.width * progress;
      final cursorY1 = offset.dy;
      final cursorY2 = offset.dy + textPainter.height;
      final blinkPhase = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;
      if (blinkPhase < 0.5) {
        final cursorPaint = Paint()
          ..color = const Color(0xFF1976D2)
          ..strokeWidth = 2;
        canvas.drawLine(Offset(cursorX, cursorY1), Offset(cursorX, cursorY2), cursorPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) => oldDelegate.progress != progress;
}

enum FireworkParticleType {
  burst,
  trail,
  sparkle,
  ring,
  star,
  cascade,
  ember,
}

class FireworkParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double delay;
  final double size;
  final double life;
  final FireworkParticleType particleType;

  FireworkParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.delay,
    this.size = 2.0,
    this.life = 1.0,
    this.particleType = FireworkParticleType.burst,
  });
  
  // Backward compatibility with old parameters
  bool get isTrail => particleType == FireworkParticleType.trail;
  bool get isSparkle => particleType == FireworkParticleType.sparkle;
}

class FireworksPainter extends CustomPainter {
  final List<FireworkParticle> particles;
  final double animationValue;

  FireworksPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedTime = math.max(0.0, (animationValue * 6) - particle.delay);
      if (adjustedTime <= 0) continue;

      final progress = math.min(1.0, adjustedTime / particle.life);
      
      double fadeProgress = _calculateFadeProgress(particle, adjustedTime, progress);
      if (fadeProgress <= 0) continue;

      final gravity = _getGravity(particle);
      final position = _calculatePosition(particle, size, progress, gravity);
      final currentSize = _calculateSize(particle, progress);
      
      _drawParticle(canvas, particle, position, currentSize, fadeProgress, progress);
    }
  }
  
  double _calculateFadeProgress(FireworkParticle particle, double adjustedTime, double progress) {
    switch (particle.particleType) {
      case FireworkParticleType.sparkle:
        return (math.sin(adjustedTime * 10) + 1) / 2 * (1 - progress);
      case FireworkParticleType.trail:
      case FireworkParticleType.cascade:
        return math.max(0.0, 1.0 - progress * 0.8);
      case FireworkParticleType.ring:
        return progress > 0.8 ? (1.0 - progress) / 0.2 : 1.0;
      default: // burst
        return progress > 0.7 ? (1.0 - progress) / 0.3 : 1.0;
    }
  }
  
  double _getGravity(FireworkParticle particle) {
    switch (particle.particleType) {
      case FireworkParticleType.sparkle:
        return 10.0;
      case FireworkParticleType.ring:
        return 20.0;
      default:
        return 30.0;
    }
  }
  
  Offset _calculatePosition(FireworkParticle particle, Size size, double progress, double gravity) {
    final x = particle.startX * size.width + particle.velocityX * progress;
    final y = particle.startY * size.height + particle.velocityY * progress + 
              (progress * progress * gravity);
    return Offset(x, y);
  }
  
  double _calculateSize(FireworkParticle particle, double progress) {
    switch (particle.particleType) {
      case FireworkParticleType.ring:
        return particle.size * (0.5 + 0.5 * progress); // Rings grow
      default:
        return particle.size * (1.0 - progress * 0.5); // Normal shrinkage
    }
  }
  
  void _drawParticle(Canvas canvas, FireworkParticle particle, Offset position, 
                     double currentSize, double fadeProgress, double progress) {
    final mainPaint = Paint()
      ..color = particle.color.withOpacity(fadeProgress)
      ..style = PaintingStyle.fill;

    switch (particle.particleType) {
      case FireworkParticleType.ring:
        _drawRing(canvas, position, currentSize, mainPaint, fadeProgress);
        break;
      default:
        _drawCircleParticle(canvas, particle, position, currentSize, mainPaint, fadeProgress, progress);
    }
  }
  
  void _drawRing(Canvas canvas, Offset center, double size, Paint paint, double fadeProgress) {
    final ringPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawCircle(center, size, ringPaint);
    
    // Add subtle glow
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(fadeProgress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(center, size, glowPaint);
  }
  
  void _drawCircleParticle(Canvas canvas, FireworkParticle particle, Offset center, 
                          double currentSize, Paint paint, double fadeProgress, double progress) {
    canvas.drawCircle(center, currentSize, paint);
    
    // Add subtle glow for main particles
    if (particle.particleType != FireworkParticleType.sparkle && 
        particle.particleType != FireworkParticleType.trail) {
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(fadeProgress * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(center, currentSize * 1.8, glowPaint);
    }
    
    // Add small sparkle cross for burst particles
    if (particle.particleType == FireworkParticleType.burst && progress < 0.4) {
      final sparklePaint = Paint()
        ..color = Colors.white.withOpacity(fadeProgress * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, currentSize * 0.2, sparklePaint);
      
      final sparkleSize = currentSize * 0.5;
      canvas.drawRect(
        Rect.fromCenter(center: center, width: sparkleSize * 2, height: 1),
        sparklePaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 1, height: sparkleSize * 2),
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
