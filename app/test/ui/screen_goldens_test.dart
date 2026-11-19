import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_host/common/l10n.dart';
import 'package:mafia_host/features/gallery/screen_catalog.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
import 'package:mafia_host/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

/// Every main screen in its seeded mockup state, at 390×844, in English and
/// Arabic. Update with `flutter test --update-goldens test/ui`.
void main() {
  for (final scenario in screenCatalog) {
    for (final lang in const ['en', 'ar']) {
      testWidgets('${scenario.id} ($lang)', (tester) async {
        debugDisableShadows = false;
        addTearDown(() => debugDisableShadows = true);
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
        tester.view.viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
        addTearDown(tester.view.reset);
        final locale = Locale(lang);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            theme: AppTheme.night(locale),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // End states (announcements in, sun risen).
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: RepaintBoundary(
              key: const Key('golden'),
              child: Builder(builder: scenario.build),
            ),
          ),
        );
        // Providers load asynchronously (in-memory database).
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(const Key('golden')),
          matchesGoldenFile('goldens/screens/${scenario.id}_$lang.png'),
        );
      });
    }
  }
}
