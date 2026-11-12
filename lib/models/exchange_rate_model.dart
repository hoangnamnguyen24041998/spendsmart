import 'dart:convert';

/// ============================================================================
/// [MODEL LAYER] - ExchangeRateModel
/// Vai trò:
/// - POJO đại diện cho dữ liệu tỷ giá hối đoái lấy từ Open Exchange Rates API.
/// - Chứa thông tin đồng tiền gốc (baseCode), thời điểm cập nhật (timeLastUpdateUtc)
///   và bảng tỷ giá (rates).
/// - Cung cấp hàm serialize/deserialize (toMap, fromMap, toJson, fromJson, copyWith).
/// - NGUYÊN TẮC: Thuần túy chứa dữ liệu, không chứa logic UI.
/// ============================================================================

class ExchangeRateModel {
  final String result;
  final String baseCode;
  final String timeLastUpdateUtc;
  final Map<String, double> rates;

  const ExchangeRateModel({
    required this.result,
    required this.baseCode,
    required this.timeLastUpdateUtc,
    required this.rates,
  });

  /// Getter hỗ trợ lấy nhanh tỷ giá USD -> VND
  double get vndRate => rates['VND'] ?? 0.0;

  /// Tạo bản sao với các trường tùy chọn thay đổi
  ExchangeRateModel copyWith({
    String? result,
    String? baseCode,
    String? timeLastUpdateUtc,
    Map<String, double>? rates,
  }) {
    return ExchangeRateModel(
      result: result ?? this.result,
      baseCode: baseCode ?? this.baseCode,
      timeLastUpdateUtc: timeLastUpdateUtc ?? this.timeLastUpdateUtc,
      rates: rates ?? this.rates,
    );
  }

  /// Chuyển đối tượng thành `Map<String, dynamic>`
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'result': result,
      'base_code': baseCode,
      'time_last_update_utc': timeLastUpdateUtc,
      'rates': rates,
    };
  }

  /// Parse dữ liệu từ `Map<String, dynamic>` (theo JSON format của open.er-api.com)
  factory ExchangeRateModel.fromMap(Map<String, dynamic> map) {
    final rawRates = map['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = <String, double>{};

    rawRates.forEach((key, value) {
      if (value is num) {
        parsedRates[key] = value.toDouble();
      }
    });

    return ExchangeRateModel(
      result: map['result'] as String? ?? '',
      baseCode: map['base_code'] as String? ?? 'USD',
      timeLastUpdateUtc: map['time_last_update_utc'] as String? ?? '',
      rates: parsedRates,
    );
  }

  /// Chuyển Model thành chuỗi JSON string
  String toJson() => json.encode(toMap());

  /// Parse từ chuỗi JSON string thành Model
  factory ExchangeRateModel.fromJson(String source) =>
      ExchangeRateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant ExchangeRateModel other) {
    if (identical(this, other)) return true;

    return other.result == result &&
        other.baseCode == baseCode &&
        other.timeLastUpdateUtc == timeLastUpdateUtc;
  }

  @override
  int get hashCode {
    return result.hashCode ^
        baseCode.hashCode ^
        timeLastUpdateUtc.hashCode ^
        rates.hashCode;
  }

  @override
  String toString() {
    return 'ExchangeRateModel(baseCode: $baseCode, vndRate: $vndRate, timeLastUpdateUtc: $timeLastUpdateUtc)';
  }
}
