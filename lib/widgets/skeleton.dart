import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// ---------------------------------------------------------------------
/// RawSkeleton — a shimmering placeholder block, the Flutter analog of
/// the web app's Skeleton/SkeletonList components. Built with a plain
/// AnimationController + LinearGradient sweep rather than pulling in a
/// shimmer package, staying consistent with this project's "build it
/// from Containers" approach.
/// ---------------------------------------------------------------------
class RawSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const RawSkeleton({super.key, this.height = 14, this.width, this.borderRadius});

  @override
  State<RawSkeleton> createState() => _RawSkeletonState();
}

class _RawSkeletonState extends State<RawSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final base = colors.border.withOpacity(0.35);
    final highlight = colors.border.withOpacity(0.12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.sm),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0),
              end: Alignment(1.0 - _controller.value * 2, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A row-shaped skeleton matching RawTable's row layout, used while the
/// mock API "GET" call is in flight.
class RawTableSkeleton extends StatelessWidget {
  final int rows;

  const RawTableSkeleton({super.key, this.rows = 6});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = controller.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.effectiveBorder(controller.highContrast)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(rows, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                const Expanded(flex: 3, child: RawSkeleton(height: 14)),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(flex: 2, child: RawSkeleton(height: 14)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: RawSkeleton(height: 20, borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(flex: 2, child: RawSkeleton(height: 14)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
