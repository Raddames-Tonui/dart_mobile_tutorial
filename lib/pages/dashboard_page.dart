import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/mascot.dart';
import '../widgets/raw_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPalette colors = context.watch<ThemeController>().colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Mascot(size: 44),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Widget Tree', style: AppText.heading1(colors))),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Everything you see on screen is a node in a tree, the same '
            'way a web page is a DOM tree. Flutter just calls its nodes '
            '"widgets" instead of "elements".',
            style: AppText.body(colors),
          ),
          const SizedBox(height: AppSpacing.lg),

          RawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("This app's tree", style: AppText.heading2(colors)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'MaterialApp\n'
                  '└─ HomeShell (AppBar + Drawer)\n'
                  '    └─ IndexedStack\n'
                  '        ├─ DashboardPage   (you are here)\n'
                  '        ├─ TablePage  ──add──> shared CartState\n'
                  '        ├─ FormPage\n'
                  '        │   └─ (push) FormSuccessPage\n'
                  '        └─ StoragePage\n'
                  '    └─ RawBottomNav\n'
                  '    (push) SettingsPage, CartPage — reached from the\n'
                  '    Drawer/AppBar, not tabs of their own',
                  style: AppText.mono(colors),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          RawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Two kinds of "tree" in this app', style: AppText.heading2(colors)),
                const SizedBox(height: AppSpacing.sm),
                _bullet(
                  colors,
                  'The IndexedStack tree (tabs)',
                  'All four tabs exist at once, stacked on top of each '
                  'other. Switching tabs just changes which one is '
                  'visible — state is preserved. Like four browser tabs.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _bullet(
                  colors,
                  'The Navigator tree (stack)',
                  'Form → FormSuccessPage, and the Drawer/cart icon → '
                  'SettingsPage/CartPage, are all pushes onto the stack — '
                  "they don't have tabs of their own, and pop() returns "
                  'you exactly where you started.',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          RawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What each part demonstrates', style: AppText.heading2(colors)),
                const SizedBox(height: AppSpacing.sm),
                _bullet(colors, 'Table',
                    'A mock async GET, a skeleton loading state, client-side filter, a masked account number, and "add to cart".'),
                _bullet(colors, 'Form',
                    'Validated input, a mock POST, a success toast, then a pushed confirmation page.'),
                _bullet(colors, 'Storage',
                    'localStorage vs. secure storage vs. session-state, side by side.'),
                _bullet(colors, 'Settings (Drawer → Settings)',
                    'Dark/light mode, high contrast, 4 accent colors, and a language switch — all persisted.'),
                _bullet(colors, 'Cart (AppBar icon)',
                    'State shared across pages via Provider, independent of which tab is visible.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(AppPalette colors, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: RichText(
        text: TextSpan(
          style: AppText.body(colors),
          children: [
            TextSpan(text: '• $title — ', style: AppText.body(colors).copyWith(fontWeight: FontWeight.w600)),
            TextSpan(text: body),
          ],
        ),
      ),
    );
  }
}
