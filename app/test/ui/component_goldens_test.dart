import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_host/common/l10n.dart';
import 'package:mafia_host/features/gallery/component_catalog.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
import 'package:mafia_host/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

/// Golden for every component sample in the gallery, in English and Arabic.
/// Update with `flutter test --update-goldens test/ui`.
void main() {
  for (final sample in componentCatalog) {
    for (final lang in const ['en', 'ar']) {
      testWidgets('${sample.id} ($lang)', (tester) async {
        // Real shadow blur, as on device (tests flatten shadows by default).
        debugDisableShadows = false;
        addTearDown(() => debugDisableShadows = true);
        final locale = Locale(lang);
        tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final theme = sample.phase == Phase.night ? AppTheme.night(locale) : AppTheme.day(locale);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            theme: theme,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // The golden is the sample's own height at 390 wide.
            home: UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              alignment: AlignmentDirectional.topStart,
              child: Builder(
                builder: (context) => RepaintBoundary(
                  key: const Key('golden'),
                  child: ColoredBox(
                    color: context.mafia.bg,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(Space.page),
                      child: sample.build(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(const Key('golden')),
          matchesGoldenFile('goldens/${sample.id}_$lang.png'),
        );
      });
    }
  }
}
