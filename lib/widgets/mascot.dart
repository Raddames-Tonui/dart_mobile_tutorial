import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_controller.dart';

/// ---------------------------------------------------------------------
/// Mascot — a small animated character, the Duolingo-owl-style touch:
/// a bit of personality living in the corner of the UI rather than a
/// static logo. Built with a plain AnimationController bobbing loop —
/// no Rive/Lottie dependency, consistent with this project's "hand-roll
/// it" approach. Swapping this for a real Rive/Lottie character file
/// later is the natural next step if you want proper animation.
/// ---------------------------------------------------------------------
class Mascot extends StatefulWidget {
  final double size;

  const Mascot({super.key, this.size = 40});

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bob;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _bob = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        return Transform.translate(offset: Offset(0, _bob.value), child: child);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(color: colors.primary, width: 1.4),
        ),
        child: Text('🦉', style: TextStyle(fontSize: widget.size * 0.55)),
      ),
    );
  }
}
