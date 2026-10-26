import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Mystical full-screen image viewer with zoom & pan.
/// Shows a hero-animated image with dark overlay, glow effects,
/// and pinch-to-zoom support.
class MysticalImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final String? title;
  final Color accentColor;

  const MysticalImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.title,
    this.accentColor = AppColors.accentPurple,
  });

  /// Opens the viewer with a hero animation from the source widget.
  static void open(
    BuildContext context, {
    required String imageUrl,
    required String heroTag,
    String? title,
    Color accentColor = AppColors.accentPurple,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return MysticalImageViewer(
            imageUrl: imageUrl,
            heroTag: heroTag,
            title: title,
            accentColor: accentColor,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<MysticalImageViewer> createState() => _MysticalImageViewerState();
}

class _MysticalImageViewerState extends State<MysticalImageViewer> {
  final TransformationController _transformController =
      TransformationController();
  bool _isZoomed = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_isZoomed) {
      _transformController.value = Matrix4.identity();
    } else {
      final size = MediaQuery.of(context).size;
      final matrix = Matrix4.identity();
      matrix.setEntry(0, 3, -size.width / 4);
      matrix.setEntry(1, 3, -size.height / 4);
      matrix.setEntry(0, 0, 2.0);
      matrix.setEntry(1, 1, 2.0);
      _transformController.value = matrix;
    }
    setState(() => _isZoomed = !_isZoomed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Background glow ───
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    widget.accentColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Interactive image area ───
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            onDoubleTap: _onDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionEnd: (details) {
                setState(() {
                  _isZoomed =
                      _transformController.value.getMaxScaleOnAxis() > 1.1;
                });
              },
              child: Center(
                child: Hero(
                  tag: widget.heroTag,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: -8,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 250,
                          height: 380,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.accentColor.withValues(alpha: 0.3),
                                widget.accentColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textMuted,
                              size: 48,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        final progress = loadingProgress.expectedTotalBytes !=
                                null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null;
                        return Container(
                          width: 250,
                          height: 380,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.accentColor.withValues(alpha: 0.15),
                                widget.accentColor.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              color: widget.accentColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Top bar: close button + title ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Close button
                    _GlowIconButton(
                      icon: Icons.close,
                      color: widget.accentColor,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    if (widget.title != null)
                      Expanded(
                        child: Text(
                          widget.title!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            shadows: [
                              Shadow(
                                color: widget.accentColor.withValues(alpha: 0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Bottom hint ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withValues(alpha: 0.4),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isZoomed
                              ? Icons.zoom_out
                              : Icons.zoom_in,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isZoomed
                              ? 'Chạm 2 lần để thu nhỏ'
                              : 'Phóng to bằng 2 ngón hoặc chạm 2 lần',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlowIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
