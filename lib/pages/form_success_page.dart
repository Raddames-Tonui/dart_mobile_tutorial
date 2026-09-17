import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/raw_button.dart';
import '../widgets/raw_card.dart';

/// A page that only ever exists via Navigator.push() from FormPage —
/// it has no tab of its own. This is the "stack" part of the
/// navigation tree, as opposed to the IndexedStack's "tabs".
class FormSuccessPage extends StatelessWidget {
  final Item item;

  const FormSuccessPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final AppPalette colors = context.watch<ThemeController>().colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, size: 20, color: colors.primary),
                    const SizedBox(width: 4),
                    Text('Back', style: AppText.body(colors).copyWith(color: colors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Created', style: AppText.heading1(colors)),
              const SizedBox(height: AppSpacing.md),
              RawCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(colors, 'ID', '${item.id}'),
                    _row(colors, 'Name', item.name),
                    _row(colors, 'Category', item.category),
                    _row(colors, 'Status', item.status),
                    _row(colors, 'Amount', 'KES ${item.amount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              RawButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(AppPalette colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.label(colors)),
          Text(value, style: AppText.body(colors)),
        ],
      ),
    );
  }
}
