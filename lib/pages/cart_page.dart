import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/raw_button.dart';
import '../widgets/raw_card.dart';

/// Pushed from the AppBar's cart icon — like SettingsPage, this has no
/// tab of its own. CartState is Provider-shared with TablePage, so
/// items added there just show up here regardless of navigation state.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final cart = context.watch<CartState>();

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
                    Icon(Icons.arrow_back, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Back', style: AppText.body(colors).copyWith(color: colors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Cart', style: AppText.heading1(colors)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add items from the Table tab — they show up here regardless '
                'of which tab was active when you added them. That\'s '
                'Provider-shared state, not per-page state.',
                style: AppText.caption(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: cart.items.isEmpty
                    ? Center(child: Text('Cart is empty', style: AppText.caption(colors)))
                    : ListView.separated(
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return RawCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: AppText.body(colors)),
                                      Text('KES ${item.amount.toStringAsFixed(2)}',
                                          style: AppText.caption(colors)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => cart.removeAt(index),
                                  child: Icon(Icons.delete_outline, color: colors.danger),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (cart.items.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppText.heading2(colors)),
                    Text('KES ${cart.total.toStringAsFixed(2)}', style: AppText.heading2(colors)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                RawButton(label: 'Clear cart', outlined: true, onPressed: cart.clear),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
