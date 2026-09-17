import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/toast_service.dart';
import '../state/cart_state.dart';
import '../state/locale_controller.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/mascot.dart';
import 'cart_page.dart';
import 'dashboard_page.dart';
import 'form_page.dart';
import 'settings_page.dart';
import 'storage_page.dart';
import 'table_page.dart';

/// ---------------------------------------------------------------------
/// HomeShell — root of the navigation tree.
///
///   HomeShell (Scaffold: AppBar + Drawer + IndexedStack + BottomNav)
///     ├── AppBar: hamburger → Drawer, mascot + brand, cart icon (push)
///     ├── Drawer: quick theme toggle, Settings (push), logout (demo)
///     ├── IndexedStack (tabs, state preserved across switches)
///     │     ├── DashboardPage
///     │     ├── TablePage
///     │     ├── FormPage  ──push──> FormSuccessPage
///     │     └── StoragePage
///     └── RawBottomNav
///
/// Two different "tree" mechanics on purpose: IndexedStack keeps every
/// tab alive (like four browser tabs), while Navigator.push for
/// FormSuccessPage/SettingsPage/CartPage is a real stack — those pages
/// don't exist until pushed, and pop() removes them entirely.
/// ---------------------------------------------------------------------
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final _pages = const [
    DashboardPage(),
    TablePage(),
    FormPage(),
    StoragePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = controller.colors;
    final locale = context.watch<LocaleController>();

    final tabs = [
      _TabDef(label: locale.t('tree'), icon: Icons.account_tree_outlined),
      _TabDef(label: locale.t('table'), icon: Icons.table_chart_outlined),
      _TabDef(label: locale.t('form'), icon: Icons.edit_note_outlined),
      _TabDef(label: locale.t('storage'), icon: Icons.lock_outline),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _RawAppBar(
          colors: colors,
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const _RawDrawer(),
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: _RawBottomNav(
        tabs: tabs,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _TabDef {
  final String label;
  final IconData icon;
  const _TabDef({required this.label, required this.icon});
}

/// Custom top bar: hamburger (opens the Drawer, this app's "sidebar"),
/// a bouncing Mascot + brand, and a cart icon with a live badge.
class _RawAppBar extends StatelessWidget {
  final AppPalette colors;
  final VoidCallback onMenuTap;

  const _RawAppBar({required this.colors, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              GestureDetector(onTap: onMenuTap, child: Icon(Icons.menu, color: colors.textPrimary)),
              const SizedBox(width: AppSpacing.sm),
              const Mascot(size: 32),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Sunfyre', style: AppText.heading2(colors))),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: colors.textPrimary),
                    if (cart.count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: colors.danger, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${cart.count}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "sidebar" — a standard Flutter Drawer, styled to match the rest
/// of the app. Holds a quick theme toggle and a push to SettingsPage.
class _RawDrawer extends StatelessWidget {
  const _RawDrawer();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = controller.colors;
    final locale = context.watch<LocaleController>();

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: colors.background,
              child: Row(
                children: [
                  const Mascot(size: 44),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sunfyre', style: AppText.heading2(colors)),
                      Text('Prototype build', style: AppText.caption(colors)),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: colors.textPrimary),
              title: Text(locale.t('settings'), style: AppText.body(colors)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: Icon(
                controller.isDark ? Icons.dark_mode : Icons.light_mode,
                color: colors.textPrimary,
              ),
              title: Text(locale.t('darkMode'), style: AppText.body(colors)),
              trailing: Switch(
                value: controller.isDark,
                activeColor: colors.primary,
                onChanged: (_) => controller.toggleMode(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: colors.danger),
              title: Text('Log out (demo)', style: AppText.body(colors)),
              onTap: () {
                Navigator.of(context).pop();
                ToastService.show(context, message: 'Logged out (demo only)', type: ToastType.info);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A bottom nav bar built from a bare Row of GestureDetectors instead
/// of BottomNavigationBar — full manual control, following the active
/// theme via ThemeController.
class _RawBottomNav extends StatelessWidget {
  final List<_TabDef> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _RawBottomNav({required this.tabs, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = i == currentIndex;
            final tab = tabs[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: 22, color: active ? colors.primary : colors.textSecondary),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: AppText.caption(colors).copyWith(
                        color: active ? colors.primary : colors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
