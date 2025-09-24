import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'services/storage_service.dart';
import 'controllers/expense_controller.dart';
import 'views/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    debugPrint =
        ((String? message, {int wrapWidth = 1024}) {}) as DebugPrintCallback;
  }

  await GetStorage.init();
  await initializeDateFormatting();
  await StorageService.init();

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
      debugShowCheckedModeBanner: false,
      themeMode: initialDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: SplashScreen(),
    );
  }
}
