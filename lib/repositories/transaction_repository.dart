import '../models/exchange_rate_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// ============================================================================
/// [DATA LAYER - REPOSITORY PATTERN] - TransactionRepository
/// Vai trò:
/// - Đóng vai trò là Single Source of Truth (nguồn chân lý dữ liệu duy nhất).
/// - Che giấu nguồn gốc dữ liệu (Local Storage hay Remote API).
/// - ViewModel chỉ tương tác với Repository thông qua Contract trừu tượng này,
///   giúp code dễ dàng Unit Test, Mocking và mở rộng sang SQLite/Isar/Hive sau này.
/// ============================================================================

abstract class TransactionRepository {
  /// Lấy danh sách giao dịch từ bộ nhớ cục bộ
  Future<List<TransactionModel>> getTransactions();

  /// Thêm mới một giao dịch và lưu trữ xuống thiết bị
  Future<void> addTransaction(TransactionModel transaction);

  /// Xóa một giao dịch theo id và cập nhật lưu trữ
  Future<void> deleteTransaction(String id);

  /// Lấy tỷ giá hối đoái mới nhất từ Remote API
  Future<ExchangeRateModel> getExchangeRates();
}

/// Triển khai cụ thể của TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  TransactionRepositoryImpl(this._apiService, this._storageService);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final list = await _storageService.loadTransactions();
    // Sắp xếp giao dịch mới nhất lên đầu danh sách theo thời gian
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final currentList = await _storageService.loadTransactions();
    // Thêm giao dịch mới vào danh sách
    currentList.insert(0, transaction);
    await _storageService.saveTransactions(currentList);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final currentList = await _storageService.loadTransactions();
    currentList.removeWhere((item) => item.id == id);
    await _storageService.saveTransactions(currentList);
  }

  @override
  Future<ExchangeRateModel> getExchangeRates() async {
    return await _apiService.fetchExchangeRates();
  }
}
