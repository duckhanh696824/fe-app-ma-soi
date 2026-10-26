import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api/api_client.dart';
import '../api/vote_sang_api.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

/// Day vote screen — discussion → nomination → vote (hang / save).
///
/// Receives arguments: { maVan, soDem, nguoiChoi }
class DayVoteScreen extends StatefulWidget {
  const DayVoteScreen({super.key});

  @override
  State<DayVoteScreen> createState() => _DayVoteScreenState();
}

class _DayVoteScreenState extends State<DayVoteScreen> {
  bool _initialized = false;

  late int _maVan;
  late int _soDem;
  late List<Map<String, dynamic>> _nguoiChoi;

  // State
  _DayPhase _phase = _DayPhase.discussion;
  int? _nominatedPlayerId;
  int? _maVote; // from API response after nomination
  bool _isSubmitting = false;
  String? _error;
  String? _voteResult; // TREO_CO | THA

  final _apiClient = ApiClient();
  late VoteSangApi _voteSangApi;

  @override
  void initState() {
    super.initState();
    _voteSangApi = VoteSangApi(_apiClient);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _maVan = args['maVan'] as int;
        _soDem = args['soDem'] as int;
        _nguoiChoi =
            List<Map<String, dynamic>>.from(args['nguoiChoi'] as List);
      } else {
        _maVan = 0;
        _soDem = 1;
        _nguoiChoi = [];
      }
      _initialized = true;
    }
  }

  List<Map<String, dynamic>> get _alivePlayers =>
      _nguoiChoi.where((nc) => nc['TrangThai'] != 'CHET').toList();

  String _playerName(int? id) {
    if (id == null) return '???';
    final p = _nguoiChoi.firstWhere(
      (nc) => nc['MaNguoiChoi'] == id,
      orElse: () => {},
    );
    return (p['TenNguoiChoi'] ?? '???').toString();
  }

  Future<void> _nominate(int maNguoiChoi) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final resp = await _voteSangApi.deCuTreoCo(
        maVan: _maVan,
        soNgay: _soDem,
        maNguoiBiDeCu: maNguoiChoi,
      );

      if (!mounted) return;

      int? maVote;
      if (resp is Map) {
        maVote = resp['maVote'] ?? resp['MaVote'] ?? resp['data']?['maVote'];
      }

      setState(() {
        _isSubmitting = false;
        _nominatedPlayerId = maNguoiChoi;
        _maVote = maVote;
        _phase = _DayPhase.voting;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Lỗi đề cử: $e';
      });
    }
  }

  Future<void> _vote(String ketQua) async {
    if (_maVote == null) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await _voteSangApi.ketQuaVote(_maVote!, ketQua);

      if (!mounted) return;

      if (ketQua == 'TREO_CO') {
        // Mark player as dead
        final idx = _nguoiChoi.indexWhere(
          (nc) => nc['MaNguoiChoi'] == _nominatedPlayerId,
        );
        if (idx != -1) {
          _nguoiChoi[idx]['TrangThai'] = 'CHET';
        }
      }

      setState(() {
        _isSubmitting = false;
        _voteResult = ketQua;
        _phase = _DayPhase.result;
      });

      // Check game over via API
      try {
        final chungCuoc = await _voteSangApi.kiemTraChungCuoc(_maVan);
        if (!mounted) return;
        if (chungCuoc is Map && chungCuoc['ketThuc'] == true) {
          Navigator.pushReplacementNamed(context, '/gameover', arguments: {
            'maVan': _maVan,
            'nguoiChoi': _nguoiChoi,
            'pheThang': chungCuoc['pheThang'],
          });
          return;
        }
      } catch (_) {
        // Not game over yet, continue
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Lỗi bỏ phiếu: $e';
      });
    }
  }

  void _goToNextNight() {
    Navigator.pushReplacementNamed(context, '/night', arguments: {
      'maVan': _maVan,
      'soDem': _soDem + 1,
      'nguoiChoi': _nguoiChoi,
    });
  }

  void _skipVote() {
    _goToNextNight();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF312E81),
              Color(0xFF1E1B4B),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 12),

                // Error
                if (_error != null) _buildError(),

                // Content
                Expanded(child: _buildPhaseContent()),

                // Bottom actions
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _phase == _DayPhase.discussion
                    ? 'BAN NGÀY - THẢO LUẬN'
                    : _phase == _DayPhase.voting
                        ? 'BIỂU QUYẾT'
                        : 'KẾT QUẢ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Sau đêm $_soDem',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people, color: AppColors.accentGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                '${_alivePlayers.length}',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderColor: AppColors.accentRed,
        isSelected: true,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.accentRed, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error!,
                  style: const TextStyle(
                      color: AppColors.accentRed, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case _DayPhase.discussion:
        return _buildDiscussion();
      case _DayPhase.voting:
        return _buildVoting();
      case _DayPhase.result:
        return _buildResult();
    }
  }

  // ─── DISCUSSION ──────────────────────────────────────────────────

  Widget _buildDiscussion() {
    return Column(
      children: [
        // Discussion banner
        GlassCard(
          child: Column(
            children: [
              const Icon(Icons.groups,
                  color: AppColors.accentPurple, size: 40),
              const SizedBox(height: 8),
              const Text(
                'Thời gian thảo luận',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Thảo luận xong → Đề cử 1 người để treo cổ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.95),

        const SizedBox(height: 12),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Chọn người để đề cử:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: _alivePlayers.length,
            itemBuilder: (context, index) {
              final player = _alivePlayers[index];
              final id = player['MaNguoiChoi'] as int?;
              final name = player['TenNguoiChoi']?.toString() ?? '???';

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GlassCard(
                  onTap: _isSubmitting
                      ? null
                      : () {
                          if (id != null) _nominate(id);
                        },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.person,
                          color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.accentRed.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.accentRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'Đề cử',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (80 * index).ms)
                  .slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }

  // ─── VOTING ──────────────────────────────────────────────────────

  Widget _buildVoting() {
    final name = _playerName(_nominatedPlayerId);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nominated player
          GlassCard(
            borderColor: AppColors.accentRed,
            isSelected: true,
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.accentRed.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Center(
                    child: Text('⚖️', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Người bị đề cử',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cả làng biểu quyết: Giết hay cứu?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scaleXY(begin: 0.9),

          const SizedBox(height: 32),

          // Vote buttons
          Row(
            children: [
              // Save
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSubmitting ? null : () => _vote('THA'),
                    icon: const Icon(Icons.favorite,
                        color: Colors.white, size: 20),
                    label: const Text(
                      'CỨU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Kill
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSubmitting ? null : () => _vote('TREO_CO'),
                    icon: const Icon(Icons.gavel,
                        color: Colors.white, size: 20),
                    label: const Text(
                      'TREO CỔ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(color: AppColors.accentPurple),
            ),
        ],
      ),
    );
  }

  // ─── RESULT ──────────────────────────────────────────────────────

  Widget _buildResult() {
    final name = _playerName(_nominatedPlayerId);
    final isHanged = _voteResult == 'TREO_CO';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isHanged ? AppColors.accentRed : AppColors.accentGreen)
                  .withValues(alpha: 0.15),
              border: Border.all(
                color:
                    (isHanged ? AppColors.accentRed : AppColors.accentGreen)
                        .withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isHanged ? AppColors.accentRed : AppColors.accentGreen)
                          .withValues(alpha: 0.3),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Center(
              child: Text(
                isHanged ? '💀' : '🕊️',
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ).animate().scaleXY(begin: 0, end: 1, duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: (isHanged ? AppColors.accentRed : AppColors.accentGreen)
                  .withValues(alpha: 0.15),
              border: Border.all(
                color:
                    (isHanged ? AppColors.accentRed : AppColors.accentGreen)
                        .withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              isHanged ? '☠️ ĐÃ BỊ TREO CỔ' : '🕊️ ĐƯỢC THA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:
                    isHanged ? AppColors.accentRed : AppColors.accentGreen,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scaleXY(begin: 0.8),
        ],
      ),
    );
  }

  // ─── BOTTOM ACTIONS ──────────────────────────────────────────────

  Widget _buildBottomActions() {
    switch (_phase) {
      case _DayPhase.discussion:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _skipVote,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'BỎ QUA (Không treo cổ ai)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        );

      case _DayPhase.voting:
        return const SizedBox.shrink();

      case _DayPhase.result:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _goToNextNight,
            icon: const Icon(Icons.nightlight_round,
                color: Colors.white, size: 20),
            label: const Text(
              'VÀO ĐÊM TIẾP THEO',
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
            ),
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3);
    }
  }
}

enum _DayPhase {
  discussion,
  voting,
  result,
}
