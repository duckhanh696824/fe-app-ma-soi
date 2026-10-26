import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_role.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/role_card.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _playerCount = 6;

  @override
  void initState() {
    super.initState();
    // Set default role config
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      provider.updateRoleConfig(GameRole.werewolf, 2);
      provider.updateRoleConfig(GameRole.villager, 2);
      provider.updateRoleConfig(GameRole.seer, 1);
      provider.updateRoleConfig(GameRole.guard, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.nightGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<GameProvider>().resetGame();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary),
                    ),
                    const Expanded(
                      child: Text(
                        'THIẾT LẬP TRÒ CHƠI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player count selector
                      GlassCard(
                        child: Column(
                          children: [
                            const Text(
                              'Số người chơi',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CircleButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (_playerCount > 4) {
                                      setState(() => _playerCount--);
                                    }
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    '$_playerCount',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.accentPurple,
                                    ),
                                  ),
                                ),
                                _CircleButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    if (_playerCount < 20) {
                                      setState(() => _playerCount++);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                      const SizedBox(height: 24),

                      // Role selection title
                      const Text(
                        '🎭 Chọn vai trò',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 12),

                      // Role grid
                      Consumer<GameProvider>(
                        builder: (context, provider, _) {
                          return GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                            children: GameRole.values.map((role) {
                              int count = provider.roleConfig[role] ?? 0;
                              return RoleCard(
                                role: role,
                                count: count,
                                onIncrement: () {
                                  provider.updateRoleConfig(role, count + 1);
                                },
                                onDecrement: () {
                                  if (count > 0) {
                                    provider.updateRoleConfig(role, count - 1);
                                  }
                                },
                              );
                            }).toList(),
                          );
                        },
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                      const SizedBox(height: 24),

                      // Validation & Continue
                      Consumer<GameProvider>(
                        builder: (context, provider, _) {
                          String? error =
                              provider.validateConfig(_playerCount);
                          int totalRoles = provider.totalRolesConfigured;

                          return Column(
                            children: [
                              // Progress indicator
                              GlassCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Đã chọn: $totalRoles / $_playerCount vai',
                                      style: TextStyle(
                                        color: totalRoles == _playerCount
                                            ? AppColors.accentGreen
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      totalRoles == _playerCount
                                          ? Icons.check_circle
                                          : Icons.pending,
                                      color: totalRoles == _playerCount
                                          ? AppColors.accentGreen
                                          : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),

                              if (error != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                        AppColors.accentRed.withValues(alpha: 0.1),
                                    border: Border.all(
                                        color: AppColors.accentRed
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber,
                                          color: AppColors.accentRed, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          error,
                                          style: const TextStyle(
                                            color: AppColors.accentRed,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Continue button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: error == null
                                      ? () {
                                          Navigator.pushNamed(
                                            context,
                                            '/assign',
                                            arguments: _playerCount,
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: error == null
                                        ? AppColors.accentPurple
                                        : AppColors.primaryMid,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'TIẾP TỤC →',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentPurple.withValues(alpha: 0.15),
          border: Border.all(
            color: AppColors.accentPurple.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Icon(icon, color: AppColors.accentPurple, size: 24),
      ),
    );
  }
}
