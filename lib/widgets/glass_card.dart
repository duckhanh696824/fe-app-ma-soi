import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isSelected;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? (borderColor ?? AppColors.accentPurple)
                : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isSelected
                  ? (borderColor ?? AppColors.accentPurple).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.08),
              isSelected
                  ? (borderColor ?? AppColors.accentPurple).withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.03),
            ],
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (borderColor ?? AppColors.accentPurple)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
