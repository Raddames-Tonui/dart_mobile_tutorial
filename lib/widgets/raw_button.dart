import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// A button built from a bare GestureDetector + Container instead of
/// ElevatedButton — no Material ripple, no default padding/elevation
/// from a theme. Every pixel is set explicitly here, which is the
/// point: this is what "raw CSS" styling looks like in Flutter. Color
/// now comes from ThemeController so it follows accent/dark-mode.
class RawButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool loading;

  const RawButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : colors.primary,
          border: Border.all(color: colors.primary, width: outlined ? 1.4 : 0),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                label,
                style: outlined
                    ? AppText.button.copyWith(color: colors.primary)
                    : AppText.button,
              ),
      ),
    );
  }
}
