import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------
/// A deliberately small stand-in for the web app's i18next setup —
/// enough to demonstrate the pattern (pick a language → persist it →
/// explicit choice always wins on future loads) without pulling in the
/// full intl/.arb toolchain for a prototype. For the real thing later,
/// see the README's i18n row: the `intl` package + `.arb` files, or
/// `easy_localization`.
/// ---------------------------------------------------------------------
enum AppLanguage { english, swahili }

class LocaleController extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  static const _kLanguage = 'app_language';

  static const Map<AppLanguage, Map<String, String>> _strings = {
    AppLanguage.english: {
      'tree': 'Tree',
      'table': 'Table',
      'form': 'Form',
      'storage': 'Storage',
      'settings': 'Settings',
      'cart': 'Cart',
      'greeting': "Let's set things up",
      'darkMode': 'Dark mode',
      'highContrast': 'High contrast',
      'accentColor': 'Accent color',
      'language': 'Language',
      'toastSuccess': 'Saved successfully',
      'toastError': 'Something went wrong',
    },
    AppLanguage.swahili: {
      'tree': 'Muundo',
      'table': 'Jedwali',
      'form': 'Fomu',
      'storage': 'Hifadhi',
      'settings': 'Mipangilio',
      'cart': 'Kikapu',
      'greeting': 'Hebu tuweke mipangilio',
      'darkMode': 'Hali ya giza',
      'highContrast': 'Utofautishaji wa juu',
      'accentColor': 'Rangi kuu',
      'language': 'Lugha',
      'toastSuccess': 'Imehifadhiwa',
      'toastError': 'Hitilafu imetokea',
    },
  };

  String t(String key) => _strings[_language]?[key] ?? key;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kLanguage);
    _language = AppLanguage.values.firstWhere(
      (l) => l.name == name,
      orElse: () => AppLanguage.english,
    );
    notifyListeners();
  }

  void setLanguage(AppLanguage language) async {
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, language.name);
  }
}
