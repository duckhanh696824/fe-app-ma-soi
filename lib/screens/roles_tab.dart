import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api/api_config.dart';
import '../models/game_role.dart';
import '../theme/app_colors.dart';
import '../widgets/mystical_bg.dart';
import '../widgets/mystical_image_viewer.dart';

class RolesTab extends StatefulWidget {
  const RolesTab({super.key});

  @override
  State<RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<RolesTab> with TickerProviderStateMixin {
  GameRole? _expandedRole;
  late AnimationController _glowPulse;

  @override
  void initState() {
    super.initState();
    _glowPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowPulse.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Simulate network refresh
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _expandedRole = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MysticalBackground(
      particleCount: 25,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.accentPurple,
        backgroundColor: AppColors.surface,
        displacement: 40,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Mystical icon
                        AnimatedBuilder(
                          animation: _glowPulse,
                          builder: (context, child) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF4C1D95),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentPurple
                                        .withValues(alpha: 0.3 + _glowPulse.value * 0.3),
                                    blurRadius: 12 + _glowPulse.value * 8,
                                    spreadRadius: _glowPulse.value * 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_fix_high,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vai trò',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 2,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .shimmer(
                                    duration: 2.seconds,
                                    color: AppColors.accentPurple.withValues(alpha: 0.4),
                                  ),
                              Text(
                                '${GameRole.values.length} linh hồn • 4 thế lực',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1,
                                ),
                              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Faction sections
            ..._buildFactionSections(),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFactionSections() {
    final factions = [
      GameTeam.villager,
      GameTeam.wolf,
      GameTeam.switchSide,
      GameTeam.thirdParty,
    ];

    List<Widget> sections = [];
    for (int fi = 0; fi < factions.length; fi++) {
      final faction = factions[fi];
      final roles = GameRoleExtension.byTeam(faction);

      // ─── Faction header ───
      sections.add(
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        faction.color.withValues(alpha: 0.15 + _glowPulse.value * 0.08),
                        faction.color.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: faction.color.withValues(alpha: 0.3 + _glowPulse.value * 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: faction.color.withValues(alpha: 0.1 + _glowPulse.value * 0.08),
                        blurRadius: 16 + _glowPulse.value * 8,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              faction.color.withValues(alpha: 0.6),
                              faction.color.withValues(alpha: 0.15),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: faction.color.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            faction.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faction.displayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: faction.color,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${roles.length} vai trò',
                              style: TextStyle(
                                fontSize: 12,
                                color: faction.color.withValues(alpha: 0.6),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: faction.color.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          color: faction.color.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            '${roles.length}',
                            style: TextStyle(
                              color: faction.color,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
              .animate()
              .fadeIn(delay: (fi * 200).ms, duration: 500.ms)
              .slideY(begin: 0.15),
        ),
      );

      // ─── Role cards ───
      sections.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final role = roles[index];
              final isExpanded = _expandedRole == role;

              return _MysticalRoleCard(
                role: role,
                faction: faction,
                isExpanded: isExpanded,
                glowPulse: _glowPulse,
                onTap: () {
                  setState(() {
                    _expandedRole = isExpanded ? null : role;
                  });
                },
              )
                  .animate()
                  .fadeIn(
                      delay: (fi * 150 + index * 80).ms, duration: 450.ms)
                  .slideX(begin: 0.12);
            },
            childCount: roles.length,
          ),
        ),
      );
    }
    return sections;
  }
}

/// ─── Mystical Role Card ───────────────────────────────────
class _MysticalRoleCard extends StatelessWidget {
  final GameRole role;
  final GameTeam faction;
  final bool isExpanded;
  final AnimationController glowPulse;
  final VoidCallback onTap;

  const _MysticalRoleCard({
    required this.role,
    required this.faction,
    required this.isExpanded,
    required this.glowPulse,
    required this.onTap,
  });

