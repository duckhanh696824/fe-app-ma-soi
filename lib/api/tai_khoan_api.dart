import 'api_client.dart';
import 'api_config.dart';

/// API service cho nhóm Tài Khoản.
/// Map từ: taiKhoan.routes.js — 3 endpoints.
class TaiKhoanApi {
  final ApiClient _client;

  TaiKhoanApi(this._client);

  /// POST /tai-khoan/dang-ky — Đăng ký tài khoản mới.
  Future<dynamic> dangKy({
    required String email,
    required String username,
    required String matKhau,
    required String xacNhanMatKhau,
  }) {
    return _client.post(
      '${ApiConfig.taiKhoan}/dang-ky',
      body: {
        'email': email,
        'username': username,
        'matKhau': matKhau,
        'xacNhanMatKhau': xacNhanMatKhau,
      },
    );
  }

  /// POST /tai-khoan/dang-nhap — Đăng nhập (bằng email hoặc username).
  Future<dynamic> dangNhap({
    required String taiKhoan,
    required String matKhau,
  }) {
    return _client.post(
      '${ApiConfig.taiKhoan}/dang-nhap',
      body: {
        'taiKhoan': taiKhoan,
        'matKhau': matKhau,
      },
    );
  }

  /// GET /tai-khoan/thong-tin — Lấy thông tin tài khoản đang đăng nhập.
  ///
  /// Cần truyền [token] (Bearer auth) để gọi API này.
  Future<dynamic> layThongTin(String token) {
    return _client.get(
      '${ApiConfig.taiKhoan}/thong-tin',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
