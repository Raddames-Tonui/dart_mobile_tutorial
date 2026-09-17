import 'package:flutter/widgets.dart';

/// ---------------------------------------------------------------------
/// VisibilityController — mirrors the web app's tab-hidden/blur privacy
/// signal. On mobile the equivalent event is the app being backgrounded
/// (AppLifecycleState leaving "resumed"), which matters even more here:
/// a backgrounded app can appear in the OS's app-switcher screenshot,
/// so masking sensitive values before that screenshot is taken is a
/// real leak-prevention measure, not just a nicety.
/// ---------------------------------------------------------------------
class VisibilityController extends ChangeNotifier with WidgetsBindingObserver {
  bool _isForeground = true;

  bool get isForeground => _isForeground;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final nowForeground = state == AppLifecycleState.resumed;
    if (nowForeground != _isForeground) {
      _isForeground = nowForeground;
      notifyListeners();
    }
  }
}
