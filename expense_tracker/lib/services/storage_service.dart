import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/expense.dart';

class StorageService {
  static final GetStorage _box = GetStorage();
  static const String EXPENSES_KEY = 'expenses';
  static const String THEME_KEY = 'dark_mode';
  static const String CATEGORIES_KEY = 'categories';
  static const String CATEGORY_COLORS_KEY =
      'category_colors'; // New key for category colors

  // Initialize GetStorage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Save expense data to GetStorage
  static Future<void> saveExpense(Expense expense) async {
    List<Expense> expenses = await getExpenses();
    expenses.add(expense);
    await _saveAllExpenses(expenses);
  }

  // Update existing expense
  static Future<void> updateExpense(Expense updatedExpense) async {
    List<Expense> expenses = await getExpenses();
    final index = expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index >= 0) {
      expenses[index] = updatedExpense;
      await _saveAllExpenses(expenses);
    }
  }

  // Delete an expense by ID
  static Future<void> deleteExpense(String id) async {
    List<Expense> expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id);
    await _saveAllExpenses(expenses);
  }

  // Save all expenses - internal helper method
  static Future<void> _saveAllExpenses(List<Expense> expenses) async {
    await _box.write(EXPENSES_KEY, expenses.map((e) => e.toMap()).toList());
  }

  // Get all expenses
  static Future<List<Expense>> getExpenses() async {
    List? expensesData = _box.read(EXPENSES_KEY);
    if (expensesData == null) {
      return [];
    }
    return expensesData.map<Expense>((e) => Expense.fromMap(e)).toList();
  }

  // Get expenses for a specific category
  static Future<List<Expense>> getExpensesByCategory(String category) async {
    List<Expense> allExpenses = await getExpenses();
    return allExpenses.where((e) => e.category == category).toList();
  }

  // Get expenses for a specific date range
  static Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    List<Expense> allExpenses = await getExpenses();
    return allExpenses
        .where(
          (e) =>
              !e.date.isBefore(start) &&
              !e.date.isAfter(end.add(Duration(days: 1))),
        )
        .toList();
  }

  // Save theme mode preference
  static Future<void> saveThemeMode(bool isDarkMode) async {
    await _box.write(THEME_KEY, isDarkMode);
  }

  // Get theme mode preference
  static bool getThemeMode() {
    return _box.read(THEME_KEY) ?? false;
  }

  // Save categories
  static Future<void> saveCategories(List<String> categories) async {
    await _box.write(CATEGORIES_KEY, categories);
  }

  // Get categories
  static List<String> getCategories() {
    List? categories = _box.read(CATEGORIES_KEY);
    if (categories == null) {
      return [
        'Food',
        'Transport',
        'Bills',
        'Entertainment',
        'Shopping',
        'Health',
        'Education',
        'Other',
      ];
    }
    return categories.cast<String>();
  }

  // Save category colors
  static Future<void> saveCategoryColors(
    Map<String, Color> categoryColors,
  ) async {
    final Map<String, String> colorMap = categoryColors.map((key, value) {
      return MapEntry(
        key,
        value.value.toRadixString(16),
      ); // Convert Color to Hex String
    });
    await _box.write(CATEGORY_COLORS_KEY, json.encode(colorMap));
  }

  // Get category colors
  static Future<Map<String, Color>> getCategoryColors() async {
    final colorString = _box.read(CATEGORY_COLORS_KEY);
    if (colorString != null) {
      final Map<String, dynamic> decodedMap = Map<String, dynamic>.from(
        json.decode(colorString),
      );
      return decodedMap.map((key, value) {
        return MapEntry(
          key,
          Color(int.parse(value, radix: 16)),
        ); // Convert Hex String back to Color
      });
    }
    return {};
  }
}
