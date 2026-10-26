import 'package:flutter/material.dart';

/// Mock auth provider — UI-only, no API calls.
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';
  bool _isGuest = false;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;
  bool get isGuest => _isGuest;

  /// Mock đăng nhập
  String? login(String identifier, String password) {
    // Validate
    if (identifier.trim().isEmpty) {
      return 'Vui lòng nhập email hoặc username';
    }
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    // Mock success
    _isLoggedIn = true;
    _isGuest = false;
    if (identifier.contains('@')) {
      _email = identifier.trim();
      _username = identifier.split('@').first;
    } else {
      _username = identifier.trim();
      _email = '${identifier.trim()}@masoi.app';
    }
    notifyListeners();
    return null; // null = success
  }

  /// Mock đăng ký
  String? register(String email, String username, String password, String confirmPassword) {
    if (email.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim())) {
      return 'Email không hợp lệ';
    }
    if (username.trim().isEmpty) {
      return 'Vui lòng nhập username';
    }
    if (username.trim().length < 3) {
      return 'Username phải có ít nhất 3 ký tự';
    }
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (password != confirmPassword) {
      return 'Mật khẩu xác nhận không khớp';
    }

    // Mock success
    _isLoggedIn = true;
    _isGuest = false;
    _email = email.trim();
    _username = username.trim();
    notifyListeners();
    return null; // null = success
  }

  /// Chơi không cần đăng nhập
  void playAsGuest() {
    _isLoggedIn = false;
    _isGuest = true;
    _username = 'Khách';
    _email = '';
    notifyListeners();
  }

  /// Đăng xuất
  void logout() {
    _isLoggedIn = false;
    _isGuest = false;
    _username = '';
    _email = '';
    notifyListeners();
  }
}
