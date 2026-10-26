import 'api_client.dart';
import 'api_config.dart';

/// API service cho nhóm Ván Chơi.
/// Map từ: vanChoi.routes.js — 4 endpoints.
class VanChoiApi {
  final ApiClient _client;

  VanChoiApi(this._client);

  /// POST /van-choi — Tạo ván chơi mới.
  Future<dynamic> taoVanChoi({
    required String tenVan,
    required int soLuongNguoiChoi,
  }) {
    return _client.post(
      ApiConfig.vanChoi,
      body: {
        'tenVan': tenVan,
        'soLuongNguoiChoi': soLuongNguoiChoi,
      },
    );
  }

  /// GET /van-choi — Lấy danh sách ván chơi.
  Future<dynamic> layDanhSachVan() {
    return _client.get(ApiConfig.vanChoi);
  }

  /// GET /van-choi/:maVan — Lấy thông tin chi tiết ván + danh sách người chơi.
  Future<dynamic> layThongTinVan(int maVan) {
    return _client.get('${ApiConfig.vanChoi}/$maVan');
  }

  /// PUT /van-choi/:maVan/trang-thai — Cập nhật trạng thái ván.
  Future<dynamic> capNhatTrangThaiVan(int maVan, String trangThai) {
    return _client.put(
      '${ApiConfig.vanChoi}/$maVan/trang-thai',
      body: {'trangThai': trangThai},
    );
  }
}
