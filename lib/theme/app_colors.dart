import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Deep night theme
  static const Color primaryDark = Color(0xFF0D0B1E);
  static const Color primaryDeep = Color(0xFF1A1533);
  static const Color primaryMid = Color(0xFF2D2548);
  static const Color primaryLight = Color(0xFF3E3563);

  // Accent colors
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPink = Color(0xFFEC4899);

  // Faction colors
  static const Color factionVillager = Color(0xFF10B981);
  static const Color factionWolf = Color(0xFFEF4444);
  static const Color factionSwitch = Color(0xFFF59E0B);
  static const Color factionThird = Color(0xFFA855F7);

  // Gradient
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const LinearGradient safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95), Color(0xFFF59E0B)],
  );

  // Mystical gradients
  static const LinearGradient moonlightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0C29), Color(0xFF1A1145), Color(0xFF302B63)],
  );

  static const LinearGradient enchantedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0533), Color(0xFF2D1B69), Color(0xFF0F0C29)],
  );

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Surface colors
  static const Color surface = Color(0xFF1E1B35);
  static const Color surfaceLight = Color(0xFF2A2545);
  static const Color cardBackground = Color(0x33FFFFFF);
  static const Color cardBorder = Color(0x22FFFFFF);

  // Role colors
  static const Color wolfColor = Color(0xFFEF4444);
  static const Color villagerColor = Color(0xFF10B981);
  static const Color seerColor = Color(0xFF8B5CF6);
  static const Color guardColor = Color(0xFF3B82F6);
  static const Color witchColor = Color(0xFFEC4899);
  static const Color hunterColor = Color(0xFFF59E0B);
}
