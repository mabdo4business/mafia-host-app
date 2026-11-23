import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

Map<String, dynamic> _arb(String lang) =>
    json.decode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m.group(1)!).toSet()
      ..removeAll(const {'plural', 'select'});

void main() {
  group('ARB parity', () {
    final en = _arb('en');
    final ar = _arb('ar');
    Set<String> keys(Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();

    test('en and ar have the same keys', () {
      expect(keys(ar).difference(keys(en)), isEmpty, reason: 'only in ar');
      expect(keys(en).difference(keys(ar)), isEmpty, reason: 'missing in ar');
    });

    test('every ar message uses exactly the placeholders en declares', () {
      for (final k in keys(en)) {
        final meta = en['@$k'] as Map<String, dynamic>?;
        final declared = (meta?['placeholders'] as Map<String, dynamic>?)?.keys.toSet() ?? {};
        expect(_placeholders(ar[k] as String), declared, reason: k);
      }
    });

    test('every ar value is non-empty', () {
      for (final k in keys(ar)) {
        expect((ar[k] as String).trim(), isNotEmpty, reason: k);
      }
    });
  });

  // Arabic noun forms: 1 / 2 are their own words, 3–10 plural, 11–99
  // accusative singular (tanween), 0 and 100+ genitive singular.
  group('Arabic counts', () {
    final l = lookupAppLocalizations(const Locale('ar'));

    test('players: the usual 11-player table is لاعبًا, not لاعبين', () {
      expect(l.recentDetail(4, 1), 'الليلة 4 · لاعب واحد');
      expect(l.recentDetail(4, 2), 'الليلة 4 · لاعبان');
      expect(l.recentDetail(4, 7), 'الليلة 4 · 7 لاعبين');
      expect(l.recentDetail(4, 11), 'الليلة 4 · 11 لاعبًا');
      expect(l.recentDetail(4, 100), 'الليلة 4 · 100 لاعب');
    });

    test('event night detail counts games and players separately', () {
      expect(l.eventsNightDetail(2, 11), 'لعبتان · 11 لاعبًا');
      expect(l.eventsNightDetail(3, 12), '3 ألعاب · 12 لاعبًا');
    });

    test('wins, votes and games use the 100+ form', () {
      expect(l.leaderboardWins(11), '11 انتصارًا');
      expect(l.leaderboardWins(100), '100 انتصار');
      expect(l.logVotesFor('ليلى', 11), 'ليلى: 11 صوتًا');
      expect(l.logVotesFor('ليلى', 100), 'ليلى: 100 صوت');
      expect(l.leaderboardRowDetail(120, 54), '120 لعبة · فوز 54٪');
    });

    test('game over: survivors agree with the verb', () {
      expect(l.gameOverSummary(4, 1), 'بعد 4 ليالٍ · واحد ما زال صامدًا');
      expect(l.gameOverSummary(4, 2), 'بعد 4 ليالٍ · اثنان ما زالا صامدَين');
      expect(l.gameOverSummary(4, 5), 'بعد 4 ليالٍ · 5 ما زالوا صامدين');
    });

    test('setup minimum follows the count', () {
      expect(l.setupProblemTooFewPlayers(4), 'أضف 4 لاعبين على الأقل.');
      expect(l.setupProblemTooFewPlayers(11), 'أضف 11 لاعبًا على الأقل.');
    });
  });

  group('English counts', () {
    final l = lookupAppLocalizations(const Locale('en'));

    test('singular and plural players', () {
      expect(l.recentDetail(4, 1), 'Night 4 · 1 player');
      expect(l.recentDetail(4, 11), 'Night 4 · 11 players');
      expect(l.eventsNightDetail(1, 11), '1 game · 11 players');
      expect(l.setupProblemTooFewPlayers(4), 'Add at least 4 players.');
    });
  });
}
