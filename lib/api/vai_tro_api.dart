import 'api_client.dart';
import 'api_config.dart';

/// API service cho nhóm Vai Trò.
/// Map từ: vaiTro.routes.js — 2 endpoints.
class VaiTroApi {
  final ApiClient _client;

  VaiTroApi(this._client);

  /// GET /vai-tro — Lấy danh sách tất cả vai trò.
  Future<dynamic> layDanhSachVaiTro() {
    return _client.get(ApiConfig.vaiTro);
  }

  /// GET /vai-tro/:maVaiTro — Lấy chi tiết vai trò theo mã.
  Future<dynamic> layChiTietVaiTro(int maVaiTro) {
    return _client.get('${ApiConfig.vaiTro}/$maVaiTro');
  }

  /// GET /vai-tro/danh-sach-ngan — Lấy danh sách vai trò ngắn gọn (chỉ MaVaiTro + TenVaiTro).
  Future<dynamic> layDanhSachVaiTroNgan() {
    return _client.get('${ApiConfig.vaiTro}/danh-sach-ngan');
  }
}
