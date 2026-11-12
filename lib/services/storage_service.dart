import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

/// ============================================================================
/// [DATA LAYER - LOCAL STORAGE SERVICE] - StorageService
/// Vai trò:
/// - Chịu trách nhiệm trực tiếp đọc và ghi dữ liệu cục bộ trên thiết bị qua
///   gói SharedPreferences (cơ chế Offline-First).
/// - Thực hiện tuần tự hóa (serialization) danh sách TransactionModel thành JSON String
///   khi lưu, và giải tuần tự (deserialization) khi đọc lên.
/// - Không chứa bất kỳ logic tính toán số dư hay logic màn hình nào.
/// ============================================================================

class StorageService {
  static const String _transactionsKey = 'spendsmart_transactions_key';

  SharedPreferences? _preferences;

  StorageService([this._preferences]);

  /// Đảm bảo SharedPreferences instance đã được khởi tạo
  Future<SharedPreferences> _getInstance() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  /// Đọc danh sách tất cả các giao dịch đã lưu trong thiết bị
  Future<List<TransactionModel>> loadTransactions() async {
    try {
      final prefs = await _getInstance();
      final jsonString = prefs.getString(_transactionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = json.decode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Trường hợp dữ liệu lưu trữ bị lỗi format, trả về rỗng để an toàn
      return [];
    }
  }

  /// Ghi đè toàn bộ danh sách giao dịch xuống bộ nhớ SharedPreferences
  Future<bool> saveTransactions(List<TransactionModel> transactions) async {
    try {
      final prefs = await _getInstance();
      final mappedList = transactions.map((t) => t.toMap()).toList();
      final jsonString = json.encode(mappedList);
      return await prefs.setString(_transactionsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Xóa toàn bộ dữ liệu giao dịch đã lưu (dùng cho test hoặc reset app)
  Future<bool> clearTransactions() async {
    final prefs = await _getInstance();
    return await prefs.remove(_transactionsKey);
  }
}
