import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/mystical_bg.dart';
import '../widgets/glass_card.dart';
import '../widgets/win_conditions_dialog.dart';

/// Mock game data for UI
class _MockGame {
  final int id;
  final String name;
  final int playerCount;
  final String status; // 'Đang chơi', 'Đã kết thúc'
  final String date;

  const _MockGame({
    required this.id,
    required this.name,
    required this.playerCount,
    required this.status,
    required this.date,
  });
}

class GamesTab extends StatefulWidget {
  const GamesTab({super.key});

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  final List<_MockGame> _games = [];
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    // TODO: Khi API sẵn sàng, khởi tạo VanChoiApi và gọi _loadGamesFromApi()
  }

  Future<void> _onRefresh() async {
    // TODO: Khi API sẵn sàng, gọi _loadGamesFromApi()
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  void _showCreateGameDialog() {
    int playerCount = 8;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.accentPurple.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      '🎮 Tạo Ván Mới',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Player count
                    const Text(
                      'Số lượng người chơi',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DialogCircleButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (playerCount > 4) {
                              setDialogState(() => playerCount--);
                            }
                          },
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            '$playerCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentPurple,
                            ),
                          ),
                        ),
                        _DialogCircleButton(
                          icon: Icons.add,
                          onTap: () {
                            if (playerCount < 30) {
                              setDialogState(() => playerCount++);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4 - 30 người',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(
                                  color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _createGame(playerCount);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Tạo',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _createGame(int playerCount) {
    final auth = context.read<AuthProvider>();
    final maVan = _nextId++;
    final tenVan = auth.isLoggedIn ? 'Ván $maVan' : 'Ván chơi';

    setState(() {
      _games.add(_MockGame(
        id: maVan,
        name: tenVan,
        playerCount: playerCount,
        status: 'Đang chơi',
        date: '',
      ));
    });

    Navigator.pushNamed(
      context,
      '/game-detail',
      arguments: {
        'gameId': maVan,
        'gameName': tenVan,
        'playerCount': playerCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MysticalBackground(
      particleCount: 12,
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎮 Ván Chơi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                          const SizedBox(height: 4),
                          Text(
                            auth.isLoggedIn
                                ? 'Xin chào, ${auth.username}'
                                : 'Chế độ khách',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Win conditions button
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => WinConditionsDialog.show(context),
                        icon: const Text('📜', style: TextStyle(fontSize: 18)),
                        label: const Text(
                          'Luật Chơi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentCyan,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.accentCyan.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Create game button
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _showCreateGameDialog,
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.white, size: 22),
                          label: const Text(
                            'TẠO VÁN MỚI',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: AppColors.accentPurple.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Game list or guest message
            auth.isLoggedIn
                ? _buildGameListSliver()
                : SliverFillRemaining(child: _buildGuestMessage()),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bạn có thể đăng nhập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Để xem danh sách các ván chơi trước đó.\nBạn vẫn có thể tạo ván mới mà không cần đăng nhập.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                'Đăng nhập',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentPurple,
                side: BorderSide(
                  color: AppColors.accentPurple.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 800.ms),
      ),
    );
  }

  Widget _buildGameListSliver() {
    if (_games.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_esports_outlined,
                size: 64,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có ván chơi nào',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tạo ván mới để bắt đầu!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final game = _games[index];
          final isPlaying = game.status == 'Đang chơi';

          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: GlassCard(
              borderColor: isPlaying ? AppColors.accentGreen : null,
              isSelected: isPlaying,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/game-detail',
                  arguments: {
                    'gameId': game.id,
                    'gameName': game.name,
                    'playerCount': game.playerCount,
                  },
                );
              },
              child: Row(
                children: [
                  // Game icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isPlaying
                          ? AppColors.safeGradient
                          : const LinearGradient(colors: [
                              AppColors.primaryMid,
                              AppColors.primaryLight,
                            ]),
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.play_circle_fill
                          : Icons.check_circle,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Game info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${game.playerCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.calendar_today,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                game.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isPlaying
                          ? AppColors.accentGreen.withValues(alpha: 0.15)
                          : AppColors.textMuted.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isPlaying
                            ? AppColors.accentGreen.withValues(alpha: 0.4)
                            : AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      game.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPlaying
                            ? AppColors.accentGreen
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 100).ms, duration: 400.ms)
              .slideX(begin: 0.15);
        },
        childCount: _games.length,
      ),
    );
  }
}

class _DialogCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DialogCircleButton({required this.icon, required this.onTap});

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
