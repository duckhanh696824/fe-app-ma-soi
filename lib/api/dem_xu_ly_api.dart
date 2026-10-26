import 'api_client.dart';
import 'api_config.dart';

/// API service cho nhóm Xử Lý Đêm.
/// Map từ: demXuLy.routes.js — 6 endpoints.
class DemXuLyApi {
  final ApiClient _client;

  DemXuLyApi(this._client);

  /// POST /dem-xu-ly/hanh-dong — Thêm hành động ban đêm.
  ///
  /// [maNguoiMucTieu2] dùng cho Thần Tình Yêu (ghép đôi) hoặc Du Côn (chỉ định 2 người).
  /// [loaiHanhDong] lấy từ GET /api/nguoi-choi/hanh-dong-vai-tro/:maVaiTro.
  Future<dynamic> themHanhDongDem({
    required int maVan,
    required int soDem,
    required int maNguoiThucHien,
    required String loaiHanhDong,
    int? maNguoiMucTieu,
    int? maNguoiMucTieu2,
  }) {
    final body = <String, dynamic>{
      'maVan': maVan,
      'soDem': soDem,
      'maNguoiThucHien': maNguoiThucHien,
      'loaiHanhDong': loaiHanhDong,
    };
    if (maNguoiMucTieu != null) body['maNguoiMucTieu'] = maNguoiMucTieu;
    if (maNguoiMucTieu2 != null) body['maNguoiMucTieu2'] = maNguoiMucTieu2;

    return _client.post('${ApiConfig.demXuLy}/hanh-dong', body: body);
  }

  /// POST /dem-xu-ly/xu-ly/:maVan — Xử lý đêm (tính kết quả: ai chết, ai sống, lý do).
  ///
  /// [boQuaKiemTra] = true để bỏ qua kiểm tra vai trò đã hành động chưa.
  Future<dynamic> xuLyDem(
    int maVan, {
    required int soDem,
    bool boQuaKiemTra = false,
  }) {
    return _client.post(
      '${ApiConfig.demXuLy}/xu-ly/$maVan',
      body: {
        'soDem': soDem,
        'boQuaKiemTra': boQuaKiemTra,
      },
    );
  }

  /// GET /dem-xu-ly/thu-tu/:maVan/:soDem — Gợi ý thứ tự hành động đêm.
  Future<dynamic> layThuTuDem(int maVan, int soDem) {
    return _client.get('${ApiConfig.demXuLy}/thu-tu/$maVan/$soDem');
  }

  /// GET /dem-xu-ly/trang-thai/:maVan/:soDem — Kiểm tra trạng thái đêm.
  Future<dynamic> kiemTraTrangThaiDem(int maVan, int soDem) {
    return _client.get('${ApiConfig.demXuLy}/trang-thai/$maVan/$soDem');
  }

  /// GET /dem-xu-ly/ket-qua/:maVan/:soDem — Lấy kết quả đêm (hiển thị buổi sáng).
  Future<dynamic> layKetQuaDem(int maVan, int soDem) {
    return _client.get('${ApiConfig.demXuLy}/ket-qua/$maVan/$soDem');
  }

  /// GET /dem-xu-ly/hanh-dong/:maVan/:soDem — Lấy danh sách hành động trong đêm.
  Future<dynamic> layHanhDongDem(int maVan, int soDem) {
    return _client.get('${ApiConfig.demXuLy}/hanh-dong/$maVan/$soDem');
  }
}
