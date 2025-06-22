import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';

class DeliverySuccessfullDialog extends StatefulWidget {
  final String? orderId;

  const DeliverySuccessfullDialog({super.key, this.orderId});

  @override
  State<DeliverySuccessfullDialog> createState() => _DeliverySuccessfullDialogState();
}

class _DeliverySuccessfullDialogState extends State<DeliverySuccessfullDialog>
    with TickerProviderStateMixin {
  late AnimationController _fireworksController;
  late List<FireworkParticle> _particles;

  @override
  void initState() {
    super.initState();
    _fireworksController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _particles = _generateFireworkParticles();
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    super.dispose();
  }

  List<FireworkParticle> _generateFireworkParticles() {
    final particles = <FireworkParticle>[];
    final random = math.Random();
    
    for (int burst = 0; burst < 5; burst++) {
      final burstX = 0.1 + (random.nextDouble() * 0.8);
      final burstY = 0.2 + (random.nextDouble() * 0.4);
      
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20) * 2 * math.pi;
        final velocity = 40 + random.nextDouble() * 60;
        particles.add(
          FireworkParticle(
            startX: burstX,
            startY: burstY,
            velocityX: math.cos(angle) * velocity,
            velocityY: math.sin(angle) * velocity,
            color: _getRandomFireworkColor(),
            delay: burst * 1.0,
            size: 2.0 + random.nextDouble() * 3.0,
            life: 1.5 + random.nextDouble() * 1.0,
          ),
        );
      }
      
      for (int i = 0; i < 8; i++) {
        final angle = random.nextDouble() * 2 * math.pi;
        final velocity = 20 + random.nextDouble() * 30;
        particles.add(
          FireworkParticle(
            startX: burstX,
            startY: burstY,
            velocityX: math.cos(angle) * velocity,
            velocityY: math.sin(angle) * velocity,
            color: _getRandomFireworkColor().withOpacity(0.6),
            delay: burst * 1.0 + 0.2,
            size: 1.0 + random.nextDouble() * 2.0,
            life: 2.0 + random.nextDouble() * 0.5,
            isTrail: true,
          ),
        );
      }
    }
    
    for (int i = 0; i < 30; i++) {
      particles.add(
        FireworkParticle(
          startX: random.nextDouble(),
          startY: random.nextDouble() * 0.6,
          velocityX: (random.nextDouble() - 0.5) * 20,
          velocityY: (random.nextDouble() - 0.5) * 20,
          color: Colors.white.withOpacity(0.8),
          delay: random.nextDouble() * 5.0,
          size: 0.5 + random.nextDouble() * 1.5,
          life: 0.5 + random.nextDouble() * 1.0,
          isSparkle: true,
        ),
      );
    }
    
    return particles;
  }

  Color _getRandomFireworkColor() {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
      const Color(0xFFFF9FF3),
      const Color(0xFFBB6BD9),
      const Color(0xFFFF7675),
      const Color(0xFF74B9FF),
      const Color(0xFF55A3FF),
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
                const SizedBox(height: 16),
                const Text(
                  'Congratulations! You got your',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'beloved items!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class FireworkParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double delay;
  final double size;
  final double life;
  final bool isTrail;
  final bool isSparkle;

  FireworkParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.delay,
    this.size = 2.0,
    this.life = 1.0,
    this.isTrail = false,
    this.isSparkle = false,
  });
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
      
      double fadeProgress;
      if (particle.isSparkle) {
        fadeProgress = (math.sin(adjustedTime * 8) + 1) / 2 * (1 - progress);
      } else if (particle.isTrail) {
        fadeProgress = math.max(0.0, 1.0 - progress * 0.8);
      } else {
        fadeProgress = progress > 0.7 ? (1.0 - progress) / 0.3 : 1.0;
      }
      
      if (fadeProgress <= 0) continue;

      final gravity = particle.isSparkle ? 20.0 : 50.0;
      final x = particle.startX * size.width + particle.velocityX * progress;
      final y = particle.startY * size.height + particle.velocityY * progress + 
                (progress * progress * gravity);

      final mainPaint = Paint()
        ..color = particle.color.withOpacity(fadeProgress)
        ..style = PaintingStyle.fill;

      final currentSize = particle.size * (1.0 - progress * 0.5);
      canvas.drawCircle(Offset(x, y), currentSize, mainPaint);
      
      if (!particle.isSparkle && !particle.isTrail) {
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(fadeProgress * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawCircle(Offset(x, y), currentSize * 2, glowPaint);
      }
      
      if (!particle.isTrail && progress < 0.4) {
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(fadeProgress * 0.9)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), currentSize * 0.3, sparklePaint);
        
        final sparkleSize = currentSize * 0.6;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: sparkleSize * 2, height: 1),
          sparklePaint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 1, height: sparkleSize * 2),
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
