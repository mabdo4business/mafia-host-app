import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;
import 'package:mafia_engine/mafia_engine.dart';

import '../game/game_session.dart';
import '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Formats a number with the current locale's digits.
  String number(int n) =>
      NumberFormat.decimalPattern(Localizations.localeOf(this).toString()).format(n);

  /// Zero-padded two digits in the current locale ("07", "٠٧").
  String twoDigits(int n) => NumberFormat('00', Localizations.localeOf(this).toString()).format(n);
}

extension RoleText on AppLocalizations {
  String role(Role r) => switch (r) {
    Role.godfather => roleGodfather,
    Role.mafia => roleMafia,
    Role.putana => rolePutana,
    Role.lawyer => roleLawyer,
    Role.witch => roleWitch,
    Role.detective => roleDetective,
    Role.doctor => roleDoctor,
    Role.joker => roleJoker,
    Role.switchman => roleSwitchman,
    Role.silencer => roleSilencer,
    Role.bomb => roleBomb,
    Role.shapeshifter => roleShapeshifter,
    Role.chameleon => roleChameleon,
    Role.tnt => roleTnt,
    Role.civilian => roleCivilian,
  };

  /// What the role does, as told on its card.
  String ability(Role r) => switch (r) {
    Role.godfather => abilityGodfather,
    Role.mafia => abilityMafia,
    Role.putana => abilityPutana,
    Role.lawyer => abilityLawyer,
    Role.witch => abilityWitch,
    Role.detective => abilityDetective,
    Role.doctor => abilityDoctor,
    Role.joker => abilityJoker,
    Role.switchman => abilitySwitchman,
    Role.silencer => abilitySilencer,
    Role.bomb => abilityBomb,
    Role.shapeshifter => abilityShapeshifter,
    Role.chameleon => abilityChameleon,
    Role.tnt => abilityTnt,
    Role.civilian => abilityCivilian,
  };

  String team(Team t) => switch (t) {
    Team.civilians => teamCivilians,
    Team.mafia => teamMafia,
  };

  /// "Doctor", or "Chameleon as Doctor" once a Chameleon has chosen.
  String playerRole(Player p) => p.role == Role.chameleon && p.chameleonRole != null
      ? chameleonAs(role(p.chameleonRole!))
      : role(p.role);

  String names(Iterable<String> names) => names.join(listSeparator);

  String stageTitle(GameSession s) => switch (s.stage) {
    GameStage.night => stageNight(s.round),
    GameStage.morning => stageMorning(s.round),
    GameStage.day || GameStage.dayResult => stageDay(s.round),
    GameStage.gameOver => stageGameOver,
  };
}

/// The app's localization delegates. Not the generated
/// `AppLocalizations.localizationsDelegates`: as of Flutter 3.50, gen-l10n
/// still lists flutter_localizations' Material/Cupertino delegates, which
/// material_ui's MaterialApp doesn't recognize (Arabic would have no
/// Material strings and the AppBar throws).
const List<LocalizationsDelegate<Object>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];
