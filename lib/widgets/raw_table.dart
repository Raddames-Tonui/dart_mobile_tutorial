import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// A table built row-by-row from Containers and Rows — not Flutter's
/// built-in DataTable widget, which pulls its look from the ambient
/// Material theme. Building it manually gives full control over every
/// border, padding, and color, and now that control follows the active
/// accent/dark-mode/high-contrast combination.
///
/// New: an optional [onAdd] callback renders a trailing "add" icon per
/// row — used by TablePage to add an item to the shared CartState.
class RawTable extends StatelessWidget {
  final List<Item> items;
  final void Function(Item item)? onAdd;

  const RawTable({super.key, required this.items, this.onAdd});

  Color _statusColor(AppPalette colors, String status) {
    switch (status) {
      case 'COMPLETED':
        return colors.success;
      case 'FAILED':
        return colors.danger;
      default:
        return colors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = controller.colors;
    final border = colors.effectiveBorder(controller.highContrast);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            color: colors.background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('NAME', style: AppText.label(colors))),
                Expanded(flex: 2, child: Text('CATEGORY', style: AppText.label(colors))),
                Expanded(flex: 2, child: Text('STATUS', style: AppText.label(colors))),
                Expanded(
                  flex: 2,
                  child: Text('AMOUNT', style: AppText.label(colors), textAlign: TextAlign.right),
                ),
                if (onAdd != null) const SizedBox(width: 28),
              ],
            ),
          ),
          // Data rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final statusColor = _statusColor(colors, item.status);
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: index.isEven ? colors.surface : colors.background,
                border: Border(top: BorderSide(color: border, width: 0.6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(item.name, style: AppText.body(colors), overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(flex: 2, child: Text(item.category, style: AppText.body(colors))),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: AppText.caption(colors).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'KES ${item.amount.toStringAsFixed(2)}',
                      style: AppText.body(colors),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (onAdd != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => onAdd!(item),
                        child: Icon(Icons.add_circle_outline, size: 20, color: colors.primary),
                      ),
                    ),
                ],
              ),
            );
          }),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('No matching rows', style: AppText.caption(colors)),
            ),
        ],
      ),
    );
  }
}
