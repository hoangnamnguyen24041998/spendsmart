import 'package:flutter_test/flutter_test.dart';
import 'package:spendsmart/models/exchange_rate_model.dart';
import 'package:spendsmart/models/transaction_model.dart';
import 'package:spendsmart/repositories/transaction_repository.dart';
import 'package:spendsmart/viewmodels/transaction_viewmodel.dart';

/// Mock Repository để kiểm thử Unit Test cho ViewModel mà không phụ thuộc DB hay Network
class MockTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _data = [];

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return List.from(_data);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _data.insert(0, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _data.removeWhere((item) => item.id == id);
  }

  @override
  Future<ExchangeRateModel> getExchangeRates() async {
    return const ExchangeRateModel(
      result: 'success',
      baseCode: 'USD',
      timeLastUpdateUtc: '2026-11-11',
      rates: {'VND': 25400.0},
    );
  }
}

void main() {
  group('TransactionViewModel MVVM Unit Tests', () {
    late MockTransactionRepository repository;
    late TransactionViewModel viewModel;

    setUp(() {
      repository = MockTransactionRepository();
      viewModel = TransactionViewModel(repository);
    });

    test('Khởi tạo ViewModel có trạng thái initial và danh sách rỗng', () {
      expect(viewModel.status, equals(ViewStatus.initial));
      expect(viewModel.transactions, isEmpty);
      expect(viewModel.balance, equals(0.0));
      expect(viewModel.totalIncome, equals(0.0));
      expect(viewModel.totalExpense, equals(0.0));
    });

    test('Thêm giao dịch thu nhập và chi tiêu, tính toán số dư chính xác', () async {
      // Thêm thu nhập 10,000,000 VND
      final income = TransactionModel(
        id: '1',
        title: 'Lương tháng 11',
        amount: 10000000.0,
        date: DateTime.now(),
        type: TransactionType.income,
        category: 'Lương',
      );
      await viewModel.addTransaction(income);

      expect(viewModel.totalIncome, equals(10000000.0));
      expect(viewModel.totalExpense, equals(0.0));
      expect(viewModel.balance, equals(10000000.0));

      // Thêm chi tiêu 2,500,000 VND
      final expense = TransactionModel(
        id: '2',
        title: 'Mua sắm gia đình',
        amount: 2500000.0,
        date: DateTime.now(),
        type: TransactionType.expense,
        category: 'Mua sắm',
      );
      await viewModel.addTransaction(expense);

      expect(viewModel.totalIncome, equals(10000000.0));
      expect(viewModel.totalExpense, equals(2500000.0));
      expect(viewModel.balance, equals(7500000.0));
    });

    test('Xóa giao dịch thành công cập nhật lại số dư', () async {
      final tx = TransactionModel(
        id: '99',
        title: 'Tiền thưởng',
        amount: 5000000.0,
        date: DateTime.now(),
        type: TransactionType.income,
        category: 'Thưởng',
      );
      await viewModel.addTransaction(tx);
      expect(viewModel.balance, equals(5000000.0));

      await viewModel.deleteTransaction('99');
      expect(viewModel.transactions, isEmpty);
      expect(viewModel.balance, equals(0.0));
    });
  });
}
