// Debug-only: shows every seeded screen in English, then Arabic, a few
// seconds each, logging "TOUR <id>_<lang>" so screenshots can be taken on a
// simulator (`flutter run --route /gallery/tour`).

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';
import 'screen_catalog.dart';

class ScreenTour extends StatefulWidget {
  const ScreenTour({super.key, this.seconds = 6});

  static const route = '/gallery/tour';

  final int seconds;

  @override
  State<ScreenTour> createState() => _ScreenTourState();
}

class _ScreenTourState extends State<ScreenTour> {
  static const _langs = ['en', 'ar'];
  int _i = 0;
  Timer? _timer;

  int get _count => screenCatalog.length * _langs.length;

  @override
  void initState() {
    super.initState();
    _log();
    _timer = Timer.periodic(Duration(seconds: widget.seconds), (t) {
      if (_i + 1 >= _count) {
        t.cancel();
        debugPrint('TOUR done');
        return;
      }
      setState(() => _i++);
      _log();
    });
  }

  void _log() {
    final s = screenCatalog[_i % screenCatalog.length];
    debugPrint('TOUR ${s.id}_${_langs[_i ~/ screenCatalog.length]}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = screenCatalog[_i % screenCatalog.length];
    final locale = Locale(_langs[_i ~/ screenCatalog.length]);
    return Localizations.override(
      key: ValueKey(_i),
      context: context,
      locale: locale,
      child: Builder(
        builder: (context) => Theme(
          data: AppTheme.night(locale),
          child: Builder(builder: s.build),
        ),
      ),
    );
  }
}
