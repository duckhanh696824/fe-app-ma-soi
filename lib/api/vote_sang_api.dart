import 'api_client.dart';
import 'api_config.dart';

/// API service cho nhóm Vote Sáng.
/// Map từ: voteSang.routes.js — 4 endpoints.
class VoteSangApi {
  final ApiClient _client;

  VoteSangApi(this._client);

  /// POST /vote-sang/de-cu — Bước 1: Đề cử người để treo cổ.
  ///
  /// [luotVote] = 1 hoặc 2 (nếu có Kẻ Phá Rối).
  Future<dynamic> deCuTreoCo({
    required int maVan,
    required int soNgay,
    required int maNguoiBiDeCu,
    int? luotVote,
  }) {
    final body = <String, dynamic>{
      'maVan': maVan,
      'soNgay': soNgay,
      'maNguoiBiDeCu': maNguoiBiDeCu,
    };
    if (luotVote != null) body['luotVote'] = luotVote;
    return _client.post('${ApiConfig.voteSang}/de-cu', body: body);
  }

  /// PUT /vote-sang/ket-qua/:maVote — Bước 2: Kết quả vote (TREO_CO / THA / BO_QUA).
  Future<dynamic> ketQuaVote(int maVote, String ketQua) {
    return _client.put(
      '${ApiConfig.voteSang}/ket-qua/$maVote',
      body: {'ketQua': ketQua},
    );
  }

  /// GET /vote-sang/lich-su/:maVan — Lấy lịch sử vote của ván.
  ///
  /// [soNgay] tùy chọn, lọc theo ngày.
  Future<dynamic> layLichSuVote(int maVan, {int? soNgay}) {
    final query = <String, dynamic>{};
    if (soNgay != null) query['soNgay'] = soNgay;

    return _client.get(
      '${ApiConfig.voteSang}/lich-su/$maVan',
      queryParams: query.isNotEmpty ? query : null,
    );
  }

  /// GET /vote-sang/chung-cuoc/:maVan — Kiểm tra kết quả chung cuộc (phe nào thắng).
  Future<dynamic> kiemTraChungCuoc(int maVan) {
    return _client.get('${ApiConfig.voteSang}/chung-cuoc/$maVan');
  }
}
