# SpendSmart - Ứng dụng Quản lý Thu Chi & Tỷ giá Ngoại tệ

Ứng dụng Flutter Mobile quản lý tài chính cá nhân được thiết kế và xây dựng theo chuẩn kiến trúc **MVVM (Model - View - ViewModel)** kết hợp thư viện `provider` cho Dependency Injection và State Management.

---

## 🏛️ Kiến trúc tổng thể MVVM (Model - View - ViewModel)

Dự án tuân thủ nghiêm ngặt nguyên lý **Separation of Concerns (SoC)** và **Single Responsibility Principle (SRP)**:

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEW (UI)                           │
│  DashboardScreen, AddTransactionModal, Widgets...           │
│  - Chỉ chứa logic hiển thị giao diện                        │
│  - Lắng nghe ViewModel qua Consumer<T> / context.watch<T>() │
│  - Phát sự kiện người dùng qua context.read<T>()            │
└──────────────────────────────▲──────────────────────────────┘
                               │ (Notifies UI / Observes)
┌──────────────────────────────▼──────────────────────────────┐
│                    VIEWMODEL (Logic)                        │
│  TransactionViewModel, ExchangeRateViewModel                │
│  - Kế thừa ChangeNotifier                                   │
│  - Quản lý toàn bộ State (Private state + Public getter)    │
│  - Tính toán số dư (Balance, Total Income, Total Expense)   │
│  - Không import 'package:flutter/material.dart'             │
└──────────────────────────────▲──────────────────────────────┘
                               │ (Requests data / Updates)
┌──────────────────────────────▼──────────────────────────────┐
│                  REPOSITORY & DATA LAYER                    │
│  TransactionRepository (Interface + Implementation)         │
│  ├── ApiService (Gọi RESTful API tỷ giá USD/VND live)       │
│  └── StorageService (Lưu trữ cục bộ SharedPreferences)      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Cấu trúc thư mục chuẩn MVVM

```
lib/
├── models/
│   ├── transaction_model.dart     # POJO & Serialization (Income/Expense entity)
│   └── exchange_rate_model.dart    # POJO & Serialization cho API tỷ giá
├── services/
│   ├── api_service.dart            # Giao tiếp HTTP RESTful API (open.er-api.com)
│   └── storage_service.dart        # Lưu trữ Offline-first qua SharedPreferences
├── repositories/
│   └── transaction_repository.dart # Repository Pattern làm Single Source of Truth
├── viewmodels/
│   ├── transaction_viewmodel.dart  # Business Logic, tính số dư & CRUD giao dịch
│   └── exchange_rate_viewmodel.dart# Quản lý vòng đời trạng thái tỷ giá trực tuyến
├── views/
│   ├── screens/
│   │   ├── dashboard_screen.dart   # Màn hình chính Dashboard
│   │   └── add_transaction_modal.dart # Form Modal BottomSheet nhập giao dịch
│   └── widgets/
│       ├── balance_card_widget.dart   # Card gradient hiển thị số dư, thu, chi
│       ├── exchange_rate_widget.dart  # Widget hiển thị tỷ giá (Loading/Success/Error/Retry)
│       └── transaction_tile_widget.dart# Item hiển thị giao dịch + nút xóa
└── main.dart                       # Khởi tạo DI MultiProvider cấp Root
```

---

## 🚀 Tính năng cốt lõi

1. **Quản lý thu chi (CRUD):**
   - Thêm, xóa và hiển thị lịch sử giao dịch.
   - ViewModel tự động tính toán chính xác **Tổng thu**, **Tổng chi** và **Số dư khả dụng**.
2. **Tỷ giá ngoại tệ trực tuyến:**
   - Tích hợp API: `https://open.er-api.com/v6/latest/USD`.
   - Xử lý 3 trạng thái chuẩn mực: **Loading**, **Success**, **Error** kèm nút **Thử lại (Retry)**.
3. **Modal BottomSheet & Form Validation:**
   - Kiểm tra hợp lệ: Tên không để trống, số tiền phải là số `> 0`.
   - Chọn loại giao dịch (Thu nhập / Chi tiêu) và danh mục trực quan.
4. **Cơ chế Offline-First:**
   - Dữ liệu thu chi được tự động đồng bộ và lưu trữ an toàn trong `SharedPreferences`.

---

## 🧪 Kiểm thử tự động (Unit Tests)

Bộ kiểm thử được viết tại `test/transaction_viewmodel_test.dart` nhằm kiểm chứng tính độc lập của tầng ViewModel thông qua `MockTransactionRepository`:

```bash
flutter test
```

---

## 🛠️ Hướng dẫn cài đặt & Chạy ứng dụng

1. **Clone repository:**
   ```bash
   git clone <REPO_URL>
   cd spendsmart
   ```

2. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```
