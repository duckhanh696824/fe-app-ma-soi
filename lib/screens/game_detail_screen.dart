import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api/api_client.dart';
import '../api/vai_tro_api.dart';
import '../models/game_role.dart';
import '../theme/app_colors.dart';
import '../widgets/mystical_bg.dart';
import '../widgets/glass_card.dart';
import '../widgets/win_conditions_dialog.dart';

class GameDetailScreen extends StatefulWidget {
  const GameDetailScreen({super.key});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  // ignore: unused_field
  late int _gameId;
  late String _gameName;
  late int _playerCount;
  late List<TextEditingController> _nameControllers;
  late List<GameRole?> _selectedRoles;
  bool _initialized = false;
  bool _isStarting = false;

  final _apiClient = ApiClient();
  late VaiTroApi _vaiTroApi;

  // Role name → maVaiTro mapping from API
  final Map<String, int> _roleIdMap = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _gameId = args['gameId'] as int;
      _gameName = args['gameName'] as String;
      _playerCount = args['playerCount'] as int;
      _nameControllers =
          List.generate(_playerCount, (_) => TextEditingController());
      _selectedRoles = List.filled(_playerCount, null);
      _vaiTroApi = VaiTroApi(_apiClient);
      _initialized = true;
      _loadRoleMapping();
    }
  }

  /// Fetch role list from API to get correct maVaiTro IDs
  Future<void> _loadRoleMapping() async {
    try {
      final resp = await _vaiTroApi.layDanhSachVaiTro();
      if (!mounted) return;

      List<Map<String, dynamic>> roles = [];
      if (resp is List) {
        roles = resp.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else if (resp is Map && resp['data'] is List) {
        roles = (resp['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      final map = <String, int>{};
      for (final role in roles) {
        final name = (role['TenVaiTro'] ?? role['tenVaiTro'] ?? '').toString().toLowerCase();
        final id = role['MaVaiTro'] ?? role['maVaiTro'];
        if (name.isNotEmpty && id is int) {
          map[name] = id;
        }
      }
      if (mounted) {
        setState(() {
          _roleIdMap.clear();
          _roleIdMap.addAll(map);
        });
      }
    } catch (_) {
      // Will fallback to index+1 if API unavailable
    }
  }

  /// Get the API maVaiTro for a given GameRole
  int _getMaVaiTro(GameRole role) {
    final displayName = role.displayName.toLowerCase();
    // Try exact match
    if (_roleIdMap.containsKey(displayName)) {
      return _roleIdMap[displayName]!;
    }
    // Try partial match
    for (final entry in _roleIdMap.entries) {
      if (entry.key.contains(displayName) || displayName.contains(entry.key)) {
        return entry.value;
      }
    }
    // Fallback: index + 1
    return role.index + 1;
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canStart {
    for (int i = 0; i < _playerCount; i++) {
      if (_nameControllers[i].text.trim().isEmpty || _selectedRoles[i] == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _handleStart() async {
    if (!_canStart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tên và chọn vai trò cho tất cả người chơi'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isStarting = true);

    // Build local player list (fake mode — no API call)
    final nguoiChoi = <Map<String, dynamic>>[];
    for (int i = 0; i < _playerCount; i++) {
      final role = _selectedRoles[i]!;
      nguoiChoi.add({
        'MaNguoiChoi': i + 1, // Fake ID
        'TenNguoiChoi': _nameControllers[i].text.trim(),
        'MaVaiTro': _getMaVaiTro(role),
        'TenVaiTro': role.displayName,
        'TrangThai': 'SONG',
      });
    }

    // Navigate to night screen with local data
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/night', arguments: {
      'maVan': _gameId,
      'soDem': 1,
      'nguoiChoi': nguoiChoi,
    });
  }

  void _showRoleBottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Chọn Vai Trò',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: GameRole.values.length,
                    itemBuilder: (ctx, roleIndex) {
                      final role = GameRole.values[roleIndex];
                      final isSelected = _selectedRoles[index] == role;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRoles[index] = role;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isSelected
                                  ? role.color.withValues(alpha: 0.15)
                                  : AppColors.surface,
                              border: Border.all(
                                color: isSelected
                                    ? role.color.withValues(alpha: 0.6)
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: role.color.withValues(alpha: 0.2),
                                    border: Border.all(
                                      color: role.color.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      role.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        role.displayName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? role.color
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        role.team.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: role.team.color
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: role.color,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticalBackground(
        particleCount: 15,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface.withValues(alpha: 0.8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _gameName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentGreen,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Đang chơi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.people, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '$_playerCount người',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment, color: AppColors.accentCyan, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tiến độ: ${_selectedRoles.where((r) => r != null).length}/$_playerCount người đã gán vai',
                              style: TextStyle(
                                fontSize: 13,
                                color: _canStart
                                    ? AppColors.accentGreen
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _selectedRoles
                                        .where((r) => r != null)
                                        .length /
                                    _playerCount,
                                backgroundColor:
                                    AppColors.primaryMid,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _canStart
                                      ? AppColors.accentGreen
                                      : AppColors.accentPurple,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              // Player list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _playerCount,
                  itemBuilder: (context, index) {
                    final role = _selectedRoles[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        borderColor: role?.color,
                        isSelected: role != null,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Player number
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: role != null
                                    ? LinearGradient(colors: [
                                        role.color.withValues(alpha: 0.6),
                                        role.color.withValues(alpha: 0.3),
                                      ])
                                    : AppColors.purpleGradient,
                              ),
                              child: Center(
                                child: role != null
                                    ? Text(role.emoji,
                                        style: const TextStyle(fontSize: 16))
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name input
                            Expanded(
                              child: TextFormField(
                                controller: _nameControllers[index],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Người chơi ${index + 1}',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            // Role selector
                            GestureDetector(
                              onTap: () => _showRoleBottomSheet(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: role != null
                                      ? role.color.withValues(alpha: 0.15)
                                      : AppColors.primaryMid,
                                  border: Border.all(
                                    color: role != null
                                        ? role.color.withValues(alpha: 0.5)
                                        : AppColors.cardBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      role?.displayName ?? 'Chọn vai',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: role?.color ??
                                            AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.expand_more,
                                      size: 16,
                                      color: role?.color ??
                                          AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (300 + index * 60).ms, duration: 400.ms)
                        .slideX(begin: 0.15);
                  },
                ),
              ),

              // Start button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // View rules button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () => WinConditionsDialog.show(context),
                        icon: const Text('📜', style: TextStyle(fontSize: 16)),
                        label: const Text(
                          'Xem luật chơi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentCyan,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.accentCyan.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canStart && !_isStarting ? _handleStart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canStart && !_isStarting
                              ? AppColors.accentGreen
                              : AppColors.primaryMid,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: _canStart ? 8 : 0,
                          shadowColor:
                              AppColors.accentGreen.withValues(alpha: 0.5),
                        ),
                        child: _isStarting
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '🎮 BẮT ĐẦU GAME',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: _canStart
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }
}
