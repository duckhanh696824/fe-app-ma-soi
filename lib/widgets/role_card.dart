import 'package:flutter/material.dart';
import '../models/game_role.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class RoleCard extends StatelessWidget {
  final GameRole role;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const RoleCard({
    super.key,
    required this.role,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isSelected: count > 0,
      borderColor: role.color,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Role icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  role.color.withValues(alpha: 0.3),
                  role.color.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: role.color.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              role.icon,
              color: role.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          // Role name
          Text(
            role.displayName,
            style: TextStyle(
              color: count > 0 ? role.color : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: onDecrement,
                color: role.color,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: count > 0 ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onTap: onIncrement,
                color: role.color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
