import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Dialog hiển thị luật chơi và điều kiện thắng cuộc cho từng phe.
class WinConditionsDialog extends StatelessWidget {
  const WinConditionsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const WinConditionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1145), Color(0xFF0D0B1E)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.purpleGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('📜', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LUẬT CHƠI MA SÓI',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Điều kiện chiến thắng của từng phe',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFactionCard(
                      emoji: '🏘️',
                      name: 'PHE DÂN LÀNG',
                      color: AppColors.factionVillager,
                      winCondition:
                          'Tìm và loại bỏ tất cả Ma Sói ra khỏi làng.',
                      details: [
                        '👥 Bao gồm: Dân Làng, Tiên Tri, Bảo Vệ, Phù Thủy, Thợ Săn, Già Làng, Cupid, Bác Sĩ, Thiếu Niên Sói',
                        '🎯 Mục tiêu: Phát hiện và treo cổ tất cả sói',
                        '💡 Strategy: Dùng khả năng đặc biệt ban đêm + thảo luận ban ngày để tìm sói',
                      ],
                      delay: 0,
                    ),

                    const SizedBox(height: 14),

                    _buildFactionCard(
                      emoji: '🐺',
                      name: 'PHE SÓI',
                      color: AppColors.factionWolf,
                      winCondition:
                          'Số sói còn sống ≥ số dân còn sống.',
                      details: [
                        '🐺 Bao gồm: Sói Thường, Sói Trưởng, Sói Nguyền, Pháp Sư Sói',
                        '🎯 Mục tiêu: Cắn chết dân làng mỗi đêm cho đến khi áp đảo',
                        '💡 Strategy: Giả dạng dân làng, đánh lạc hướng cuộc thảo luận',
                      ],
                      delay: 100,
                    ),

                    const SizedBox(height: 14),

                    _buildFactionCard(
                      emoji: '⚖️',
                      name: 'PHE THỨ 3',
                      color: AppColors.factionThird,
                      winCondition:
                          'Mỗi vai trò có điều kiện thắng riêng biệt.',
                      details: [
                        '🧞 Thần Đèn: Thắng khi sống sót đến cuối game',
                        '🦊 Cáo: Thắng khi phát hiện ra tất cả sói (còn khả năng)',
                      ],
                      delay: 200,
                    ),

                    const SizedBox(height: 14),

                    _buildFactionCard(
                      emoji: '🔄',
                      name: 'ĐỔI PHE',
                      color: AppColors.factionSwitch,
                      winCondition:
                          'Thắng cùng phe hiện tại của mình.',
                      details: [
                        '🌑 Kẻ Bị Nguyền Rủa: Ban đầu phe dân, nếu bị sói cắn → chuyển sang phe sói',
                        '🎭 Người Hầu Gái: Thuộc phe dân, có thể chết thay người bị treo cổ (nếu là phe dân)',
                      ],
                      delay: 300,
                    ),

                    const SizedBox(height: 20),

                    // Game flow overview
                    _buildSimpleCard(
                      borderColor: AppColors.accentCyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: AppColors.accentCyan, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'LUỒNG GAME',
                                style: TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFlowStep('1', 'Chia bài cho mỗi người chơi',
                              Icons.style),
                          _buildFlowStep('2',
                              'Đêm: Quản trò gọi từng vai trò thức dậy',
                              Icons.nightlight_round),
                          _buildFlowStep('3',
                              'Sáng: Công bố ai bị chết trong đêm',
                              Icons.wb_sunny),
                          _buildFlowStep('4',
                              'Ngày: Thảo luận → đề cử → bỏ phiếu treo cổ',
                              Icons.groups),
                          _buildFlowStep('5',
                              'Lặp lại cho đến khi 1 phe chiến thắng',
                              Icons.emoji_events),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Simple card without BackdropFilter to avoid rendering issues in modal sheets
  Widget _buildSimpleCard({
    Color? borderColor,
    bool isSelected = false,
    EdgeInsetsGeometry? padding,
    required Widget child,
  }) {
    final color = borderColor ?? AppColors.cardBorder;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            isSelected
                ? color.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildFactionCard({
    required String emoji,
    required String name,
    required Color color,
    required String winCondition,
    required List<String> details,
    required int delay,
  }) {
    return _buildSimpleCard(
      borderColor: color,
      isSelected: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.08),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    winCondition,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...details.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  d,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200 + delay)).slideY(begin: 0.1);
  }

  Widget _buildFlowStep(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPurple.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.accentPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
