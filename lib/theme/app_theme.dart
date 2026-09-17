import 'package:flutter/material.dart';
import 'app_palette.dart';

/// ---------------------------------------------------------------------
/// AppTheme — spacing/radius stay fixed constants (layout doesn't
/// change with color theme); text *styles* now take an AppPalette so
/// their color follows whatever accent/light-dark/contrast combination
/// is currently active. Every call site is `AppText.heading1(colors)`
/// rather than a bare constant — see theme_controller.dart for where
/// `colors` comes from.
/// ---------------------------------------------------------------------

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 16.0;
}

class AppText {
  static TextStyle heading1(AppPalette p) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
        height: 1.3,
      );

  static TextStyle heading2(AppPalette p) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: p.textPrimary,
      );

  static TextStyle body(AppPalette p) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: p.textPrimary,
        height: 1.4,
      );

  static TextStyle caption(AppPalette p) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: p.textSecondary,
      );

  static TextStyle label(AppPalette p) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: p.textSecondary,
        letterSpacing: 0.4,
      );

  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle mono(AppPalette p) => TextStyle(
        fontSize: 12,
        fontFamily: 'monospace',
        color: p.textPrimary,
        height: 1.5,
      );
}
