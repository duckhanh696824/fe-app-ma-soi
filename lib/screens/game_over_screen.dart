import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_role.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        bool wolfWins = provider.winner == GameTeam.wolf;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: wolfWins
                    ? [
                        const Color(0xFF1A0000),
                        const Color(0xFF3B0000),
                        const Color(0xFF1A0000),
                      ]
                    : [
                        const Color(0xFF001A0A),
                        const Color(0xFF003B1A),
                        const Color(0xFF001A0A),
                      ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),

                    // Winner icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: wolfWins
                                ? AppColors.accentRed.withValues(alpha: 0.5)
                                : AppColors.accentGreen.withValues(alpha: 0.5),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        wolfWins ? Icons.pets : Icons.shield,
                        size: 80,
                        color: wolfWins
                            ? AppColors.accentRed
                            : AppColors.accentGreen,
                      ),
                    )
                        .animate()
                        .scaleXY(
                          begin: 0,
                          end: 1,
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .shimmer(
                          delay: 800.ms,
                          duration: 2.seconds,
                          color: wolfWins
                              ? AppColors.accentRed.withValues(alpha: 0.3)
                              : AppColors.accentGreen.withValues(alpha: 0.3),
                        ),

                    const SizedBox(height: 32),

                    // Winner text
                    Text(
                      wolfWins ? '🐺 PHE SÓI THẮNG!' : '🏘️ PHE DÂN THẮNG!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: wolfWins
                            ? AppColors.accentRed
                            : AppColors.accentGreen,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: wolfWins
                                ? AppColors.accentRed
                                : AppColors.accentGreen,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 800.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 8),

                    Text(
                      wolfWins
                          ? 'Ma sói đã chiến thắng dân làng'
                          : 'Dân làng đã tiêu diệt hết sói',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 8),

                    Text(
                      'Trò chơi kết thúc sau ${provider.nightCount} đêm',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(delay: 1000.ms),

                    const SizedBox(height: 32),

                    // All players with roles
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📋 Danh sách vai trò',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: provider.players.length,
                                itemBuilder: (context, index) {
                                  final player = provider.players[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: player.role.color
                                                .withValues(alpha: 0.2),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              player.role.icon,
                                              color: player.role.color,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            player.name,
                                            style: TextStyle(
                                              color: player.isAlive
                                                  ? AppColors.textPrimary
                                                  : AppColors.textMuted,
                                              fontWeight: FontWeight.w500,
                                              decoration: player.isAlive
                                                  ? null
                                                  : TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: player.role.color
                                                .withValues(alpha: 0.15),
                                          ),
                                          child: Text(
                                            player.role.displayName,
                                            style: TextStyle(
                                              color: player.role.color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          player.isAlive
                                              ? Icons.favorite
                                              : Icons.heart_broken,
                                          size: 16,
                                          color: player.isAlive
                                              ? AppColors.accentGreen
                                              : AppColors.accentRed,
                                        ),
                                      ],
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: (1200 + index * 100).ms)
                                      .slideX(begin: 0.2);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Play again button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.resetGame();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '🔄 CHƠI LẠI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 2000.ms)
                        .slideY(begin: 0.3),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
