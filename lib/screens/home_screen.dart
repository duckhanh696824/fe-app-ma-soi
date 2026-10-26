import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../widgets/mystical_bg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticalBackground(
        particleCount: 40,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Moon icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPurple.withValues(alpha: 0.4),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.accentCyan.withValues(alpha: 0.2),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      size: 80,
                      color: AppColors.accentPurple,
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scaleXY(
                        begin: 0.95,
                        end: 1.05,
                        duration: 3.seconds,
                        curve: Curves.easeInOut,
                      )
                      .shimmer(
                        duration: 3.seconds,
                        color: AppColors.accentCyan.withValues(alpha: 0.3),
                      ),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'MA SÓI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: AppColors.accentPurple,
                          blurRadius: 30,
                        ),
                        Shadow(
                          color: AppColors.accentCyan,
                          blurRadius: 60,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .shimmer(
                        duration: 2.seconds,
                        color: AppColors.accentPurple.withValues(alpha: 0.4),
                      )
                      .then()
                      .shimmer(
                        delay: 3.seconds,
                        duration: 2.seconds,
                        color: AppColors.accentCyan.withValues(alpha: 0.3),
                      ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'QUẢN TRÒ TỰ ĐỘNG',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),

                  const Spacer(flex: 2),

                  // Login button
                  _buildActionButton(
                    label: 'ĐĂNG NHẬP',
                    icon: Icons.login,
                    gradient: AppColors.purpleGradient,
                    glowColor: AppColors.accentPurple,
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  )
                      .animate()
                      .fadeIn(delay: 1600.ms, duration: 600.ms)
                      .slideY(begin: 0.5, end: 0),

                  const SizedBox(height: 14),

                  // Register button
                  _buildActionButton(
                    label: 'ĐĂNG KÝ',
                    icon: Icons.person_add,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                    glowColor: AppColors.accentCyan,
                    onTap: () => Navigator.pushNamed(context, '/register'),
                  )
                      .animate()
                      .fadeIn(delay: 1800.ms, duration: 600.ms)
                      .slideY(begin: 0.5, end: 0),

                  const SizedBox(height: 14),

                  // Guest play button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text(
                        'CHƠI NGAY',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 2000.ms, duration: 600.ms)
                      .slideY(begin: 0.5),

                  const SizedBox(height: 32),

                  // Version
                  Text(
                    'v2.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ).animate().fadeIn(delay: 2200.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        double glow = _glowController.value;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.2 + glow * 0.2),
                  blurRadius: 12 + glow * 12,
                  spreadRadius: -3 + glow * 3,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
