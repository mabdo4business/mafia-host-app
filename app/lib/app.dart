import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/l10n.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/gallery/screen_catalog.dart';
import 'features/gallery/screen_tour.dart';
import 'features/shell/main_shell.dart';
import 'game/providers.dart';
import 'l10n/app_localizations.dart';
import 'ui/ui.dart';

class MafiaHostApp extends ConsumerWidget {
  const MafiaHostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).value ?? const AppPreferences();
    Haptics.enabled = prefs.hapticsEnabled;
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
      home: const MainShell(),
      routes: {
        if (kDebugMode) GalleryScreen.route: (_) => const GalleryScreen(),
        if (kDebugMode) ScreenTour.route: (_) => const ScreenTour(),
      },
      // Debug: `flutter run --route /gallery/screen/night` opens a seeded screen.
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (!kDebugMode || !name.startsWith(GalleryScreen.screenRoute)) return null;
        final id = name.substring(GalleryScreen.screenRoute.length);
        final scenario = screenCatalog.where((s) => s.id == id).firstOrNull;
        return scenario == null ? null : MaterialPageRoute(builder: scenario.build);
      },
    );
  }
}
