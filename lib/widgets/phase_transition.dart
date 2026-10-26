import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Mystical phase transition screen used before entering night or morning.
///
/// [phaseType] — 'night' or 'morning'
/// [phaseNumber] — đêm / sáng thứ mấy
/// [onComplete] — callback khi animation kết thúc
class PhaseTransition extends StatefulWidget {
  final String phaseType; // 'night' | 'morning'
  final int phaseNumber;
  final VoidCallback onComplete;
  final Duration duration;

  const PhaseTransition({
    super.key,
    required this.phaseType,
    required this.phaseNumber,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<PhaseTransition> createState() => _PhaseTransitionState();
}

class _PhaseTransitionState extends State<PhaseTransition>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late List<_Particle> _particles;
  final _random = Random();

  bool get _isNight => widget.phaseType == 'night';

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particles = List.generate(30, (_) => _Particle.random(_random));

    Future.delayed(widget.duration, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: _isNight
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF0A0820),
                            Color.lerp(
                              const Color(0xFF1A0F3E),
                              const Color(0xFF0F0C29),
                              _pulseController.value,
                            )!,
                            const Color(0xFF150D30),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1E1B4B),
                            Color.lerp(
                              const Color(0xFF4C1D95),
                              const Color(0xFF7C3AED),
                              _pulseController.value * 0.5,
                            )!,
                            Color.lerp(
                              const Color(0xFFF59E0B),
                              const Color(0xFFFBBF24),
                              _pulseController.value,
                            )!,
                          ],
                        ),
                ),
              );
            },
          ),

          // Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                  isNight: _isNight,
                ),
              );
            },
          ),

          // Fog overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        sin(_mainController.value * pi * 2) * 0.3,
                        cos(_mainController.value * pi * 2) * 0.2 -
                            (_isNight ? 0.3 : 0.5),
                      ),
                      radius: 1.5,
                      colors: [
                        (_isNight
                                ? Colors.indigo
                                : Colors.orange)
                            .withValues(alpha: 0.08 + _mainController.value * 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Central content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),

                    // Moon or Sun icon
                    _buildCentralIcon(),

                    const SizedBox(height: 32),

                    // Phase title
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isNight
                            ? 'ĐÊM ${widget.phaseNumber}'
                            : 'BÌNH MINH',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: _isNight ? Colors.amber : Colors.orange,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: (_isNight ? Colors.amber : Colors.orange)
                                  .withValues(alpha: 0.6),
                              blurRadius: 30,
                            ),
                            Shadow(
                              color: (_isNight ? Colors.purple : Colors.deepOrange)
                                  .withValues(alpha: 0.3),
                              blurRadius: 60,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 800.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      _isNight
                          ? 'Mọi người hãy nhắm mắt...'
                          : 'Mọi người mở mắt...',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isNight
                            ? AppColors.textSecondary
                            : Colors.orange.shade100,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 1200.ms, duration: 800.ms),

                    const SizedBox(height: 40),

                    // Mystical loading indicator
                    _buildLoadingIndicator(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Vignette overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralIcon() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_isNight ? Colors.amber : Colors.orange)
                    .withValues(alpha: 0.15 + _mainController.value * 0.25),
                blurRadius: 50 + _mainController.value * 40,
                spreadRadius: 5 + _mainController.value * 10,
              ),
              BoxShadow(
                color: (_isNight ? Colors.purple : Colors.deepOrange)
                    .withValues(alpha: 0.1 + _mainController.value * 0.1),
                blurRadius: 80 + _mainController.value * 30,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_isNight ? Colors.amber : Colors.orange)
                        .withValues(alpha: 0.2 + _mainController.value * 0.2),
                    width: 2,
                  ),
                ),
              ),
              // Inner ring
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_isNight ? Colors.purple : Colors.deepOrange)
                        .withValues(alpha: 0.15 + _mainController.value * 0.15),
                    width: 1.5,
                  ),
                ),
              ),
              // Icon
              Icon(
                _isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                size: 64,
                color: _isNight ? Colors.amber : Colors.orange,
              ),
            ],
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 1.seconds)
        .scaleXY(begin: 0.3, end: 1.0, duration: 1200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final value = ((_pulseController.value + delay) % 1.0);
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_isNight ? Colors.amber : Colors.orange)
                      .withValues(alpha: 0.3 + value * 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: (_isNight ? Colors.amber : Colors.orange)
                          .withValues(alpha: value * 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    ).animate().fadeIn(delay: 1500.ms);
  }
}

// ─── Particle System ───────────────────────────────────────────────────

class _Particle {
  double x, y, size, speed, opacity;
  double drift;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
  });

  factory _Particle.random(Random r) {
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: 1.5 + r.nextDouble() * 3,
      speed: 0.2 + r.nextDouble() * 0.6,
      opacity: 0.2 + r.nextDouble() * 0.5,
      drift: -0.5 + r.nextDouble(),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isNight;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isNight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.y - progress * p.speed) % 1.0) * size.height;
      final x = (p.x + sin(progress * pi * 2 + p.drift * pi) * 0.03) *
          size.width;

      final alpha = p.opacity * (0.5 + 0.5 * sin(progress * pi * 2 + p.x * pi));

      final paint = Paint()
        ..color = (isNight ? Colors.amber : Colors.orange)
            .withValues(alpha: alpha.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
