import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';

/// ============================================================================
/// [VIEW LAYER - WIDGET] - TransactionTileWidget
/// Vai trò:
/// - Hiển thị chi tiết từng dòng giao dịch trong danh sách.
/// - Phân loại giao diện: Màu xanh lá (+) cho Thu nhập, Màu đỏ (-) cho Chi tiêu.
/// - Gửi sự kiện xóa giao dịch sang ViewModel qua `context.read<TransactionViewModel>()`.
/// ============================================================================

class TransactionTileWidget extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTileWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('dd/MM/yyyy • HH:mm');
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _getCategoryIcon(transaction.category, isIncome),
            color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            size: 24,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormatter.format(transaction.date),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transaction.note!,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${currencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
              tooltip: 'Xóa giao dịch',
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa giao dịch "${transaction.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Gửi sự kiện xóa sang ViewModel qua context.read<T>()
              context.read<TransactionViewModel>().deleteTransaction(transaction.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa giao dịch thành công.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Trả về Icon trực quan theo danh mục
  IconData _getCategoryIcon(String category, bool isIncome) {
    if (isIncome) {
      switch (category.toLowerCase()) {
        case 'lương':
        case 'tiền lương':
          return Icons.payments_outlined;
        case 'thưởng':
          return Icons.card_giftcard;
        case 'đầu tư':
          return Icons.trending_up;
        case 'tiết kiệm':
          return Icons.savings_outlined;
        default:
          return Icons.attach_money;
      }
    } else {
      switch (category.toLowerCase()) {
        case 'ăn uống':
          return Icons.restaurant_outlined;
        case 'mua sắm':
          return Icons.shopping_bag_outlined;
        case 'hóa đơn':
          return Icons.receipt_long_outlined;
        case 'giải trí':
          return Icons.movie_creation_outlined;
        case 'di chuyển':
          return Icons.directions_car_outlined;
        case 'sức khỏe':
          return Icons.medical_services_outlined;
        default:
          return Icons.local_offer_outlined;
      }
    }
  }
}
