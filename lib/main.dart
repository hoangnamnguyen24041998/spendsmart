import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/transaction_repository.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/exchange_rate_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'views/screens/dashboard_screen.dart';

/// ============================================================================
/// [ROOT APPLICATION] - main.dart
/// Vai trò:
/// - Điểm khởi chạy chính của ứng dụng Flutter.
/// - Thiết lập Dependency Injection (DI) thông qua `MultiProvider` cấp Root.
/// - Phân cấp rõ ràng:
///   1. Service Layer (ApiService, StorageService)
///   2. Repository Layer (TransactionRepository)
///   3. ViewModel Layer (TransactionViewModel, ExchangeRateViewModel)
///   4. View Layer (MaterialApp -> DashboardScreen)
/// ============================================================================

void main() async {
  // Đảm bảo Flutter Binding được khởi tạo trước khi gọi dịch vụ hệ thống
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các Singletons ở Data Layer
  final apiService = ApiService();
  final storageService = StorageService();

  // Khởi tạo Repository điều phối
  final transactionRepository = TransactionRepositoryImpl(
    apiService,
    storageService,
  );

  runApp(
    MultiProvider(
      providers: [
        // ---------------------------------------------------------------------
        // DATA LAYER PROVIDERS (Services & Repository)
        // ---------------------------------------------------------------------
        Provider<ApiService>.value(value: apiService),
        Provider<StorageService>.value(value: storageService),
        Provider<TransactionRepository>.value(value: transactionRepository),

        // ---------------------------------------------------------------------
        // VIEWMODEL LAYER PROVIDERS (State Management & Business Logic)
        // Kích hoạt nạp dữ liệu ban đầu ngay khi Provider được tạo
        // ---------------------------------------------------------------------
        ChangeNotifierProvider<TransactionViewModel>(
          create: (_) => TransactionViewModel(transactionRepository)
            ..loadTransactions(),
        ),
        ChangeNotifierProvider<ExchangeRateViewModel>(
          create: (_) => ExchangeRateViewModel(transactionRepository)
            ..fetchExchangeRates(),
        ),
      ],
      child: const SpendSmartApp(),
    ),
  );
}

class SpendSmartApp extends StatelessWidget {
  const SpendSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendSmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF0D9488),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
