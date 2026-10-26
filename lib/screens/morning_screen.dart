import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api/api_client.dart';
import '../api/dem_xu_ly_api.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/phase_transition.dart';

/// Morning screen — shows phase transition then night results from API.
///
/// Receives arguments: { maVan, soDem, nguoiChoi }
class MorningScreen extends StatefulWidget {
  const MorningScreen({super.key});

  @override
  State<MorningScreen> createState() => _MorningScreenState();
}

class _MorningScreenState extends State<MorningScreen> {
  bool _showTransition = true;
  bool _initialized = false;

  late int _maVan;
  late int _soDem;
  late List<Map<String, dynamic>> _nguoiChoi;

  // Results from API
  List<Map<String, dynamic>> _deaths = [];
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String? _error;

  final _apiClient = ApiClient();
  late DemXuLyApi _demXuLyApi;

  @override
  void initState() {
    super.initState();
    _demXuLyApi = DemXuLyApi(_apiClient);
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
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await _demXuLyApi.layKetQuaDem(_maVan, _soDem);
      if (!mounted) return;

      if (resp is Map) {
        final data = resp['data'] ?? resp;
        if (data is Map) {
          _deaths = _parseList(data['nguoiChet'] ?? data['deaths'] ?? []);
          _events = _parseList(data['suKien'] ?? data['events'] ?? []);
        }
      } else if (resp is List) {
        _deaths = _parseList(resp);
      }

      // Update nguoiChoi status based on deaths
      for (final death in _deaths) {
        final maNguoiChoi = death['MaNguoiChoi'] ?? death['maNguoiChoi'];
        if (maNguoiChoi != null) {
          final idx = _nguoiChoi.indexWhere(
            (nc) => nc['MaNguoiChoi'] == maNguoiChoi,
          );
          if (idx != -1) {
            _nguoiChoi[idx]['TrangThai'] = 'CHET';
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Không thể tải kết quả đêm: $e';
      });
    }
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  int get _aliveCount =>
      _nguoiChoi.where((nc) => nc['TrangThai'] != 'CHET').length;

  @override
  Widget build(BuildContext context) {
    if (_showTransition) {
      return PhaseTransition(
        phaseType: 'morning',
        phaseNumber: _soDem,
        onComplete: _onTransitionComplete,
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF312E81),
              Color(0xFF4C1D95),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoading() : _buildResults(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text('Đang tải kết quả...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Title
          Text(
            'KẾT QUẢ ĐÊM $_soDem',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 20),

          // Error
          if (_error != null)
            GlassCard(
              borderColor: AppColors.accentRed,
              isSelected: true,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.accentRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.accentRed, fontSize: 13))),
                ],
              ),
            ),

          // Deaths
          Expanded(
            child: ListView(
              children: [
                if (_deaths.isEmpty)
                  GlassCard(
                    borderColor: AppColors.accentGreen,
                    isSelected: true,
                    child: Column(
                      children: [
                        const Icon(Icons.shield,
                            color: AppColors.accentGreen, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Đêm qua không ai bị giết!',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).scaleXY(begin: 0.8)
                else
                  ..._deaths.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final death = entry.value;
                    final name = death['TenNguoiChoi'] ??
                        death['tenNguoiChoi'] ??
                        'Không rõ';
                    final reason = death['LyDo'] ??
                        death['lyDo'] ??
                        death['nguyenNhan'] ??
                        'Đã bị giết trong đêm';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        borderColor: AppColors.accentRed,
                        isSelected: true,
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentRed.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: AppColors.accentRed.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Center(
                                child: Text('💀', style: TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reason.toString(),
                                    style: const TextStyle(
                                      color: AppColors.accentRed,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (300 + idx * 200).ms)
                        .slideX(begin: -0.3)
                        .shake(
                          delay: (500 + idx * 200).ms,
                          hz: 2,
                          rotation: 0.02,
                        );
                  }),

                const SizedBox(height: 12),

                // Events
                ..._events.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final event = entry.value;
                  final text = event['moTa'] ??
                      event['noiDung'] ??
                      event.toString();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.accentCyan, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              text.toString(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (600 + idx * 150).ms);
                }),
              ],
            ),
          ),

          // Alive count
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people,
                    color: AppColors.accentGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Còn sống: $_aliveCount người',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Continue to day
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/day', arguments: {
                  'maVan': _maVan,
                  'soDem': _soDem,
                  'nguoiChoi': _nguoiChoi,
                });
              },
              icon: const Icon(Icons.wb_sunny, color: Colors.white),
              label: const Text(
                'BẮT ĐẦU THẢO LUẬN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
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
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}
