import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart'; // For checking kReleaseMode

import 'services/storage_service.dart';
import 'controllers/expense_controller.dart';
import 'views/splash_screen.dart'; // ✅ Added import for splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove the debug banner and clean up console logs in release mode
  if (kReleaseMode) {
    debugPrint =
        ((String? message, {int wrapWidth = 1024}) {}) as DebugPrintCallback;
  }

  await GetStorage.init();
  await initializeDateFormatting();
  await StorageService.init();

  // Initialize controllers
  Get.put(ExpenseController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ExpenseController controller = Get.find();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool initialDarkMode = StorageService.getThemeMode();
    controller.isDarkMode.value = initialDarkMode;

    return GetMaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false, // This line removes the debug banner
      themeMode: initialDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: SplashScreen(), // ✅ Start with splash screen
    );
  }
}
