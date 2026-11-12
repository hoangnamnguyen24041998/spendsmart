import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/exchange_rate_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';

/// ============================================================================
/// [VIEW LAYER - WIDGET] - ExchangeRateWidget
/// Vai trò:
/// - Hiển thị tỷ giá hối đoái trực tiếp USD/VND.
/// - Tiêu thụ ExchangeRateViewModel bằng `Consumer<ExchangeRateViewModel>`.
/// - Xử lý 3 trạng thái rõ ràng:
///   1. Loading: Hiển thị vòng xoay tiến trình khi đang lấy dữ liệu.
///   2. Error: Hiển thị thông báo lỗi thân thiện kèm nút [Thử lại] (Retry).
///   3. Success: Hiển thị giá trị quy đổi chuẩn xác 1 USD -> ? VND.
/// - Gửi sự kiện reload sang ViewModel qua `context.read<ExchangeRateViewModel>()`.
/// ============================================================================

class ExchangeRateWidget extends StatelessWidget {
  const ExchangeRateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Consumer<ExchangeRateViewModel>(
      builder: (context, rateVM, child) {
        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            child: _buildContentByStatus(context, rateVM, currencyFormatter),
          ),
        );
      },
    );
  }

  /// Điều phối hiển thị theo enum ViewStatus của ViewModel
  Widget _buildContentByStatus(
    BuildContext context,
    ExchangeRateViewModel rateVM,
    NumberFormat formatter,
  ) {
    switch (rateVM.status) {
      case ViewStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              SizedBox(width: 14),
              Text(
                'Đang cập nhật tỷ giá trực tuyến...',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );

      case ViewStatus.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rateVM.errorMessage ?? 'Không thể tải tỷ giá hối đoái.',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.read<ExchangeRateViewModel>().fetchExchangeRates(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Thử lại'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        );

      case ViewStatus.success:
      case ViewStatus.initial:
        return Row(
          children: [
            // Icon tiền tệ
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.currency_exchange, color: Color(0xFFD97706), size: 22),
            ),
            const SizedBox(width: 14),

            // Chi tiết tỷ giá
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tỷ giá trực tuyến',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: '1 USD = ',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: formatter.format(rateVM.usdToVndRate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nút Refresh thủ công
            IconButton(
              icon: const Icon(Icons.sync, color: Colors.blueGrey, size: 20),
              tooltip: 'Làm mới tỷ giá',
              onPressed: () => context.read<ExchangeRateViewModel>().fetchExchangeRates(),
            ),
          ],
        );
    }
  }
}
