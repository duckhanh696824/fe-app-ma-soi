import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Lớp xử lý lỗi API – ném ra khi server trả status khác 2xx.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  ApiException({required this.statusCode, required this.message, this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client wrapper – cung cấp GET / POST / PUT / DELETE
/// và tự động parse JSON response.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ── Helpers ─────────────────────────────────────────────────────────

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams == null || queryParams.isEmpty) return uri;

    final query = queryParams.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    return uri.replace(queryParameters: query);
  }

  /// Kiểm tra response và parse body JSON.
  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body is Map ? (body['loiMessage'] ?? body['message'] ?? 'Lỗi không xác định') : 'Lỗi không xác định',
      body: body,
    );
  }

  // ── Public methods ──────────────────────────────────────────────────

  /// HTTP GET
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    final mergedHeaders = {...ApiConfig.defaultHeaders, ...?headers};
    final response = await _client
        .get(_buildUri(path, queryParams), headers: mergedHeaders)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// HTTP POST
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final mergedHeaders = {...ApiConfig.defaultHeaders, ...?headers};
    final response = await _client
        .post(
          _buildUri(path),
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// HTTP PUT
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final mergedHeaders = {...ApiConfig.defaultHeaders, ...?headers};
    final response = await _client
        .put(
          _buildUri(path),
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// HTTP DELETE
  Future<dynamic> delete(String path, {Map<String, String>? headers}) async {
    final mergedHeaders = {...ApiConfig.defaultHeaders, ...?headers};
    final response = await _client
        .delete(_buildUri(path), headers: mergedHeaders)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  /// Giải phóng tài nguyên.
  void dispose() {
    _client.close();
  }
}
