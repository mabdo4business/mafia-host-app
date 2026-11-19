import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/l10n.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/home/home_screen.dart';
import 'game/providers.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

class MafiaHostApp extends ConsumerWidget {
  const MafiaHostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).value ?? const AppPreferences();
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: prefs.locale,
      theme: AppTheme.night(prefs.locale ?? const Locale('en')),
      // The fonts depend on the resolved locale (which may come from the
      // device), so re-theme below Localizations.
      builder: (context, child) =>
          Theme(data: AppTheme.night(Localizations.localeOf(context)), child: child!),
      home: const HomeScreen(),
      routes: {if (kDebugMode) GalleryScreen.route: (_) => const GalleryScreen()},
    );
  }
}
