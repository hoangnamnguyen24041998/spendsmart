import 'package:flutter/foundation.dart';
import '../models/exchange_rate_model.dart';
import '../repositories/transaction_repository.dart';
import 'transaction_viewmodel.dart';

/// ============================================================================
/// [VIEWMODEL LAYER] - ExchangeRateViewModel
/// Vai trò:
/// - Kế thừa `ChangeNotifier`.
/// - Quản lý toàn bộ vòng đời trạng thái của Tỷ giá ngoại tệ trực tuyến:
///   + Initial, Loading, Success, Error kèm thông báo lỗi chi tiết.
///   + Cung cấp action `fetchExchangeRates()` hỗ trợ cơ chế Thử lại (Retry).
/// - NGUYÊN TẮC BẮT BUỘC:
///   + Mọi state đều private với public getters.
///   + Không import `package:flutter/material.dart` hay `dart:ui`.
/// ============================================================================

class ExchangeRateViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  ExchangeRateViewModel(this._repository);

  // ---------------------------------------------------------------------------
  // [PRIVATE STATES]
  // ---------------------------------------------------------------------------
  ExchangeRateModel? _exchangeRate;
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // [PUBLIC GETTERS]
  // ---------------------------------------------------------------------------
  ExchangeRateModel? get exchangeRate => _exchangeRate;
  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ViewStatus.loading;
  bool get isError => _status == ViewStatus.error;
  bool get isSuccess => _status == ViewStatus.success;

  /// Tỷ giá USD -> VND
  double get usdToVndRate => _exchangeRate?.vndRate ?? 0.0;

  /// Thời gian cập nhật từ API
  String get lastUpdateUtc => _exchangeRate?.timeLastUpdateUtc ?? '';

  // ---------------------------------------------------------------------------
  // [ACTIONS]
  // ---------------------------------------------------------------------------

  /// Gọi API lấy tỷ giá hối đoái mới nhất (dùng cho cả lần đầu và Retry)
  Future<void> fetchExchangeRates() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _exchangeRate = await _repository.getExchangeRates();
      _status = ViewStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('ApiException: ', '');
      _status = ViewStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
