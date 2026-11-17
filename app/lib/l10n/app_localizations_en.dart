// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mafia Host';

  @override
  String get homeTagline => 'Run Mafia nights with physical cards — one phone, fully offline.';

  @override
  String get homeNewGame => 'New game';

  @override
  String get homeContinueGame => 'Continue';

  @override
  String get newGameConfirmTitle => 'Start a new game?';

  @override
  String get newGameConfirmBody => 'The game in progress will be closed.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSystemDefault => 'Device setting';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsSoundSection => 'Sound';

  @override
  String get settingsSound => 'Sound effects';

  @override
  String get settingsSoundSubtitle => 'A chime when night falls and when morning comes';

  @override
  String get roleCivilian => 'Civilian';

  @override
  String get roleDoctor => 'Doctor';

  @override
  String get roleDetective => 'Detective';

  @override
  String get roleBomb => 'Bomb';

  @override
  String get roleJoker => 'Joker';

  @override
  String get roleChameleon => 'Chameleon';

  @override
  String get roleMafia => 'Mafia';

  @override
  String get roleGodfather => 'Godfather';

  @override
  String get rolePotana => 'Potana';

  @override
  String get roleLawyer => 'Lawyer';

  @override
  String get teamCivilians => 'Civilians';

  @override
  String get teamMafia => 'Mafia';

  @override
  String chameleonAs(String role) {
    return 'Chameleon as $role';
  }

  @override
  String get listSeparator => ', ';

  @override
  String stageNight(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'Night $roundString';
  }

  @override
  String stageMorning(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'Morning $roundString';
  }

  @override
  String stageDay(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'Day $roundString';
  }

  @override
  String get stageGameOver => 'Game over';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get hostOnly => 'Host only';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get setupTitle => 'New game';

  @override
  String get setupPlayersSection => 'Players (seating order)';

  @override
  String playerCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString players',
      one: '1 player',
      zero: 'No players yet',
    );
    return '$_temp0';
  }

  @override
  String get setupPlayerNameHint => 'Player name';

  @override
  String get setupAddPlayer => 'Add player';

  @override
  String get setupRemovePlayer => 'Remove';

  @override
  String get setupRolesSection => 'Roles';

  @override
  String get setupSuggestedMix => 'Suggested mix';

  @override
  String get setupOptionsSection => 'Options';

  @override
  String get setupBombVictims => 'Bomb victims';

  @override
  String get setupRevealRole => 'Reveal role on death';

  @override
  String get setupDiscussionTimer => 'Discussion timer';

  @override
  String get timerOff => 'Off';

  @override
  String minutes(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get setupHouseRules => 'House rules';

  @override
  String get ruleDoctorSaveBlocksJoker => 'Doctor\'s save also stops the Joker';

  @override
  String get ruleDoctorCanSaveBombVictims => 'Doctor can save Bomb victims';

  @override
  String get ruleBlockedBombExplodes => 'Blocked Bomb still explodes';

  @override
  String get ruleChameleonMafia => 'Chameleon can pick Mafia roles';

  @override
  String get ruleTieVote => 'Tied vote';

  @override
  String get tieRevote => 'Revote';

  @override
  String get tieNoElimination => 'Nobody out';

  @override
  String get tieHostDecides => 'Host decides';

  @override
  String get setupDealRoles => 'Deal roles';

  @override
  String setupProblemTooFewPlayers(int min) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minString = minNumberFormat.format(min);

    return 'Add at least $minString players.';
  }

  @override
  String get setupProblemDuplicateName => 'Two players have the same name.';

  @override
  String get setupProblemTooManyRoles => 'There are more roles than players.';

  @override
  String get setupProblemNoMafia => 'Add at least one Mafia role.';

  @override
  String get setupProblemMafiaTooStrong => 'The Mafia must be fewer than the civilian team.';

  @override
  String get dealTitle => 'Hand out the cards';

  @override
  String get dealInstructions =>
      'Give each player the card shown next to their name. Keep this screen hidden from the table.';

  @override
  String get dealChameleonPlaysAs => 'Chameleon plays as';

  @override
  String get dealChameleonMissing => 'Each Chameleon must choose a role.';

  @override
  String get dealReshuffle => 'Reshuffle';

  @override
  String get dealStartGame => 'Start night 1';

  @override
  String get logTitle => 'Game log';

  @override
  String get menuUndo => 'Undo last step';

  @override
  String get menuEndGame => 'End game';

  @override
  String get undoDone => 'Last step undone.';

  @override
  String get endGameConfirmTitle => 'End this game?';

  @override
  String get endGameConfirmBody => 'The game will be closed and can\'t be continued.';

  @override
  String get nightIntro => 'Everyone, close your eyes.';

  @override
  String get nightBegin => 'Begin the night';

  @override
  String nightStepCounter(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Step $currentString of $totalString';
  }

  @override
  String nightMafiaDecider(String name) {
    return '$name has the final say';
  }

  @override
  String nightActor(String name) {
    return 'Card holder: $name';
  }

  @override
  String get nightWakePotana => 'Wake the Potana. Who do they block?';

  @override
  String get nightWakeLawyer => 'Wake the Lawyer. Who do they protect?';

  @override
  String get nightWakeMafia => 'Wake the Mafia. Who do they kill?';

  @override
  String get nightWakeJoker => 'Wake the Joker. Who do they kill?';

  @override
  String get nightWakeDoctor => 'Wake the Doctor. Who do they save?';

  @override
  String get nightWakeDetective => 'Wake the Detective. Who do they check?';

  @override
  String get nightNoAction => 'No action';

  @override
  String get nightBlockedWarning =>
      'Blocked by the Potana tonight — this action will have no effect. Let them choose anyway.';

  @override
  String get nightDoctorLastNight => 'Saved last night';

  @override
  String get nightDetectiveShow => 'Show the Detective:';

  @override
  String get nightDetectiveBlocked => 'The Detective is blocked tonight — give no answer.';

  @override
  String get nightReviewTitle => 'Everyone is asleep. Review the night.';

  @override
  String reviewNoAction(String actor) {
    return '$actor: no action';
  }

  @override
  String get nightResolve => 'Resolve the night';

  @override
  String get resultMafia => 'Mafia';

  @override
  String get resultCivilian => 'Civilian';

  @override
  String actorWithRole(String name, String role) {
    return '$name ($role)';
  }

  @override
  String actionPotanaBlock(String actor, String target) {
    return '$actor blocked $target';
  }

  @override
  String actionLawyerProtect(String actor, String target) {
    return '$actor protected $target';
  }

  @override
  String actionMafiaKill(String actor, String target) {
    return '$actor chose to kill $target';
  }

  @override
  String actionJokerKill(String actor, String target) {
    return '$actor chose to kill $target';
  }

  @override
  String actionDoctorSave(String actor, String target) {
    return '$actor saved $target';
  }

  @override
  String actionDetectiveCheck(String actor, String target) {
    return '$actor checked $target';
  }

  @override
  String get announceNobodyDied => 'Nobody died last night.';

  @override
  String announceKilled(String name) {
    return '$name was killed.';
  }

  @override
  String announceVotedOut(String name) {
    return '$name was voted out.';
  }

  @override
  String announceBombVictim(String name) {
    return '$name was killed by the Bomb.';
  }

  @override
  String announceCard(String role) {
    return 'Card: $role.';
  }

  @override
  String announceBomb(String name) {
    return '$name was the Bomb!';
  }

  @override
  String get announceNoElimination => 'Nobody was voted out.';

  @override
  String announceTie(String names) {
    return 'The vote is tied between $names.';
  }

  @override
  String get winMafia => 'Mafia win!';

  @override
  String get winCivilians => 'Civilians win!';

  @override
  String hostBlocked(String name) {
    return '$name was blocked.';
  }

  @override
  String hostProtected(String name) {
    return '$name was protected by the Lawyer.';
  }

  @override
  String hostSaved(String name) {
    return 'The Doctor saved $name.';
  }

  @override
  String hostDetective(String target, String result) {
    return 'Detective\'s check on $target: $result';
  }

  @override
  String hostBombDefused(String name) {
    return '$name (Bomb) was blocked and did not explode.';
  }

  @override
  String bombPick(String name, int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString players',
      one: '1 player',
    );
    return '$name was the Bomb. Choose $_temp0 to die with them.';
  }

  @override
  String bombDetonate(String selected, String required) {
    return 'Detonate ($selected/$required)';
  }

  @override
  String get morningStartDay => 'Start the day';

  @override
  String get dayDiscussion => 'Discussion';

  @override
  String get timerStart => 'Start';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerReset => 'Reset';

  @override
  String get timerDone => 'Time\'s up!';

  @override
  String get dayVoteTitle => 'Vote';

  @override
  String get dayVoteHint => 'Open a player and tap everyone who voted for them.';

  @override
  String voteCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString votes',
      one: '1 vote',
      zero: 'No votes',
    );
    return '$_temp0';
  }

  @override
  String get daySkipVote => 'No vote today';

  @override
  String get dayCountVotes => 'Count votes';

  @override
  String dayTieHostDecides(String names) {
    return 'Tie between $names. Who is out?';
  }

  @override
  String dayTieRevote(String names) {
    return 'Tie between $names. Vote again.';
  }

  @override
  String dayStartNight(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'Start night $roundString';
  }

  @override
  String get gameOverAllRoles => 'All roles';

  @override
  String get statusAlive => 'Alive';

  @override
  String get statusDead => 'Dead';

  @override
  String get gameOverPlayAgain => 'New game';

  @override
  String get logEmpty => 'Nothing has happened yet.';

  @override
  String get logNoActions => 'No night actions';

  @override
  String logVote(String voter, String target) {
    return '$voter voted for $target';
  }

  @override
  String logAbstain(String voter) {
    return '$voter did not vote';
  }

  @override
  String get logNoVote => 'No vote';

  @override
  String logTieBreak(String name) {
    return 'Host chose $name';
  }

  @override
  String logBomb(String bomb, String victims) {
    return '$bomb (Bomb) took $victims';
  }
}
