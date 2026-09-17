import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ---------------------------------------------------------------------
/// StorageService — the three storage tiers mapped from web to Flutter.
///
/// | Web                       | Flutter                 | Backing                          |
/// |----------------------------|--------------------------|-----------------------------------|
/// | localStorage (plaintext)   | shared_preferences       | Plist (iOS) / XML (Android)       |
/// | Secure, HttpOnly cookie    | flutter_secure_storage   | iOS Keychain / Android Keystore   |
/// | sessionStorage             | In-memory app state      | RAM only, gone on process kill    |
///
/// Cookies themselves don't exist automatically in Flutter's HTTP
/// clients the way they do in a browser — Dio/http don't manage a
/// cookie jar unless you add one (`dio_cookie_manager`). Most mobile
/// apps skip cookies entirely and use a bearer JWT in an Authorization
/// header instead, stored via flutter_secure_storage.
/// ---------------------------------------------------------------------
class StorageService {
  static const _secureStorage = FlutterSecureStorage();

  // ---- "localStorage" tier: plaintext, unencrypted -------------------
  static Future<void> saveLocal(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> readLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> clearLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // ---- Secure tier: Keychain / Keystore, encrypted at rest -----------
  static Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> readSecure(String key) async {
    return _secureStorage.read(key: key);
  }

  static Future<void> clearSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
}
