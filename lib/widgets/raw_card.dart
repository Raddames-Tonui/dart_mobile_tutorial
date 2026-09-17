import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// Stand-in for Material's Card widget, built manually so the shadow,
/// radius, and border are all explicit values that follow the active
/// theme rather than whatever the ambient Theme happens to specify.
/// Shadows are skipped entirely in dark mode — a soft black shadow on
/// a dark surface reads as a smudge, not depth.
class RawCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RawCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = controller.colors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.effectiveBorder(controller.highContrast)),
        boxShadow: controller.isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}
