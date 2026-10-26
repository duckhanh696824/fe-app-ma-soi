/// Cấu hình chung cho API backend Ma Sói.
class ApiConfig {
  // ── Base URL ──────────────────────────────────────────────────────────
  // Đổi thành IP / domain thật khi deploy.
  // Trên Android emulator dùng 10.0.2.2, trên thiết bị thật dùng IP LAN.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ── Server URL (dùng cho static files: images, etc.) ───────────────
  static const String serverUrl = 'http://10.0.2.2:3000';

  // ── Timeout ───────────────────────────────────────────────────────────
  static const Duration timeout = Duration(seconds: 15);

  // ── Headers mặc định ─────────────────────────────────────────────────
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Đường dẫn nhóm API ───────────────────────────────────────────────
  static const String vaiTro = '/vai-tro';
  static const String vanChoi = '/van-choi';
  static const String nguoiChoi = '/nguoi-choi';
  static const String demXuLy = '/dem-xu-ly';
  static const String voteSang = '/vote-sang';
  static const String taiKhoan = '/tai-khoan';
}
