import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/exchange_rate_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/exchange_rate_widget.dart';
import '../widgets/transaction_tile_widget.dart';
import 'add_transaction_modal.dart';

/// ============================================================================
/// [VIEW LAYER - SCREEN] - DashboardScreen
/// Vai trò:
/// - Màn hình Dashboard trung tâm của ứng dụng SpendSmart.
/// - Kết hợp các widget con: ExchangeRateWidget, BalanceCardWidget, TransactionTileWidget.
/// - Lắng nghe danh sách giao dịch qua `Consumer<TransactionViewModel>`.
/// - Hỗ trợ thao tác vuốt làm mới dữ liệu (Pull-to-refresh) bằng `RefreshIndicator`.
/// - NGUYÊN TẮC:
///   + Mọi tác vụ nghiệp vụ đều điều hướng qua `context.read<T>()`.
///   + Không gọi API trực tiếp, không tự tính toán số dư.
/// ============================================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Hàm kích hoạt làm mới toàn bộ dữ liệu (Offline Storage + Remote API)
  Future<void> _handleRefresh(BuildContext context) async {
    await Future.wait([
      context.read<TransactionViewModel>().loadTransactions(),
      context.read<ExchangeRateViewModel>().fetchExchangeRates(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền sáng slate hiện đại
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.wallet, color: Color(0xFF1E3A8A), size: 26),
            SizedBox(width: 8),
            Text(
              'SpendSmart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFF1E3A8A)),
            tooltip: 'Đồng bộ dữ liệu',
            onPressed: () => _handleRefresh(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(context),
        color: const Color(0xFF1E3A8A),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Phần 1: Tỷ giá trực tuyến + Thẻ số dư
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Widget tỷ giá ngoại tệ trực tuyến
                    ExchangeRateWidget(),
                    SizedBox(height: 14),
                    // Widget hiển thị số dư và tổng thu chi
                    BalanceCardWidget(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Phần 2: Tiêu đề danh sách giao dịch
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Consumer<TransactionViewModel>(
                  builder: (context, txVM, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Giao dịch gần đây',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${txVM.transactions.length} mục',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Phần 3: Danh sách giao dịch hoặc Empty State
            Consumer<TransactionViewModel>(
              builder: (context, txVM, child) {
                // Trạng thái đang tải lần đầu
                if (txVM.isLoading && txVM.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Trạng thái chưa có giao dịch nào
                if (txVM.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có giao dịch nào',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bấm vào nút dấu (+) bên dưới để thêm khoản thu hoặc chi tiêu đầu tiên.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Trạng thái hiển thị danh sách giao dịch
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = txVM.transactions[index];
                        return TransactionTileWidget(transaction: tx);
                      },
                      childCount: txVM.transactions.length,
                    ),
                  ),
                );
              },
            ),

            // Khoảng đệm phía dưới để không bị nút FAB che khuất
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      // Nút thêm mới giao dịch
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => AddTransactionModal.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
