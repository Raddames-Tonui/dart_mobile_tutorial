import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/toast_service.dart';
import '../state/locale_controller.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/mascot.dart';
import '../widgets/raw_button.dart';
import '../widgets/raw_card.dart';

/// Pushed from the Drawer, not a bottom-nav tab — this is the "stack"
/// navigation mechanic again, same as FormSuccessPage. Everything here
/// writes through ThemeController/LocaleController, which persist to
/// shared_preferences on every change (see the Storage tab for why
/// that tier is the right one for this kind of non-sensitive data).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final locale = context.watch<LocaleController>();
    final AppPalette colors = themeController.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
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

            Row(
              children: [
                const Mascot(size: 52),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.t('settings'), style: AppText.heading1(colors)),
                      Text(locale.t('greeting'), style: AppText.caption(colors)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            RawCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.t('darkMode'), style: AppText.heading2(colors)),
                        Text(
                          themeController.isDark ? 'Dark theme active' : 'Light theme active',
                          style: AppText.caption(colors),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeController.isDark,
                    activeColor: colors.primary,
                    onChanged: (_) => themeController.toggleMode(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            RawCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.t('highContrast'), style: AppText.heading2(colors)),
                        Text('Stronger borders and text separation', style: AppText.caption(colors)),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeController.highContrast,
                    activeColor: colors.primary,
                    onChanged: themeController.setHighContrast,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            RawCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.t('accentColor'), style: AppText.heading2(colors)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: AppAccent.values.map((accent) {
                      final selected = accent == themeController.accent;
                      return GestureDetector(
                        onTap: () => themeController.setAccent(accent),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accent.swatch,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(color: colors.textPrimary, width: 3)
                                    : null,
                              ),
                              child: selected
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(accent.label, style: AppText.caption(colors)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            RawCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.t('language'), style: AppText.heading2(colors)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: AppLanguage.values.map((lang) {
                      final selected = lang == locale.language;
                      final label = lang == AppLanguage.english ? 'English' : 'Kiswahili';
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () => locale.setLanguage(lang),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? colors.primary : colors.inputBackground,
                              border: Border.all(
                                color: selected
                                    ? colors.primary
                                    : colors.effectiveBorder(themeController.highContrast),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              label,
                              style: AppText.caption(colors).copyWith(
                                color: selected ? Colors.white : colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            RawCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Toasts', style: AppText.heading2(colors)),
                  const SizedBox(height: 4),
                  Text(
                    'Dismiss-and-forget notices — never block input, unlike a confirm dialog.',
                    style: AppText.caption(colors),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      RawButton(
                        label: 'Success',
                        onPressed: () => ToastService.show(context,
                            message: locale.t('toastSuccess'), type: ToastType.success),
                      ),
                      RawButton(
                        label: 'Error',
                        outlined: true,
                        onPressed: () => ToastService.show(context,
                            message: locale.t('toastError'), type: ToastType.error),
                      ),
                      RawButton(
                        label: 'Info',
                        outlined: true,
                        onPressed: () =>
                            ToastService.show(context, message: 'Just so you know…', type: ToastType.info),
                      ),
                      RawButton(
                        label: 'Warning',
                        outlined: true,
                        onPressed: () => ToastService.show(context,
                            message: 'Double-check that amount', type: ToastType.warning),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
