import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/transaction_viewmodel.dart';

/// ============================================================================
/// [VIEW LAYER - WIDGET] - BalanceCardWidget
/// Vai trò:
/// - Hiển thị trực quan Số dư hiện tại, Tổng thu và Tổng chi.
/// - Lắng nghe (watch) dữ liệu từ TransactionViewModel thông qua `context.watch<T>()`
///   hoặc `Consumer<T>`.
/// - NGUYÊN TẮC:
///   + Không thực hiện bất kỳ phép cộng trừ tính toán số dư nào tại đây.
///   + Chỉ format chuỗi tiền tệ hiển thị người dùng từ các getter của ViewModel.
/// ============================================================================

class BalanceCardWidget extends StatelessWidget {
  const BalanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Lắng nghe State từ TransactionViewModel
    final viewModel = context.watch<TransactionViewModel>();
    final balance = viewModel.balance;
    final income = viewModel.totalIncome;
    final expense = viewModel.totalExpense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep Navy
            Color(0xFF2563EB), // Vibrant Blue
            Color(0xFF3B82F6), // Royal Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tiêu đề số dư
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng số dư khả dụng',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Ví chính',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hiển thị số dư lớn
          Text(
            currencyFormatter.format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 22),

          // Khung phân chia Thu nhập & Chi tiêu
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Cột Thu nhập
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_downward, color: Color(0xFF34D399), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thu nhập',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currencyFormatter.format(income),
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Đường phân cách giữa
                Container(
                  height: 36,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 12),

                // Cột Chi tiêu
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward, color: Color(0xFFF87171), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiêu',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currencyFormatter.format(expense),
                                style: const TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
