import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_model.dart';

/// ============================================================================
/// [DATA LAYER - REMOTE SERVICE] - ApiService
/// Vai trò:
/// - Chịu trách nhiệm giao tiếp HTTP RESTful API ra bên ngoài mạng.
/// - Gọi endpoint tỷ giá hối đoái trực tuyến: https://open.er-api.com/v6/latest/USD
/// - Xử lý mã trạng thái HTTP, timeout và các ngoại lệ mạng (SocketException, TimeoutException).
/// - Trả về dữ liệu thô đã parse thành Model, hoàn toàn tách biệt khỏi UI & State.
/// ============================================================================

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message ${statusCode != null ? "(Code: $statusCode)" : ""}';
}

class ApiService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest/USD';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Lấy tỷ giá hối đoái mới nhất từ Open Exchange Rates API
  Future<ExchangeRateModel> fetchExchangeRates() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await _client.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return ExchangeRateModel.fromJson(response.body);
      } else {
        throw ApiException(
          'Không thể lấy dữ liệu tỷ giá từ máy chủ.',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Không có kết nối mạng. Vui lòng kiểm tra lại Internet.');
    } on TimeoutException {
      throw ApiException('Quá thời gian kết nối đến máy chủ tỷ giá.');
    } on FormatException {
      throw ApiException('Dữ liệu phản hồi từ máy chủ không hợp lệ.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Đã xảy ra lỗi không xác định: $e');
    }
  }

  /// Giải phóng tài nguyên client khi không dùng nữa
  void dispose() {
    _client.close();
  }
}
