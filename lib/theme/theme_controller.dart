import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_palette.dart';

/// ---------------------------------------------------------------------
/// ThemeController — the Flutter equivalent of the React app's theme
/// system: light/dark + a separate high-contrast opt-in, plus (new
/// here) a selectable accent color. Persisted via shared_preferences
/// because theme is explicitly non-sensitive data — the same reasoning
/// the web app uses for keeping theme in plain localStorage instead of
/// encrypted storage.
/// ---------------------------------------------------------------------
class ThemeController extends ChangeNotifier {
  AppAccent _accent = AppAccent.blue;
  AppBrightnessMode _mode = AppBrightnessMode.light;
  bool _highContrast = false;

  AppAccent get accent => _accent;
  AppBrightnessMode get mode => _mode;
  bool get highContrast => _highContrast;
  bool get isDark => _mode == AppBrightnessMode.dark;

  AppPalette get colors => buildPalette(_accent, _mode, _highContrast);

  static const _kAccent = 'theme_accent';
  static const _kMode = 'theme_mode';
  static const _kContrast = 'theme_high_contrast';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final accentName = prefs.getString(_kAccent);
    final modeName = prefs.getString(_kMode);
    _accent = AppAccent.values.firstWhere(
      (a) => a.name == accentName,
      orElse: () => AppAccent.blue,
    );
    _mode = AppBrightnessMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => AppBrightnessMode.light,
    );
    _highContrast = prefs.getBool(_kContrast) ?? false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccent, _accent.name);
    await prefs.setString(_kMode, _mode.name);
    await prefs.setBool(_kContrast, _highContrast);
  }

  void setAccent(AppAccent accent) {
    _accent = accent;
    notifyListeners();
    _persist();
  }

  void toggleMode() {
    _mode = _mode == AppBrightnessMode.light ? AppBrightnessMode.dark : AppBrightnessMode.light;
    notifyListeners();
    _persist();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
    _persist();
  }
}
