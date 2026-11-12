import 'dart:convert';

/// ============================================================================
/// [MODEL LAYER] - TransactionModel & TransactionType
/// Vai trò:
/// - Là POJO/Data Class thuần túy đại diện cho thực thể Giao dịch thu/chi.
/// - Chứa các trường dữ liệu bất biến (immutable), hàm khởi tạo, copyWith,
///   cùng các phương thức serialize/deserialize (toMap, fromMap, toJson, fromJson).
/// - NGUYÊN TẮC: Tuyệt đối không chứa logic giao diện (Flutter UI) hay logic
///   nghiệp vụ tính toán số dư.
/// ============================================================================

enum TransactionType {
  income,  // Thu nhập (+)
  expense, // Chi tiêu (-)
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
  });

  /// Tạo bản sao với các thuộc tính được cập nhật (Immutable State Pattern)
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? category,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  /// Chuyển đổi Model thành `Map<String, dynamic>` để lưu trữ SharedPreferences / Local DB
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'category': category,
      'note': note,
    };
  }

  /// Khởi tạo Model từ `Map<String, dynamic>`
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == (map['type'] as String?),
        orElse: () => TransactionType.expense,
      ),
      category: map['category'] as String? ?? 'Khác',
      note: map['note'] as String?,
    );
  }

  /// Chuyển Model thành chuỗi JSON string
  String toJson() => json.encode(toMap());

  /// Parse chuỗi JSON string thành Model
  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant TransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.type == type &&
        other.category == category &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        type.hashCode ^
        category.hashCode ^
        (note?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, date: $date, type: $type, category: $category, note: $note)';
  }
}
