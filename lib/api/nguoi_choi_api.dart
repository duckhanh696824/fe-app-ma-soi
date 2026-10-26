import 'api_client.dart';
import 'api_config.dart';

/// API service cho nhóm Người Chơi.
/// Map từ: nguoiChoi.routes.js — 5 endpoints.
class NguoiChoiApi {
  final ApiClient _client;

  NguoiChoiApi(this._client);

  /// POST /nguoi-choi/tao-danh-sach — Thêm danh sách người chơi (kèm vai trò) vào ván.
  ///
  /// [danhSachNguoiChoi] là danh sách các map, mỗi phần tử gồm:
  ///   - `tenNguoiChoi` (String, bắt buộc)
  ///   - `maVaiTro` (int?, tùy chọn)
  Future<dynamic> themDanhSachNguoiChoi({
    required int maVan,
    required List<Map<String, dynamic>> danhSachNguoiChoi,
  }) {
    return _client.post(
      '${ApiConfig.nguoiChoi}/tao-danh-sach',
      body: {
        'maVan': maVan,
        'danhSachNguoiChoi': danhSachNguoiChoi,
      },
    );
  }

  /// POST /nguoi-choi — Thêm 1 người chơi vào ván.
  Future<dynamic> themNguoiChoi({
    required int maVan,
    required String tenNguoiChoi,
    int? maVaiTro,
  }) {
    final body = <String, dynamic>{
      'maVan': maVan,
      'tenNguoiChoi': tenNguoiChoi,
    };
    if (maVaiTro != null) body['maVaiTro'] = maVaiTro;
    return _client.post(ApiConfig.nguoiChoi, body: body);
  }

  /// PUT /nguoi-choi/:maNguoiChoi/vai-tro — Gán/đổi vai trò cho người chơi.
  Future<dynamic> ganVaiTro(int maNguoiChoi, int maVaiTro) {
    return _client.put(
      '${ApiConfig.nguoiChoi}/$maNguoiChoi/vai-tro',
      body: {'maVaiTro': maVaiTro},
    );
  }

  /// GET /nguoi-choi/van/:maVan — Lấy danh sách người chơi theo ván.
  Future<dynamic> layDanhSachNguoiChoi(int maVan) {
    return _client.get('${ApiConfig.nguoiChoi}/van/$maVan');
  }

  /// GET /nguoi-choi/hanh-dong-vai-tro/:maVaiTro — Lấy hành động có thể thực hiện của vai trò.
  ///
  /// Truyền thêm [maVan], [maNguoiChoi], [soDem] để kiểm tra chức năng đã dùng.
  Future<dynamic> layHanhDongVaiTro(
    int maVaiTro, {
    int? maVan,
    int? maNguoiChoi,
    int? soDem,
  }) {
    final query = <String, dynamic>{};
    if (maVan != null) query['maVan'] = maVan;
    if (maNguoiChoi != null) query['maNguoiChoi'] = maNguoiChoi;
    if (soDem != null) query['soDem'] = soDem;

    return _client.get(
      '${ApiConfig.nguoiChoi}/hanh-dong-vai-tro/$maVaiTro',
      queryParams: query.isNotEmpty ? query : null,
    );
  }
}
