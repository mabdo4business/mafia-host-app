import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const AppPreferences();
    final controller = ref.read(preferencesProvider.notifier);

    Widget option(String label, bool selected, VoidCallback onTap) => ListTile(
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: onTap,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          SectionHeader(l.settingsLanguage),
          option(l.settingsSystemDefault, prefs.locale == null, () => controller.setLocale(null)),
          // Language names are shown in their own language on purpose.
          option(
            l.languageEnglish,
            prefs.locale?.languageCode == 'en',
            () => controller.setLocale(const Locale('en')),
          ),
          option(
            l.languageArabic,
            prefs.locale?.languageCode == 'ar',
            () => controller.setLocale(const Locale('ar')),
          ),
          SectionHeader(l.settingsTheme),
          for (final (mode, label) in [
            (ThemeMode.system, l.settingsSystemDefault),
            (ThemeMode.light, l.themeLight),
            (ThemeMode.dark, l.themeDark),
          ])
            option(label, prefs.themeMode == mode, () => controller.setThemeMode(mode)),
        ],
      ),
    );
  }
}
