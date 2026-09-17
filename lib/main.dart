import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_shell.dart';
import 'state/cart_state.dart';
import 'state/locale_controller.dart';
import 'state/session_state.dart';
import 'state/visibility_controller.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  final localeController = LocaleController();
  final visibilityController = VisibilityController()..attach();

  // Loaded before runApp — the closest mobile equivalent to the web
  // app's synchronous pre-paint theme script: avoids a flash of the
  // default theme/language before the persisted choice loads.
  await Future.wait([themeController.load(), localeController.load()]);

  runApp(SunfyreProtoApp(
    themeController: themeController,
    localeController: localeController,
    visibilityController: visibilityController,
  ));
}

class SunfyreProtoApp extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;
  final VisibilityController visibilityController;

  const SunfyreProtoApp({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.visibilityController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider.value(value: visibilityController),
        ChangeNotifierProvider(create: (_) => SessionState()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          final colors = theme.colors;
          // ColorScheme.fromSeed lets the few remaining stock Material
          // widgets we use (Switch, DropdownButton) also follow the
          // active accent/dark-mode combination, not just our RawX ones.
          return MaterialApp(
            title: 'Sunfyre Mobile Prototype',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: colors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: colors.primary,
                brightness: theme.isDark ? Brightness.dark : Brightness.light,
              ),
            ),
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
