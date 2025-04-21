import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../services/storage_service.dart';

class CategoryManagementScreen extends StatelessWidget {
  final ExpenseController controller = Get.find();
  final TextEditingController textController = TextEditingController();

  CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAddCategoryField(theme),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Expanded(child: _buildCategoryList(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryField(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: 'New Category',
              labelStyle: TextStyle(color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            final newCategory = textController.text.trim();
            if (newCategory.isNotEmpty) {
              controller.addCategory(newCategory);
              textController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildCategoryList(ThemeData theme) {
    return Obx(
      () =>
          controller.categories.isEmpty
              ? Center(
                child: Text(
                  'No categories added yet.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.category, color: theme.colorScheme.primary),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => _confirmDeleteCategory(context, category),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, String category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "$category"? '
              'All expenses in this category will be set to "Uncategorized".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCategory(category);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _deleteCategory(String category) {
    controller.categories.remove(category);
    StorageService.saveCategories(controller.categories);

    for (int i = 0; i < controller.expenseList.length; i++) {
      final expense = controller.expenseList[i];
      if (expense.category == category) {
        final updatedExpense = expense.copyWith(category: 'Uncategorized');
        controller.updateExpense(updatedExpense);
      }
    }

    Get.snackbar(
      'Success',
      'Category deleted successfully',
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
