import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/mystical_bg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 800));

    final error = auth.login(
      _identifierController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _handleGuest() {
    context.read<AuthProvider>().playAsGuest();
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticalBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Moon icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.4),
                            blurRadius: 50,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.nightlight_round,
                        size: 60,
                        color: AppColors.accentPurple,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                            begin: 0.95,
                            end: 1.05,
                            duration: 3.seconds,
                            curve: Curves.easeInOut)
                        .shimmer(
                            duration: 3.seconds,
                            color: AppColors.accentCyan.withValues(alpha: 0.3)),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppColors.accentPurple,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng trở lại Ma Sói',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                    const SizedBox(height: 40),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.accentRed.withValues(alpha: 0.15),
                          border: Border.all(
                              color: AppColors.accentRed.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.accentRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.accentRed,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(duration: 400.ms),

                    // Email/Username field
                    _buildTextField(
                      controller: _identifierController,
                      label: 'Email hoặc Username',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email hoặc username';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                    const SizedBox(height: 16),

                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

                    const SizedBox(height: 28),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor:
                              AppColors.accentPurple.withValues(alpha: 0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'ĐĂNG NHẬP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                    const SizedBox(height: 20),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/register'),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                              color: AppColors.accentPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),

                    const SizedBox(height: 32),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.cardBorder,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'HOẶC',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.cardBorder,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 24),

                    // Guest play button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _handleGuest,
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'CHƠI NGAY',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentCyan,
                          side: BorderSide(
                            color: AppColors.accentCyan.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.accentPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
