// Debug-only developer tool (registered under kDebugMode). Its chrome is
// not user-facing, so its few labels are not localized.

import 'package:material_ui/material_ui.dart';

import '../../ui/ui.dart';
import 'component_catalog.dart';
import 'screen_catalog.dart';

/// Every lib/ui component with live previews. Toggle language (and so
/// direction) and night/day theme from the app bar.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  static const route = '/gallery';

  /// Prefix for seeded screens: `/gallery/screen/<id>`.
  static const screenRoute = '/gallery/screen/';

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Locale? _locale;

  /// Null shows each component in its own phase.
  Phase? _phase;

  @override
  Widget build(BuildContext context) {
    final locale = _locale ?? Localizations.localeOf(context);
    final ar = locale.languageCode == 'ar';
    return Localizations.override(
      context: context,
      locale: locale,
      child: Builder(
        builder: (context) => Theme(
          data: AppTheme.night(locale),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Components'),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _locale = Locale(ar ? 'en' : 'ar')),
                  child: Text(ar ? 'EN' : 'AR'),
                ),
                TextButton(
                  onPressed: () => setState(
                    () => _phase = switch (_phase) {
                      null => Phase.night,
                      Phase.night => Phase.day,
                      Phase.day => null,
                    },
                  ),
                  child: Text(_phase?.name ?? 'auto'),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: componentCatalog.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.all(Space.lg),
                    child: Wrap(
                      spacing: Space.sm,
                      runSpacing: Space.sm,
                      children: [
                        for (final sc in screenCatalog)
                          ActionChip(
                            label: Text(sc.id),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => Localizations.override(
                                  context: context,
                                  locale: locale,
                                  child: Builder(
                                    builder: (context) => Theme(
                                      data: AppTheme.night(locale),
                                      child: Builder(builder: sc.build),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                final s = componentCatalog[index - 1];
                final phase = _phase ?? s.phase;
                return Theme(
                  data: phase == Phase.night ? AppTheme.night(locale) : AppTheme.day(locale),
                  child: Builder(
                    builder: (context) => ColoredBox(
                      color: context.mafia.bg,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          Space.page,
                          Space.xl,
                          Space.page,
                          Space.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              s.id,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ).copyWith(color: context.mafia.textMuted),
                            ),
                            const SizedBox(height: Space.md),
                            s.build(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