  String get _imageUrl => '${ApiConfig.serverUrl}${role.imagePath}';
  String get _heroTag => 'role_card_${role.name}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: glowPulse,
          builder: (context, child) {
            final glow = isExpanded ? glowPulse.value : 0.0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isExpanded
                      ? role.color.withValues(alpha: 0.5 + glow * 0.2)
                      : AppColors.cardBorder,
                  width: isExpanded ? 1.5 : 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isExpanded
                      ? [
                          role.color.withValues(alpha: 0.12 + glow * 0.04),
                          role.color.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.2),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                ),
                boxShadow: isExpanded
                    ? [
                        BoxShadow(
                          color: role.color.withValues(alpha: 0.15 + glow * 0.1),
                          blurRadius: 20 + glow * 10,
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: role.color.withValues(alpha: 0.05),
                          blurRadius: 40,
                          spreadRadius: -8,
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // ─── Role header row ───
                    Row(
                      children: [
                        // Card image thumbnail (tappable to open viewer)
                        GestureDetector(
                          onTap: () => _openImageViewer(context),
                          child: Hero(
                            tag: _heroTag,
                            child: _RoleCardImage(
                              imageUrl: _imageUrl,
                              role: role,
                              isExpanded: isExpanded,
                              glow: glow,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Role info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isExpanded
                                      ? role.color
                                      : AppColors.textPrimary,
                                  letterSpacing: isExpanded ? 1 : 0,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: faction.color,
                                      boxShadow: [
                                        BoxShadow(
                                          color: faction.color.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    faction.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: faction.color.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (role.hasNightAction) ...[
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.nightlight_round,
                                      size: 13,
                                      color: AppColors.accentPurple.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Đêm',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.accentPurple.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Expand indicator
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 350),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isExpanded
                                  ? role.color.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                            child: Icon(
                              Icons.expand_more,
                              size: 20,
                              color: isExpanded ? role.color : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ─── Expanded content ───
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildExpandedContent(context),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 400),
                      sizeCurve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context) {
    MysticalImageViewer.open(
      context,
      imageUrl: _imageUrl,
      heroTag: _heroTag,
      title: role.displayName,
      accentColor: role.color,
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          // ─── Divider ───
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  role.color.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ─── Card image + Description ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large card image (tappable)
              GestureDetector(
                onTap: () => _openImageViewer(context),
                child: _RoleCardImageLarge(
                  imageUrl: _imageUrl,
                  role: role,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MysticalInfoSection(
                  icon: Icons.auto_stories,
                  label: 'Mô Tả',
                  content: role.description,
                  color: role.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ─── Night & Day abilities ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MysticalInfoSection(
                  icon: Icons.dark_mode,
                  label: 'Ban Đêm',
                  content: role.khaNangDem,
                  color: const Color(0xFF8B5CF6),
                  compact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MysticalInfoSection(
                  icon: Icons.wb_sunny,
                  label: 'Ban Ngày',
                  content: role.khaNangNgay,
                  color: const Color(0xFFF59E0B),
                  compact: true,
                ),
              ),
            ],
          ),

          // ─── Note ───
          if (role.ghiChu != null) ...[
            const SizedBox(height: 10),
            _MysticalInfoSection(
              icon: Icons.warning_amber_rounded,
              label: 'Ghi Chú',
              content: role.ghiChu!,
              color: const Color(0xFFEF4444),
              isWarning: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// ─── Role Card Image (thumbnail) ──────────────────────────
class _RoleCardImage extends StatelessWidget {
  final String imageUrl;
  final GameRole role;
  final bool isExpanded;
  final double glow;

  const _RoleCardImage({
    required this.imageUrl,
    required this.role,
    required this.isExpanded,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: role.color.withValues(alpha: isExpanded ? 0.6 + glow * 0.2 : 0.35),
          width: isExpanded ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: role.color.withValues(alpha: isExpanded ? 0.25 + glow * 0.15 : 0.1),
            blurRadius: isExpanded ? 14 + glow * 6 : 8,
            spreadRadius: -2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  role.color.withValues(alpha: 0.4),
                  role.color.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Text(role.emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  role.color.withValues(alpha: 0.2),
                  role.color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: role.color.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ─── Role Card Image Large (expanded) ────────────────────
class _RoleCardImageLarge extends StatelessWidget {
  final String imageUrl;
  final GameRole role;

  const _RoleCardImageLarge({
    required this.imageUrl,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: role.color.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: role.color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  role.color.withValues(alpha: 0.3),
                  role.color.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(role.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                Text(
                  role.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: role.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  role.color.withValues(alpha: 0.15),
                  role.color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: role.color.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ─── Mystical Info Section ────────────────────────────────
class _MysticalInfoSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String content;
  final Color color;
  final bool compact;
  final bool isWarning;

  const _MysticalInfoSection({
    required this.icon,
    required this.label,
    required this.content,
    required this.color,
    this.compact = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isWarning ? 0.12 : 0.08),
            color.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: isWarning ? 0.3 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: compact ? 14 : 15),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            content,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
