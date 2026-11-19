import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Arabic UI uses Western digits throughout (as NumberFormat('ar') does).
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
  LicenseRegistry.addLicense(_fontLicenses);
  runApp(const ProviderScope(child: MafiaHostApp()));
}

/// The bundled fonts' SIL Open Font License texts, for the licenses page.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final (font, package) in const [
    ('unbounded', 'Unbounded'),
    ('inter', 'Inter'),
    ('cairo', 'Cairo'),
    ('ibmplexsansarabic', 'IBM Plex Sans Arabic'),
  ]) {
    final text = await rootBundle.loadString('assets/fonts/OFL-$font.txt');
    yield LicenseEntryWithLineBreaks([package], text);
  }
}
