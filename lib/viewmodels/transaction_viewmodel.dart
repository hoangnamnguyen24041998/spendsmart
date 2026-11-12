import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// ============================================================================
/// [VIEWMODEL LAYER] - TransactionViewModel
/// Vai trò:
/// - Kế thừa `ChangeNotifier` để thông báo cho UI Rebuild khi State thay đổi.
/// - Đảm nhiệm toàn bộ Business Logic liên quan đến Quản lý Thu/Chi:
///   + Tính toán Tổng thu (totalIncome), Tổng chi (totalExpense) và Số dư (balance).
///   + Quản lý danh sách giao dịch, trạng thái tải (ViewStatus), thông báo lỗi.
/// - NGUYÊN TẮC BẮT BUỘC:
///   + Mọi biến State đều là `private`, chỉ truy xuất ra ngoài qua `public getter`.
///   + TUYỆT ĐỐI KHÔNG import `dart:ui` hay `package:flutter/material.dart`
///     (chỉ dùng `package:flutter/foundation.dart`).
/// ============================================================================

enum ViewStatus {
  initial,
  loading,
  success,
  error,
}

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionViewModel(this._repository);

  // ---------------------------------------------------------------------------
  // [PRIVATE STATES] - Đóng gói dữ liệu bảo đảm tính toàn vẹn (Encapsulation)
  // ---------------------------------------------------------------------------
  List<TransactionModel> _transactions = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // [PUBLIC GETTERS] - Cung cấp State ra ngoài cho UI tiêu thụ
  // ---------------------------------------------------------------------------
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ViewStatus.loading;
  bool get isEmpty => _transactions.isEmpty;

  // ---------------------------------------------------------------------------
  // [BUSINESS LOGIC CALCULATIONS] - Tính toán tập trung tại ViewModel
  // Tuyệt đối không để View tự cộng trừ số dư
  // ---------------------------------------------------------------------------

  /// Tính tổng số tiền thu nhập
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (previousValue, element) => previousValue + element.amount);
  }

  /// Tính tổng số tiền chi tiêu
  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (previousValue, element) => previousValue + element.amount);
  }

  /// Số dư hiện tại = Tổng thu - Tổng chi
  double get balance => totalIncome - totalExpense;

  // ---------------------------------------------------------------------------
  // [USER ACTIONS / EVENTS] - Nhận yêu cầu từ View và tương tác với Repository
  // ---------------------------------------------------------------------------

  /// Tải danh sách giao dịch từ kho lưu trữ
  Future<void> loadTransactions() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions();
      _status = ViewStatus.success;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách giao dịch: $e';
      _status = ViewStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Thêm giao dịch mới
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.addTransaction(transaction);
      // Cập nhật lại danh sách sau khi thêm
      _transactions = await _repository.getTransactions();
      _status = ViewStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Thêm giao dịch thất bại: $e';
      _status = ViewStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Xóa một giao dịch dựa vào ID
  Future<bool> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      // Cập nhật lại danh sách sau khi xóa
      _transactions = await _repository.getTransactions();
      _status = ViewStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Xóa giao dịch thất bại: $e';
      _status = ViewStatus.error;
      notifyListeners();
      return false;
    }
  }
}
