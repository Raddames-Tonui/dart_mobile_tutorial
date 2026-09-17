import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../state/session_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/raw_button.dart';
import '../widgets/raw_card.dart';
import '../widgets/raw_input.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final _localController = TextEditingController();
  final _secureController = TextEditingController();
  final _sessionController = TextEditingController();

  String? _localValue;
  String? _secureValue;

  @override
  void initState() {
    super.initState();
    _loadStoredValues();
  }

  Future<void> _loadStoredValues() async {
    final local = await StorageService.readLocal('demo_local_key');
    final secure = await StorageService.readSecure('demo_secure_key');
    if (!mounted) return;
    setState(() {
      _localValue = local;
      _secureValue = secure;
    });
  }

  @override
  void dispose() {
    _localController.dispose();
    _secureController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette colors = context.watch<ThemeController>().colors;
    final session = context.watch<SessionState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Storage', style: AppText.heading1(colors)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Three tiers, mapped from the web concepts you already know. '
            'Theme and language (Settings) intentionally use the plain '
            '"localStorage" tier too — they carry no sensitive information, '
            'the same reasoning the web app uses.',
            style: AppText.caption(colors),
          ),
          const SizedBox(height: AppSpacing.lg),

          _StorageTierCard(
            title: 'shared_preferences  —  "localStorage"',
            description:
                'Plaintext, unencrypted. Fine for a theme choice or a locale. '
                'Never put a token or anything sensitive here — in a fintech '
                'app this is the one place tokens must NOT go.',
            controller: _localController,
            currentValue: _localValue,
            onSave: () async {
              await StorageService.saveLocal('demo_local_key', _localController.text);
              await _loadStoredValues();
            },
            onClear: () async {
              await StorageService.clearLocal('demo_local_key');
              await _loadStoredValues();
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _StorageTierCard(
            title: 'flutter_secure_storage  —  "secure cookie"',
            description:
                'Backed by iOS Keychain / Android Keystore — encrypted at '
                'the OS level. This is where a JWT or refresh token belongs.',
            controller: _secureController,
            currentValue: _secureValue,
            onSave: () async {
              await StorageService.saveSecure('demo_secure_key', _secureController.text);
              await _loadStoredValues();
            },
            onClear: () async {
              await StorageService.clearSecure('demo_secure_key');
              await _loadStoredValues();
            },
          ),
          const SizedBox(height: AppSpacing.md),

          RawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Provider ChangeNotifier  —  "sessionStorage"', style: AppText.heading2(colors)),
                const SizedBox(height: 4),
                Text(
                  'Lives in RAM only. Gone the instant the app process is '
                  'killed — not just backgrounded. Good for a short-lived '
                  "value you deliberately don't want to survive a restart.",
                  style: AppText.caption(colors),
                ),
                const SizedBox(height: AppSpacing.sm),
                RawInput(label: 'Value', controller: _sessionController),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: RawButton(
                        label: 'Save to session',
                        onPressed: () => session.setSessionValue(_sessionController.text),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: RawButton(label: 'Clear', outlined: true, onPressed: session.clear),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Currently held in memory: ${session.sessionValue ?? "(nothing)"}',
                    style: AppText.body(colors)),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          RawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A note on cookies', style: AppText.heading2(colors)),
                const SizedBox(height: 4),
                Text(
                  "Your backend's auth system uses HttpOnly, SameSite cookies "
                  "for browser clients. Flutter's HTTP clients (Dio, http) "
                  "don't carry a cookie jar automatically the way a browser "
                  'does. For this mobile app, the backend would issue a '
                  'bearer JWT instead (its "BEARER mode", X-Client-Type: '
                  'BEARER header) — stored in flutter_secure_storage, sent '
                  'as an Authorization header on every request.',
                  style: AppText.body(colors),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageTierCard extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final String? currentValue;
  final VoidCallback onSave;
  final VoidCallback onClear;

  const _StorageTierCard({
    required this.title,
    required this.description,
    required this.controller,
    required this.currentValue,
    required this.onSave,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return RawCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading2(colors)),
          const SizedBox(height: 4),
          Text(description, style: AppText.caption(colors)),
          const SizedBox(height: AppSpacing.sm),
          RawInput(label: 'Value', controller: controller),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: RawButton(label: 'Save', onPressed: onSave)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: RawButton(label: 'Clear', outlined: true, onPressed: onClear)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Currently stored: ${currentValue ?? "(nothing)"}', style: AppText.body(colors)),
        ],
      ),
    );
  }
}
