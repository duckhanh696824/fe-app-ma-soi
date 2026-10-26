import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_role.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class HunterScreen extends StatefulWidget {
  const HunterScreen({super.key});

  @override
  State<HunterScreen> createState() => _HunterScreenState();
}

class _HunterScreenState extends State<HunterScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        Player hunter = provider.players
            .firstWhere((p) => p.role == GameRole.hunter);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.nightGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Hunter icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.hunterColor.withValues(alpha: 0.3),
                            AppColors.hunterColor.withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.hunterColor.withValues(alpha: 0.4),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.gps_fixed,
                        color: AppColors.hunterColor,
                        size: 40,
                      ),
                    )
                        .animate()
                        .scaleXY(begin: 0, end: 1, duration: 600.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 20),

                    Text(
                      '🏹 ${hunter.name} là Thợ Săn!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hunterColor,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 8),

                    const Text(
                      'Thợ Săn đã chết và được bắn 1 người đi theo',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 24),

                    // Target selection
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.alivePlayers.length,
                        itemBuilder: (context, index) {
                          final player = provider.alivePlayers[index];
                          bool isSelected = _selectedId == player.id;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              onTap: () =>
                                  setState(() => _selectedId = player.id),
                              isSelected: isSelected,
                              borderColor: AppColors.hunterColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.gps_fixed
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? AppColors.hunterColor
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (100 * index).ms)
                              .slideX(begin: 0.2);
                        },
                      ),
                    ),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedId != null
                            ? () {
                                provider.hunterShoot(_selectedId!);
                                if (provider.phase == GamePhase.gameOver) {
                                  Navigator.pushReplacementNamed(
                                      context, '/gameover');
                                } else {
                                  provider.goToMorning();
                                  Navigator.pushReplacementNamed(
                                      context, '/morning');
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedId != null
                              ? AppColors.hunterColor
                              : AppColors.primaryMid,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '🏹 BẮN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
