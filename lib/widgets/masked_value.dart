import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/visibility_controller.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// ---------------------------------------------------------------------
/// MaskedValue — the Flutter equivalent of the web app's MaskedValue
/// component: renders a masked value by default, with an explicit
/// reveal toggle, and re-masks automatically the instant the app
/// leaves the foreground — even if it was mid-"revealed" when that
/// happened. See VisibilityController for why this matters more on
/// mobile than on web (OS app-switcher screenshots).
/// ---------------------------------------------------------------------
class MaskedValue extends StatefulWidget {
  final String value;
  final String label;

  const MaskedValue({super.key, required this.value, required this.label});

  @override
  State<MaskedValue> createState() => _MaskedValueState();
}

class _MaskedValueState extends State<MaskedValue> {
  bool _revealed = false;

  String get _masked {
    if (widget.value.length <= 4) return '••••';
    final tail = widget.value.substring(widget.value.length - 4);
    return ('•' * (widget.value.length - 4)) + tail;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final visibility = context.watch<VisibilityController>();

    // Re-mask the instant the app is backgrounded, matching the web
    // app's blur-on-tab-hidden behavior — even if this rebuild wasn't
    // triggered by the user tapping "Hide".
    if (!visibility.isForeground && _revealed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _revealed = false);
      });
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: AppText.label(colors)),
              Text(
                _revealed ? widget.value : _masked,
                style: AppText.body(colors).copyWith(fontFamily: 'monospace', letterSpacing: 1.1),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _revealed = !_revealed),
          child: Text(
            _revealed ? 'Hide' : 'Show',
            style: AppText.body(colors).copyWith(color: colors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
