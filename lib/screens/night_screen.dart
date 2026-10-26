import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api/api_client.dart';
import '../api/dem_xu_ly_api.dart';
import '../api/nguoi_choi_api.dart';
import '../models/game_role.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/phase_transition.dart';

/// Night screen — step-by-step role suggestions with local fallback.
///
/// Receives arguments: { maVan, soDem, nguoiChoi: [...] }
class NightScreen extends StatefulWidget {
  const NightScreen({super.key});

  @override
  State<NightScreen> createState() => _NightScreenState();
}

class _NightScreenState extends State<NightScreen> {
  bool _showTransition = true;
  bool _initialized = false;

  late int _maVan;
  late int _soDem;
  late List<Map<String, dynamic>> _nguoiChoi;

  // Night action order
  List<Map<String, dynamic>> _thuTuDem = [];
  int _currentSuggestionIndex = 0;

  // Completed actions
  final List<Map<String, dynamic>> _completedActions = [];

  // Night status
  int _soVaiTroCanGoi = 0;
  int _soVaiTroDaGoi = 0;
  bool _nightComplete = false;

  // Current action state
  bool _showCustomPicker = false;
  Map<String, dynamic>? _selectedRole;
  List<Map<String, dynamic>> _availableActions = [];
  String? _selectedAction;
  int? _selectedTarget1;
  int? _selectedTarget2;
  bool _isSubmitting = false;

  // Post-action GM instruction
  String? _gmInstruction;

  // Loading / error
  bool _isLoading = false;
  String? _error;

  final _apiClient = ApiClient();
  late DemXuLyApi _demXuLyApi;
  late NguoiChoiApi _nguoiChoiApi;

