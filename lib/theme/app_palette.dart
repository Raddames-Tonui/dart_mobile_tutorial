import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// The 4 selectable accent palettes, plus light/dark and a high-contrast
/// modifier — the Flutter equivalent of the CSS custom-property system
/// in variables.css (--primary-500, [data-theme="dark"], etc).
/// ---------------------------------------------------------------------
enum AppAccent { green, blue, maroon, pink }

enum AppBrightnessMode { light, dark }

extension AppAccentLabel on AppAccent {
  String get label {
    switch (this) {
      case AppAccent.green:
        return 'Green';
      case AppAccent.blue:
        return 'Blue';
      case AppAccent.maroon:
        return 'Maroon';
      case AppAccent.pink:
        return 'Pink';
    }
  }

  Color get swatch {
    switch (this) {
      case AppAccent.green:
        return const Color(0xFF39AD9A);
      case AppAccent.blue:
        return const Color(0xFF228BE6);
      case AppAccent.maroon:
        return const Color(0xFF7A1F2B);
      case AppAccent.pink:
        return const Color(0xFFD6336C);
    }
  }
}

/// A resolved set of colors for one (accent, brightness, contrast)
/// combination — everything a widget needs, computed once per rebuild.
/// This plays the role variables.css plays for the web app: one place
/// every widget's color comes from, never a hardcoded literal.
class AppPalette {
  final Color background;
  final Color surface;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primaryDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color danger;
  final Color inputBackground;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.danger,
    required this.inputBackground,
  });

  /// High contrast swaps the "soft" border for a much darker one and
  /// boosts secondary-text contrast — the same idea as the CSS's
  /// separate data-contrast="high" attribute, distinct from dark mode.
  Color effectiveBorder(bool highContrast) => highContrast ? borderStrong : border;
}

AppPalette buildPalette(AppAccent accent, AppBrightnessMode mode, bool highContrast) {
  final isDark = mode == AppBrightnessMode.dark;

  final primary = accent.swatch;
  final hsl = HSLColor.fromColor(primary);
  final primaryDark = hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();

  if (isDark) {
    return AppPalette(
      background: const Color(0xFF1B1E26),
      surface: const Color(0xFF262A34),
      border: const Color(0xFF3F4454),
      borderStrong: highContrast ? const Color(0xFFF2F4F8) : const Color(0xFF5A6072),
      primary: primary,
      primaryDark: primaryDark,
      textPrimary: Colors.white,
      textSecondary: highContrast ? const Color(0xFFD9DDE8) : const Color(0xFF9BA1B3),
      success: const Color(0xFF3FA852),
      danger: const Color(0xFFF87171),
      inputBackground: const Color(0xFF20232B),
    );
  }

  return AppPalette(
    background: const Color(0xFFF5F6FA),
    surface: Colors.white,
    border: const Color(0xFFE1E4EA),
    borderStrong: highContrast ? const Color(0xFF1A1D29) : const Color(0xFFC6C6C6),
    primary: primary,
    primaryDark: primaryDark,
    textPrimary: const Color(0xFF1A1D29),
    textSecondary: highContrast ? const Color(0xFF3F4454) : const Color(0xFF6B7280),
    success: const Color(0xFF1F9254),
    danger: const Color(0xFFC0392B),
    inputBackground: const Color(0xFFFAFBFC),
  );
}
