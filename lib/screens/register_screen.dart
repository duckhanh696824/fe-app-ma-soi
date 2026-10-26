import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/mystical_bg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();

    await Future.delayed(const Duration(milliseconds: 800));

    final error = auth.register(
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
      _confirmPasswordController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticalBackground(
        gradient: AppColors.enchantedGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCyan.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 50,
                        color: AppColors.accentCyan,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                            begin: 0.95,
                            end: 1.05,
                            duration: 3.seconds,
                            curve: Curves.easeInOut),

                    const SizedBox(height: 24),

                    const Text(
                      'ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppColors.accentCyan,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

                    const SizedBox(height: 8),
                    Text(
                      'Tạo tài khoản mới để quản lý ván chơi',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                    const SizedBox(height: 36),

                    // Error
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
                              child: Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: AppColors.accentRed, fontSize: 13)),
                            ),
                          ],
                        ),
                      ).animate().shake(duration: 400.ms),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                    const SizedBox(height: 14),

                    // Username
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập username';
                        }
                        if (v.trim().length < 3) {
                          return 'Username phải có ít nhất 3 ký tự';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

                    const SizedBox(height: 14),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu (ít nhất 6 ký tự)',
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
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (v.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),

                    const SizedBox(height: 14),

                    // Confirm password
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu',
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (v != _passwordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),

                    const SizedBox(height: 28),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor:
                              AppColors.accentCyan.withValues(alpha: 0.5),
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
                                'ĐĂNG KÝ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã có tài khoản? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: AppColors.accentCyan,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),

                    const SizedBox(height: 16),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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
              const BorderSide(color: AppColors.accentCyan, width: 2),
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