  @override
  void initState() {
    super.initState();
    _demXuLyApi = DemXuLyApi(_apiClient);
    _nguoiChoiApi = NguoiChoiApi(_apiClient);
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

  void _onTransitionComplete() {
    if (!mounted) return;
    setState(() => _showTransition = false);
    _loadNightData();
  }

  Future<void> _loadNightData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final thuTuResp = await _demXuLyApi.layThuTuDem(_maVan, _soDem);
      final trangThaiResp =
          await _demXuLyApi.kiemTraTrangThaiDem(_maVan, _soDem);

      if (!mounted) return;
      setState(() {
        _thuTuDem = _parseListMap(thuTuResp);
        if (trangThaiResp is Map) {
          _soVaiTroCanGoi = trangThaiResp['soVaiTroCanGoi'] ?? _thuTuDem.length;
          _soVaiTroDaGoi = trangThaiResp['soVaiTroDaGoi'] ?? 0;
        } else {
          _soVaiTroCanGoi = _thuTuDem.length;
        }
        _isLoading = false;
      });
    } catch (_) {
      // Fallback to local data
      if (!mounted) return;
      _buildLocalFallback();
      setState(() {
        _isLoading = false;
        _error = null;
      });
    }
  }

  /// Build night action order from local nguoiChoi data
  void _buildLocalFallback() {
    final rolesWithNightAction = <Map<String, dynamic>>[];

    for (final nc in _nguoiChoi) {
      if (nc['TrangThai'] == 'CHET') continue;

      final tenVaiTro = (nc['TenVaiTro'] ?? '').toString();
      final maVaiTro = nc['MaVaiTro'] ?? nc['maVaiTro'];

      // Match to local GameRole enum
      GameRole? localRole;
      for (final role in GameRole.values) {
        if (role.displayName.toLowerCase() == tenVaiTro.toLowerCase()) {
          localRole = role;
          break;
        }
      }
      // Fallback: match by maVaiTro index
      if (localRole == null && maVaiTro is int) {
        for (final role in GameRole.values) {
          if (role.index + 1 == maVaiTro) {
            localRole = role;
            break;
          }
        }
      }

      // Include roles with night actions
      if (localRole != null && localRole.hasNightAction) {
        rolesWithNightAction.add({
          ...nc,
          'TenVaiTro': localRole.displayName,
          '_nightOrder': localRole.nightOrder,
          '_localRole': localRole,
        });
      }
    }

    // Sort by night order
    rolesWithNightAction.sort((a, b) =>
        (a['_nightOrder'] as int).compareTo(b['_nightOrder'] as int));

    // Merge wolves into one entry (they act together)
    final merged = <Map<String, dynamic>>[];
    final wolfPlayers = <Map<String, dynamic>>[];
    for (final r in rolesWithNightAction) {
      final localRole = r['_localRole'] as GameRole;
      if (localRole == GameRole.werewolf ||
          localRole == GameRole.alphaWolf ||
          localRole == GameRole.cursedWolf) {
        wolfPlayers.add(r);
      } else {
        merged.add(r);
      }
    }
    // Add wolves as single entry if any
    if (wolfPlayers.isNotEmpty) {
      final firstWolf = wolfPlayers.first;
      final wolfNames = wolfPlayers.map((w) => w['TenNguoiChoi']).join(', ');
      merged.insert(
        merged.indexWhere((m) =>
            (m['_nightOrder'] as int) > (firstWolf['_nightOrder'] as int)),
        {
          ...firstWolf,
          'TenVaiTro': 'Bầy Sói',
          'TenNguoiChoi': wolfNames,
          '_wolfPlayers': wolfPlayers,
        },
      );
    }

    // If no roles found, still show ALL players so GM can manually call
    if (merged.isEmpty && _nguoiChoi.isNotEmpty) {
      for (final nc in _nguoiChoi) {
        if (nc['TrangThai'] == 'CHET') continue;
        final tenVaiTro = (nc['TenVaiTro'] ?? 'Vai trò').toString();
        merged.add({
          ...nc,
          'TenVaiTro': tenVaiTro,
          '_nightOrder': 99,
        });
      }
    }

    _thuTuDem = merged;
    _soVaiTroCanGoi = merged.length;
    _soVaiTroDaGoi = 0;
  }

  List<Map<String, dynamic>> _parseListMap(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  String _playerName(dynamic maNguoiChoi) {
    if (maNguoiChoi == null) return '???';
    final p = _nguoiChoi.firstWhere(
      (nc) => nc['MaNguoiChoi'] == maNguoiChoi,
      orElse: () => <String, dynamic>{},
    );
    return (p['TenNguoiChoi'] ?? '???').toString();
  }

  List<Map<String, dynamic>> get _alivePlayers {
    return _nguoiChoi.where((nc) => nc['TrangThai'] != 'CHET').toList();
  }

  List<Map<String, dynamic>> get _allRolesForPicker {
    final alive = _alivePlayers;
    final completedPlayerIds = _completedActions
        .map((a) {
          final role = a['role'] as Map<String, dynamic>?;
          return role?['MaNguoiChoi'] ?? role?['maNguoiChoi'];
        })
        .where((id) => id != null)
        .toSet();
    return alive.where((nc) => !completedPlayerIds.contains(nc['MaNguoiChoi'])).toList();
  }

  // ─── ACTION HANDLERS ─────────────────────────────────────────────

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    setState(() {
      _showCustomPicker = false;
      _selectedRole = suggestion;
      _selectedAction = null;
      _selectedTarget1 = null;
      _selectedTarget2 = null;
      _gmInstruction = null;
      _availableActions = _buildActionsForRole(suggestion);
      // Auto-select if only one action
      if (_availableActions.length == 1) {
        _selectedAction = _availableActions[0]['loaiHanhDong']?.toString();
      }
    });
  }

  void _openCustomPicker() {
    setState(() {
      _showCustomPicker = true;
      _selectedRole = null;
      _selectedAction = null;
      _selectedTarget1 = null;
      _selectedTarget2 = null;
      _availableActions = [];
      _gmInstruction = null;
    });
  }

  void _selectFromCustomPicker(Map<String, dynamic> roleInfo) {
    setState(() {
      _showCustomPicker = false;
      _selectedRole = roleInfo;
      _selectedAction = null;
      _selectedTarget1 = null;
      _selectedTarget2 = null;
      _availableActions = _buildActionsForRole(roleInfo);
      if (_availableActions.length == 1) {
        _selectedAction = _availableActions[0]['loaiHanhDong']?.toString();
      }
    });
  }

  /// Build available actions for a role — always works locally
  List<Map<String, dynamic>> _buildActionsForRole(Map<String, dynamic> roleInfo) {
    final tenVaiTro = (roleInfo['TenVaiTro'] ?? '').toString().toLowerCase();
    final localRole = roleInfo['_localRole'] as GameRole?;

    // Map role to concrete action codes
    if (tenVaiTro.contains('bầy sói') || tenVaiTro.contains('sói thường') ||
        tenVaiTro.contains('sói trưởng') || tenVaiTro.contains('sói nguyền') ||
        localRole == GameRole.werewolf || localRole == GameRole.alphaWolf ||
        localRole == GameRole.cursedWolf) {
      return [
        {'loaiHanhDong': 'CAN', 'moTa': '🐺 Cắn 1 người'},
      ];
    }
    if (tenVaiTro.contains('pháp sư sói') || localRole == GameRole.wolfSorcerer) {
      return [
        {'loaiHanhDong': 'SOI', 'moTa': '🧿 Soi phe 1 người'},
      ];
    }
    if (tenVaiTro.contains('tiên tri') || localRole == GameRole.seer) {
      return [
        {'loaiHanhDong': 'SOI', 'moTa': '🔮 Soi 1 người để biết phe'},
      ];
    }
    if (tenVaiTro.contains('bảo vệ') || localRole == GameRole.guard) {
      return [
        {'loaiHanhDong': 'BAO_VE', 'moTa': '🛡️ Bảo vệ 1 người'},
      ];
    }
    if (tenVaiTro.contains('phù thủy') || localRole == GameRole.witch) {
      return [
        {'loaiHanhDong': 'CHUA', 'moTa': '💚 Cứu người bị cắn (thuốc cứu)'},
        {'loaiHanhDong': 'GIET', 'moTa': '💀 Giết 1 người (thuốc độc)'},
        {'loaiHanhDong': 'KHONG', 'moTa': '😶 Không làm gì'},
      ];
    }
    if (tenVaiTro.contains('cupid') || tenVaiTro.contains('tình yêu') ||
        localRole == GameRole.cupid) {
      return [
        {'loaiHanhDong': 'GHEP_DOI', 'moTa': '💘 Ghép đôi 2 người'},
      ];
    }
    if (tenVaiTro.contains('bác sĩ') || localRole == GameRole.doctor) {
      return [
        {'loaiHanhDong': 'CHUA_TRI', 'moTa': '⚕️ Chữa trị 1 người'},
      ];
    }
    if (tenVaiTro.contains('cáo') || localRole == GameRole.fox) {
      return [
        {'loaiHanhDong': 'KIEM_TRA', 'moTa': '🦊 Kiểm tra 1 nhóm 3 người'},
      ];
    }
    if (tenVaiTro.contains('thần đèn') || localRole == GameRole.genie) {
      return [
        {'loaiHanhDong': 'BAO_VE', 'moTa': '🧞 Chọn 1 người để bảo vệ mình'},
      ];
    }
    if (tenVaiTro.contains('thiếu niên') || localRole == GameRole.littleGirl) {
      return [
        {'loaiHanhDong': 'LEN_NHIN', 'moTa': '👧 Lén nhìn sói (nguy hiểm!)'},
        {'loaiHanhDong': 'KHONG', 'moTa': '😶 Không lén nhìn'},
      ];
    }
    if (tenVaiTro.contains('nguyền rủa') || localRole == GameRole.cursedOne) {
      return [
        {'loaiHanhDong': 'XAC_NHAN', 'moTa': '🌑 Xác nhận trạng thái'},
      ];
    }

    // Default
    return [
      {'loaiHanhDong': 'HANH_DONG', 'moTa': '✨ Thực hiện hành động'},
    ];
  }

  Future<void> _submitAction() async {
    if (_selectedRole == null || _selectedAction == null) return;

    setState(() => _isSubmitting = true);

    // Build local instruction
    final tenVaiTro = _selectedRole!['TenVaiTro'] ?? '';
    final target1Name = _selectedTarget1 != null ? _playerName(_selectedTarget1) : null;
    final target2Name = _selectedTarget2 != null ? _playerName(_selectedTarget2) : null;

    String instruction = '✅ $tenVaiTro đã thực hiện: $_selectedAction';
    if (target2Name != null) {
      instruction += '\n→ Mục tiêu: $target1Name & $target2Name';
    } else if (target1Name != null) {
      instruction += '\n→ Mục tiêu: $target1Name';
    }

    // Small delay for UX feel
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _recordCompletion(instruction);
  }

  void _recordCompletion(String? instruction) {
    setState(() {
      _isSubmitting = false;
      _completedActions.add({
        'role': _selectedRole,
        'action': _selectedAction,
        'target1': _selectedTarget1,
        'target2': _selectedTarget2,
      });
      _soVaiTroDaGoi++;
      _gmInstruction = instruction;
      _selectedAction = null;
      _selectedTarget1 = null;
      _selectedTarget2 = null;
      _selectedRole = null;
      _showCustomPicker = false;
      _availableActions = [];

      if (_currentSuggestionIndex < _thuTuDem.length - 1) {
        _currentSuggestionIndex++;
      }

      if (_soVaiTroDaGoi >= _soVaiTroCanGoi && _soVaiTroCanGoi > 0) {
        _nightComplete = true;
      }
    });
  }

  Future<void> _finishNight() async {
    setState(() => _isLoading = true);

    // In fake mode, just navigate to morning
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/morning', arguments: {
      'maVan': _maVan,
      'soDem': _soDem,
      'nguoiChoi': _nguoiChoi,
    });
  }

  bool _needsSecondTarget(String tenVaiTro) {
    final lower = tenVaiTro.toLowerCase();
    return lower.contains('cupid') || lower.contains('tình yêu') ||
        (_selectedAction == 'GHEP_DOI');
  }

  bool _needsTarget() {
    if (_selectedAction == null) return false;
    // These actions don't need a target
    return _selectedAction != 'KHONG' && _selectedAction != 'XAC_NHAN';
  }

  bool _canSubmit() {
    if (_selectedAction == null) return false;
    // Actions that don't require a target
    if (_selectedAction == 'KHONG' || _selectedAction == 'XAC_NHAN') return true;
    if (_selectedTarget1 == null) return false;
    if (_selectedRole != null) {
      final tenVaiTro =
          (_selectedRole!['TenVaiTro'] ?? '').toString();
      if (_needsSecondTarget(tenVaiTro) && _selectedTarget2 == null) {
        return false;
      }
    }
    return true;
  }

  // ─── BUILD ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showTransition) {
      return PhaseTransition(
        phaseType: 'night',
        phaseNumber: _soDem,
        onComplete: _onTransitionComplete,
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.nightGradient),
        child: SafeArea(
          child: _isLoading ? _buildLoading() : _buildNightHub(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accentPurple),
          SizedBox(height: 16),
          Text('Đang tải...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNightHub() {
    return Column(
      children: [
        _buildHeader(),
        if (_error != null) _buildErrorBanner(),
        if (_gmInstruction != null) _buildGmInstructionBanner(),
        _buildProgressBar(),
        const SizedBox(height: 8),
        Expanded(
          child: _selectedRole != null
              ? _buildActionPanel()
              : _showCustomPicker
                  ? _buildCustomPickerList()
                  : _buildSuggestionList(),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withValues(alpha: 0.15),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.nightlight_round,
                color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ĐÊM $_soDem',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Quản trò gọi từng vai trò',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              '$_soVaiTroDaGoi / $_soVaiTroCanGoi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _nightComplete
                    ? AppColors.accentGreen
                    : AppColors.accentCyan,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  // ─── BANNERS ──────────────────────────────────────────────────────

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.accentRed.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.accentRed, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.accentRed, fontSize: 12)),
            ),
            GestureDetector(
              onTap: () => setState(() => _error = null),
              child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGmInstructionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.accentGreen.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'KẾT QUẢ HÀNH ĐỘNG',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _gmInstruction = null),
                  child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _gmInstruction!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildProgressBar() {
    final progress =
        _soVaiTroCanGoi > 0 ? _soVaiTroDaGoi / _soVaiTroCanGoi : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryMid,
              valueColor: AlwaysStoppedAnimation<Color>(
                _nightComplete ? AppColors.accentGreen : AppColors.accentPurple,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã gọi $_soVaiTroDaGoi / $_soVaiTroCanGoi vai trò',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              if (_nightComplete)
                const Text(
                  '✅ Đã đủ',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SUGGESTION LIST ──────────────────────────────────────────────

  Widget _buildSuggestionList() {
    if (_thuTuDem.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Không tìm thấy vai trò cần gọi',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ấn "Tự chọn vai trò" bên dưới\nđể gọi vai trò thủ công',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _thuTuDem.length,
      itemBuilder: (context, index) {
        final item = _thuTuDem[index];
        final tenVaiTro =
            item['TenVaiTro'] ?? item['tenVaiTro'] ?? 'Vai trò';
        final maNguoiChoi = item['MaNguoiChoi'] ?? item['maNguoiChoi'];
        final tenNguoiChoi = item['TenNguoiChoi']?.toString() ??
            _playerName(maNguoiChoi);
        final emoji = _getRoleEmoji(tenVaiTro.toString());
        final isCompleted = _completedActions.any((a) {
          final role = a['role'] as Map<String, dynamic>?;
          return (role?['MaNguoiChoi'] ?? role?['maNguoiChoi']) == maNguoiChoi;
        });
        final isCurrent = index == _currentSuggestionIndex && !isCompleted;
        final roleColor = _getRoleColor(tenVaiTro.toString());

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            onTap: isCompleted ? null : () => _selectSuggestion(item),
            isSelected: isCurrent,
            borderColor: isCurrent ? roleColor : null,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.accentGreen.withValues(alpha: 0.2)
                        : isCurrent
                            ? roleColor.withValues(alpha: 0.2)
                            : AppColors.primaryMid,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.accentGreen.withValues(alpha: 0.5)
                          : isCurrent
                              ? roleColor.withValues(alpha: 0.5)
                              : AppColors.cardBorder,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check,
                            color: AppColors.accentGreen, size: 18)
                        : Text(emoji, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenVaiTro.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppColors.textMuted
                              : isCurrent
                                  ? roleColor
                                  : AppColors.textPrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Người chơi: $tenNguoiChoi',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted
                              ? AppColors.textMuted
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Icon(
                    isCurrent ? Icons.play_circle_fill : Icons.chevron_right,
                    color: isCurrent ? roleColor : AppColors.textMuted,
                    size: 22,
                  ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (index * 60).ms)
            .slideX(begin: 0.15);
      },
    );
  }

  // ─── CUSTOM ROLE PICKER ──────────────────────────────────────────

  Widget _buildCustomPickerList() {
    final roles = _allRolesForPicker;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.person_search,
                  color: AppColors.accentCyan, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Chọn vai trò muốn gọi:',
                  style: TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showCustomPicker = false),
                child: const Text('Quay lại',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: roles.isEmpty
              ? const Center(
                  child: Text(
                    'Không còn vai trò nào để gọi',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final nc = roles[index];
                    final tenVaiTro =
                        nc['TenVaiTro'] ?? nc['tenVaiTro'] ?? 'Vai trò';
                    final tenNguoiChoi =
                        nc['TenNguoiChoi'] ?? nc['tenNguoiChoi'] ?? '???';
                    final emoji = _getRoleEmoji(tenVaiTro.toString());
                    final roleColor = _getRoleColor(tenVaiTro.toString());

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        onTap: () => _selectFromCustomPicker(nc),
                        borderColor: roleColor,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: roleColor.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: roleColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tenVaiTro.toString(),
                                    style: TextStyle(
                                      color: roleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    tenNguoiChoi.toString(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: roleColor, size: 16),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideX(begin: 0.15);
                  },
                ),
        ),
      ],
    );
  }

  // ─── ACTION PANEL ──────────────────────────────────────────────────

  Widget _buildActionPanel() {
    final tenVaiTro = (_selectedRole!['TenVaiTro'] ??
        _selectedRole!['tenVaiTro'] ?? 'Vai trò').toString();
    final maNguoiChoi =
        _selectedRole!['MaNguoiChoi'] ?? _selectedRole!['maNguoiChoi'];
    final tenNguoiChoi = _selectedRole!['TenNguoiChoi']?.toString() ??
        _playerName(maNguoiChoi);
    final emoji = _getRoleEmoji(tenVaiTro);
    final roleColor = _getRoleColor(tenVaiTro);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Role header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: roleColor.withValues(alpha: 0.5), width: 2),
              gradient: LinearGradient(
                colors: [
                  roleColor.withValues(alpha: 0.15),
                  roleColor.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: roleColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: roleColor.withValues(alpha: 0.2),
                    border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$tenVaiTro thức dậy',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: roleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Người chơi: $tenNguoiChoi',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ).animate().fadeIn().scaleXY(begin: 0.95),

          const SizedBox(height: 14),

          // Action selector
          if (_availableActions.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Chọn hành động:',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            ..._availableActions.map((action) {
              final loai = action['loaiHanhDong']?.toString() ?? '';
              final moTa = action['moTa']?.toString() ?? loai;
              final isSelected = _selectedAction == loai;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GlassCard(
                  onTap: () => setState(() {
                    _selectedAction = loai;
                    _selectedTarget1 = null;
                    _selectedTarget2 = null;
                  }),
                  isSelected: isSelected,
                  borderColor: roleColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            isSelected ? roleColor : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          moTa,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          // Target selector(s) — only show when action needs a target
          if (_selectedAction != null && _needsTarget()) ...[
            const SizedBox(height: 12),
            _buildTargetSelector(1, roleColor),
            if (_needsSecondTarget(tenVaiTro)) ...[
              const SizedBox(height: 12),
              _buildTargetSelector(2, roleColor),
            ],
          ],

          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _canSubmit() && !_isSubmitting ? _submitAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _canSubmit() ? roleColor : AppColors.primaryMid,
                disabledBackgroundColor: AppColors.primaryMid,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _canSubmit() ? 'XÁC NHẬN' : 'Chọn hành động & mục tiêu',
                      style: TextStyle(
                        fontSize: _canSubmit() ? 15 : 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: _canSubmit() ? 2 : 0,
                        color: _canSubmit()
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 4),

          TextButton(
            onPressed: () => setState(() {
              _selectedRole = null;
              _showCustomPicker = false;
              _availableActions = [];
              _selectedAction = null;
              _selectedTarget1 = null;
              _selectedTarget2 = null;
            }),
            child: const Text('← Quay lại danh sách',
                style: TextStyle(color: AppColors.textMuted)),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTargetSelector(int targetNumber, Color roleColor) {
    final label = targetNumber == 1 ? 'Chọn mục tiêu:' : 'Chọn mục tiêu 2:';
    final selectedId =
        targetNumber == 1 ? _selectedTarget1 : _selectedTarget2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ..._alivePlayers.map((player) {
          final id = player['MaNguoiChoi'];
          final name = player['TenNguoiChoi']?.toString() ?? '???';
          final roleName = player['TenVaiTro']?.toString() ?? '';
          final isSelected = selectedId == id;
          final isDisabled = targetNumber == 2 && _selectedTarget1 == id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: GlassCard(
                onTap: isDisabled
                    ? null
                    : () => setState(() {
                          if (targetNumber == 1) {
                            _selectedTarget1 = id;
                          } else {
                            _selectedTarget2 = id;
                          }
                        }),
                isSelected: isSelected,
                borderColor: roleColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? roleColor : AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      roleName,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── BOTTOM BUTTONS ──────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // Custom action button
          if (_selectedRole == null && !_showCustomPicker)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _openCustomPicker,
                  icon: const Icon(Icons.person_add_alt_1, size: 20),
                  label: const Text(
                    'Tự chọn vai trò',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentCyan,
                    side: BorderSide(
                      color: AppColors.accentCyan.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

          // Finish night button
          if (_nightComplete || _soVaiTroDaGoi > 0)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _nightComplete
                        ? _finishNight
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: const Text(
                                  'Kết thúc đêm sớm?',
                                  style:
                                      TextStyle(color: AppColors.textPrimary),
                                ),
                                content: Text(
                                  'Bạn mới gọi $_soVaiTroDaGoi / $_soVaiTroCanGoi vai trò.\nBạn có chắc muốn kết thúc đêm?',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _finishNight();
                                    },
                                    child: const Text(
                                      'Kết thúc',
                                      style: TextStyle(
                                          color: AppColors.accentOrange),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                icon: Icon(
                  _nightComplete ? Icons.check_circle : Icons.skip_next,
                  color: Colors.white,
                  size: 22,
                ),
                label: Text(
                  _nightComplete
                      ? 'HOÀN THÀNH ĐÊM'
                      : 'KẾT THÚC ĐÊM SỚM',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _nightComplete
                      ? AppColors.accentGreen
                      : AppColors.accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ).animate().fadeIn().scaleXY(begin: 0.95),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────

  String _getRoleEmoji(String tenVaiTro) {
    final lower = tenVaiTro.toLowerCase();
    if (lower.contains('bầy sói')) return '🐺';
    if (lower.contains('sói thường') || lower.contains('ma sói')) return '🐺';
    if (lower.contains('sói trưởng')) return '👑';
    if (lower.contains('sói nguyền')) return '💀';
    if (lower.contains('pháp sư sói')) return '🧿';
    if (lower.contains('tiên tri')) return '🔮';
    if (lower.contains('bảo vệ')) return '🛡️';
    if (lower.contains('phù thủy')) return '🧙‍♀️';
    if (lower.contains('thợ săn')) return '🏹';
    if (lower.contains('già làng')) return '👴';
    if (lower.contains('cupid') || lower.contains('tình yêu')) return '💘';
    if (lower.contains('bác sĩ')) return '⚕️';
    if (lower.contains('thiếu niên')) return '👧';
    if (lower.contains('nguyền rủa') || lower.contains('kẻ bị nguyền')) {
      return '🌑';
    }
    if (lower.contains('hầu gái')) return '🎭';
    if (lower.contains('thần đèn')) return '🧞';
    if (lower.contains('cáo')) return '🦊';
    if (lower.contains('dân')) return '👤';
    if (lower.contains('sói')) return '🐺';
    return '🎭';
  }

  Color _getRoleColor(String tenVaiTro) {
    final lower = tenVaiTro.toLowerCase();
    if (lower.contains('sói')) return AppColors.accentRed;
    if (lower.contains('tiên tri')) return AppColors.accentPurple;
    if (lower.contains('bảo vệ')) return AppColors.accentBlue;
    if (lower.contains('phù thủy')) return AppColors.accentPink;
    if (lower.contains('thợ săn')) return AppColors.accentOrange;
    if (lower.contains('cupid') || lower.contains('tình yêu')) {
      return const Color(0xFFF472B6);
    }
    if (lower.contains('bác sĩ')) return AppColors.accentCyan;
    if (lower.contains('thần đèn')) return AppColors.accentPurple;
    if (lower.contains('cáo')) return const Color(0xFFC084FC);
    if (lower.contains('nguyền rủa')) return AppColors.accentOrange;
    return AppColors.accentPurple;
  }
}
