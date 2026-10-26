import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_role.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class AssignScreen extends StatefulWidget {
  const AssignScreen({super.key});

  @override
  State<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends State<AssignScreen> {
  final List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();
  int _revealIndex = -1;
  bool _allRevealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllers.isEmpty) {
      int playerCount = ModalRoute.of(context)!.settings.arguments as int;
      for (int i = 0; i < playerCount; i++) {
        _controllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    if (!_formKey.currentState!.validate()) return;

    List<String> names = _controllers.map((c) => c.text.trim()).toList();
    context.read<GameProvider>().setupPlayers(names);

    setState(() {
      _revealIndex = -1;
      _allRevealed = false;
    });
  }

  void _nextReveal() {
    final provider = context.read<GameProvider>();
    if (_revealIndex < provider.players.length - 1) {
      setState(() => _revealIndex++);
    } else {
      setState(() => _allRevealed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        bool isAssigned = provider.players.isNotEmpty;

        return Scaffold(
          body: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.nightGradient),
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
                            provider.resetGame();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.textPrimary),
                        ),
                        Expanded(
                          child: Text(
                            isAssigned ? 'XEM VAI TRÒ' : 'NHẬP TÊN NGƯỜI CHƠI',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                  ),

                  Expanded(
                    child: isAssigned
                        ? _buildRoleReveal(provider)
                        : _buildNameInput(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameInput() {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.purpleGradient,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _controllers[index],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Người chơi ${index + 1}',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideX(begin: 0.3);
              },
            ),
          ),
        ),

        // Assign button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '🎲 XÁO TRỘN & GÁN VAI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildRoleReveal(GameProvider provider) {
    return Column(
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.accentCyan, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _allRevealed
                        ? 'Tất cả đã xem vai. Sẵn sàng bắt đầu!'
                        : _revealIndex < 0
                            ? 'Chuyền điện thoại cho từng người để xem vai trò bí mật'
                            : 'Chuyền cho người tiếp theo',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.players.length,
            itemBuilder: (context, index) {
              final player = provider.players[index];
              bool isRevealed = index <= _revealIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: index == _revealIndex + 1 ? _nextReveal : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: GlassCard(
                      isSelected: isRevealed,
                      borderColor: isRevealed ? player.role.color : null,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRevealed
                                  ? player.role.color.withValues(alpha: 0.2)
                                  : AppColors.primaryMid,
                            ),
                            child: Center(
                              child: isRevealed
                                  ? Icon(player.role.icon,
                                      color: player.role.color, size: 22)
                                  : const Icon(Icons.lock,
                                      color: AppColors.textMuted, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (isRevealed) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${player.role.emoji} ${player.role.displayName}',
                                    style: TextStyle(
                                      color: player.role.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!isRevealed && index == _revealIndex + 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: AppColors.purpleGradient,
                              ),
                              child: const Text(
                                'Nhấn để xem',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (isRevealed)
                            const Icon(Icons.check_circle,
                                color: AppColors.accentGreen, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Start game button
        if (_allRevealed)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  provider.startNight();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/night',
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
                  '🌙 BẮT ĐẦU ĐÊM ĐẦU TIÊN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.5)
              .shimmer(delay: 500.ms, duration: 1500.ms),
      ],
    );
  }
}
