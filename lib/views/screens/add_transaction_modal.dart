import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';

/// ============================================================================
/// [VIEW LAYER - MODAL SCREEN] - AddTransactionModal
/// Vai trò:
/// - Hiển thị Form Modal BottomSheet để người dùng nhập thông tin giao dịch mới.
/// - Thực hiện Validate dữ liệu đầu vào tại Form UI (số tiền > 0, tên không rỗng).
/// - Khởi tạo TransactionModel và chuyển giao hành động lưu trữ sang ViewModel
///   qua `context.read<TransactionViewModel>().addTransaction(...)`.
/// - NGUYÊN TẮC:
///   + State nội bộ (StatefulWidget) ở đây chỉ quản lý các TextEditingController
///     và trạng thái form UI (UI State), KHÔNG quản lý dữ liệu nghiệp vụ toàn app.
/// ============================================================================

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  /// Hàm tiện ích tĩnh để mở Modal từ bất kỳ đâu
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddTransactionModal(),
    );
  }

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  late String _selectedCategory;

  final List<String> _expenseCategories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Hóa đơn',
    'Giải trí',
    'Sức khỏe',
    'Khác',
  ];

  final List<String> _incomeCategories = [
    'Lương',
    'Thưởng',
    'Đầu tư',
    'Tiết kiệm',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Xử lý chọn ngày giao dịch
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Gửi dữ liệu hợp lệ sang ViewModel
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0.0;
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    // Khởi tạo TransactionModel thuần túy
    final newTransaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      category: _selectedCategory,
      note: note,
    );

    // Gửi sự kiện nghiệp vụ sang ViewModel qua context.read<T>()
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await context.read<TransactionViewModel>().addTransaction(newTransaction);

    if (mounted) {
      if (success) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Đã thêm giao dịch mới thành công!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi lưu giao dịch. Vui lòng thử lại.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final categories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh kéo drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề modal
              const Text(
                'Thêm giao dịch mới',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Toggle loại giao dịch: Chi tiêu / Thu nhập
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Chi tiêu (-)'),
                    icon: Icon(Icons.arrow_upward, size: 16),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Thu nhập (+)'),
                    icon: Icon(Icons.arrow_downward, size: 16),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _selectedCategory = (_selectedType == TransactionType.expense
                            ? _expenseCategories
                            : _incomeCategories)
                        .first;
                  });
                },
              ),
              const SizedBox(height: 18),

              // Trường 1: Tên giao dịch
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tên giao dịch *',
                  hintText: 'Ví dụ: Ăn trưa, Cà phê, Lương tháng...',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên giao dịch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Trường 2: Số tiền (Validate > 0)
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Số tiền (VND) *',
                  hintText: 'Ví dụ: 50000',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: '₫',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final numValue = double.tryParse(value.replaceAll(',', '').trim());
                  if (numValue == null || numValue <= 0) {
                    return 'Số tiền phải là số lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phân loại danh mục (Category Chips)
              const Text(
                'Danh mục:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                    selectedColor: _selectedType == TransactionType.income
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (_selectedType == TransactionType.income
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828))
                          : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Chọn ngày
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.blueGrey),
                      const SizedBox(width: 10),
                      Text(
                        'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Text('Thay đổi', style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Ghi chú thêm (Tùy chọn)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (Tùy chọn)',
                  hintText: 'Thêm thông tin bổ sung nếu có',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 22),

              // Nút Submit Form
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Lưu giao dịch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
