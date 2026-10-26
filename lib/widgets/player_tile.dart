import 'package:flutter/material.dart';
import '../models/game_role.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final bool showRole;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PlayerTile({
    super.key,
    required this.player,
    this.showRole = false,
    this.isSelected = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      isSelected: isSelected,
      borderColor: showRole ? player.role.color : null,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  (showRole ? player.role.color : AppColors.accentPurple)
                      .withValues(alpha: 0.3),
                  (showRole ? player.role.color : AppColors.accentPurple)
                      .withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: showRole ? player.role.color : AppColors.accentPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    color: player.isAlive
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration:
                        player.isAlive ? null : TextDecoration.lineThrough,
                  ),
                ),
                if (showRole) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${player.role.emoji} ${player.role.displayName}',
                    style: TextStyle(
                      color: player.role.color.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Status
          if (!player.isAlive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.accentRed.withValues(alpha: 0.15),
              ),
              child: const Text(
                '💀 Đã chết',
                style: TextStyle(
                  color: AppColors.accentRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (trailing != null) trailing!, // ignore: use_null_aware_elements
        ],
      ),
    );
  }
}
