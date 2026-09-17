import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

enum ToastType { success, error, info, warning }

/// ---------------------------------------------------------------------
/// ToastService — the Sonner equivalent. A dismiss-and-forget notice
/// that never blocks input, built on Flutter's own Overlay rather than
/// a package, matching this project's "build it yourself" approach.
///
/// Per the README's toast-vs-dialog distinction: use this for
/// low-stakes notices (a background save completed). Anything the
/// person must consciously acknowledge before continuing belongs in a
/// real showDialog() instead — that's already Future-based in Flutter,
/// so it reads almost exactly like a BC-style
/// `await dialog.confirm(...)` singleton would.
/// ---------------------------------------------------------------------
class ToastService {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
  }) {
    final overlay = Overlay.of(context);
    final colors = context.read<ThemeController>().colors;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        colors: colors,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final AppPalette colors;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.colors,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _slide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case ToastType.success:
        return widget.colors.success;
      case ToastType.error:
        return widget.colors.danger;
      case ToastType.warning:
        return const Color(0xFFE8A33D);
      case ToastType.info:
        return widget.colors.primary;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border(left: BorderSide(color: _accentColor, width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icon, color: _accentColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(widget.message, style: AppText.body(widget.colors)),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(Icons.close, size: 16, color: widget.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
