import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ExpenseController controller = Get.find();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Preferences', theme),
          _buildCardTile(
            icon: Icons.color_lens,
            title: 'Theme',
            subtitle: 'Change app appearance',
            trailing: Obx(
              () => Switch(
                value: controller.isDarkMode.value,
                onChanged: (value) => controller.toggleThemeMode(),
              ),
            ),
            theme: theme,
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Management', theme),
          _buildCardTile(
            icon: Icons.category,
            title: 'Manage Categories',
            subtitle: 'Add, edit or remove expense categories',
            onTap: () => Get.to(() => CategoryManagementScreen()),
            theme: theme,
          ),

          SizedBox(height: 24),
          _buildSectionTitle('App Info', theme),
          _buildCardTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App information',
            onTap: () => _showAboutDialog(context),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Icon(icon, color: theme.colorScheme.primary),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showAboutDialog(
      context: context,
      applicationName: 'Expense Tracker',
      applicationVersion: '2.0.0',
      applicationIcon: Icon(
        Icons.account_balance_wallet,
        size: 48,
        color: theme.colorScheme.primary,
      ),
      children: [
        SizedBox(height: 16),
        Text(
          'An advanced expense tracker app with improved UI and features.',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
        ),
        SizedBox(height: 8),
        Text(
          'Built with Flutter and GetX.',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }
}
