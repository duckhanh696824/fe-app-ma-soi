import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A mystical animated background with floating particles and glow effects.
class MysticalBackground extends StatefulWidget {
  final Widget child;
  final LinearGradient? gradient;
  final int particleCount;

  const MysticalBackground({
    super.key,
    required this.child,
    this.gradient,
    this.particleCount = 30,
  });

  @override
  State<MysticalBackground> createState() => _MysticalBackgroundState();
}

class _MysticalBackgroundState extends State<MysticalBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.gradient ?? AppColors.nightGradient,
      ),
      child: Stack(
        children: [
          // Particle layer
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Glow orbs
          Positioned(
            top: -50,
            right: -30,
            child: _GlowOrb(
              color: AppColors.accentPurple.withValues(alpha: 0.08),
              size: 250,
              controller: _controller,
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _GlowOrb(
              color: AppColors.accentCyan.withValues(alpha: 0.06),
              size: 300,
              controller: _controller,
              reverse: true,
            ),
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });

  factory _Particle.random() {
    final rng = Random();
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 3 + 1,
      speed: rng.nextDouble() * 0.3 + 0.1,
      opacity: rng.nextDouble() * 0.5 + 0.1,
      phase: rng.nextDouble() * 2 * pi,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width;
      final animY = (p.y - progress * p.speed) % 1.0;
      final dy = animY * size.height;
      final flickerOpacity =
          p.opacity * (0.5 + 0.5 * sin(progress * 2 * pi + p.phase));

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: flickerOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final AnimationController controller;
  final bool reverse;

  const _GlowOrb({
    required this.color,
    required this.size,
    required this.controller,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final scale = 1.0 +
            0.15 *
                sin(controller.value * 2 * pi + (reverse ? pi : 0));
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: size * 0.6,
                  spreadRadius: size * 0.1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
