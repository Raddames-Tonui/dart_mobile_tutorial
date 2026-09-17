import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------
/// SessionState — the "sessionStorage" analog.
///
/// Lives entirely in memory via ChangeNotifier + Provider. It behaves
/// like a web sessionStorage tab: available anywhere in the widget
/// tree while the app process is alive, and wiped the moment the app
/// is fully killed (not just backgrounded — Flutter apps can be
/// backgrounded and resumed without losing memory state on most
/// platforms, so this is closer to "gone on process death" than
/// "gone on tab close").
/// ---------------------------------------------------------------------
class SessionState extends ChangeNotifier {
  String? _sessionValue;

  String? get sessionValue => _sessionValue;

  void setSessionValue(String value) {
    _sessionValue = value;
    notifyListeners();
  }

  void clear() {
    _sessionValue = null;
    notifyListeners();
  }
}
