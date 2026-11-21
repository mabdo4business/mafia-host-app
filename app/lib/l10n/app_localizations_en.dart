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

  @override
  String quoted(String text) {
    return '“$text”';
  }

  @override
  String teamCount(String team, String count) {
    return '$team $count';
  }

  @override
  String get teamLabelMafia => 'Mafia team';

  @override
  String get teamLabelCivilians => 'Civilian team';

  @override
  String get revealTapToReveal => 'Tap to reveal';

  @override
  String get revealNoOneLooking => 'Make sure no one is looking';

  @override
  String get revealYourFamily => 'Your family';

  @override
  String get revealRole => 'Reveal role';

  @override
  String get hideRole => 'Hide role';

  @override
  String familyMember(String name, String role) {
    return '$name · $role';
  }

  @override
  String get abilityCivilian =>
      'You have no power at night. Find the Mafia and vote them out by day.';

  @override
  String get abilityDoctor =>
      'Save one player each night, yourself included — but never the same player two nights in a row.';

  @override
  String get abilityDetective =>
      'Check one player each night. The host tells you: Mafia or Civilian.';

  @override
  String get abilityBomb => 'When you die, by night or by vote, you take players down with you.';

  @override
  String get abilityJoker =>
      'You kill one player every night. You play for the Civilians, but nobody is safe.';

  @override
  String get abilityChameleon => 'Pick a role now and play it for the whole game.';

  @override
  String get abilityMafia => 'Each night, wake with your family and choose who dies.';

  @override
  String get abilityGodfather =>
      'You make the final call on who the Mafia kills. The Detective sees you as a Civilian.';

  @override
  String get abilityPotana =>
      'Each night, block one civilian\'s power. Their action has no effect.';

  @override
  String get abilityLawyer =>
      'Each night, protect a Mafia member: the Detective sees them as a Civilian.';

  @override
  String get timeLeft => 'left';

  @override
  String get statusEliminated => 'Eliminated';

  @override
  String get nightWakeTitlePotana => 'Wake the Potana';

  @override
  String get nightWakeTitleLawyer => 'Wake the Lawyer';

  @override
  String get nightWakeTitleMafia => 'Wake the Mafia';

  @override
  String get nightWakeTitleJoker => 'Wake the Joker';

  @override
  String get nightWakeTitleDoctor => 'Wake the Doctor';

  @override
  String get nightWakeTitleDetective => 'Wake the Detective';

  @override
  String get nightLinePotana => 'Potana, open your eyes. Whose power do you block tonight?';

  @override
  String get nightLineLawyer => 'Lawyer, open your eyes. Who do you protect tonight?';

  @override
  String get nightLineMafia => 'Mafia, open your eyes. Who dies tonight?';

  @override
  String get nightLineJoker => 'Joker, open your eyes. Who do you kill tonight?';

  @override
  String get nightLineDoctor => 'Doctor, open your eyes. Who do you save tonight?';

  @override
  String get nightLineDetective => 'Detective, open your eyes. Who do you check tonight?';

  @override
  String hostOnlyDetective(String name, String result) {
    return 'Host only: Detective checked $name → $result';
  }

  @override
  String actionBlock(String name) {
    return 'Block $name';
  }

  @override
  String actionProtect(String name) {
    return 'Protect $name';
  }

  @override
  String actionKill(String name) {
    return 'Kill $name';
  }

  @override
  String actionSave(String name) {
    return 'Save $name';
  }

  @override
  String actionCheck(String name) {
    return 'Check $name';
  }

  @override
  String get nightPickToBlock => 'Pick a player to block';

  @override
  String get nightPickToProtect => 'Pick a player to protect';

  @override
  String get nightPickToKill => 'Pick a player to kill';

  @override
  String get nightPickToSave => 'Pick a player to save';

  @override
  String get nightPickToCheck => 'Pick a player to check';

  @override
  String get nightBlockedShort => 'Blocked tonight: this action has no effect.';

  @override
  String get setupShuffleDeal => 'Shuffle & deal roles';

  @override
  String get revealPassNext => 'Hide & pass to next player';

  @override
  String get bombDetonateShort => 'Detonate';

  @override
  String get notifications => 'Notifications';

  @override
  String setupBalancedFor(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Balanced for $countString';
  }

  @override
  String get setupProblemMafiaTooStrongShort => 'Mafia too strong';

  @override
  String get announceRoleSecret => 'Role stays secret until the game ends';

  @override
  String announceBombTakes(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They take $countString players down with them:',
      one: 'They take 1 player down with them:',
    );
    return '$_temp0';
  }

  @override
  String get announceSomeoneSaved => 'Someone was saved by the Doctor.';

  @override
  String get announceDontSayWho => 'Don\'t say who';

  @override
  String get statGames => 'Games';

  @override
  String get statMafiaWins => 'Mafia wins';

  @override
  String get statCivilianWins => 'Civilian wins';

  @override
  String percent(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString%';
  }

  @override
  String get modeHostOnly => 'Host only · Cards';

  @override
  String get modePlayersPhones => 'Players\' phones';

  @override
  String logVotesFor(String name, int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString votes',
      one: '1 vote',
    );
    return '$name: $_temp0';
  }

  @override
  String announceWasBomb(String headline) {
    return '$headline They were the Bomb.';
  }

  @override
  String announceBombChoosing(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They take $countString players down with them: choose now.',
      one: 'They take 1 player down with them: choose now.',
    );
    return '$_temp0';
  }

  @override
  String bombChoose(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choose $countString players',
      one: 'Choose 1 player',
      zero: 'Ready',
    );
    return '$_temp0';
  }

  @override
  String bombCounter(String selected, String required) {
    return '$selected / $required';
  }

  @override
  String bombWasTheBomb(String name) {
    return '$name was the Bomb';
  }

  @override
  String chameleonBecome(String role) {
    return 'Become $role';
  }

  @override
  String get chameleonChooseRole => 'Choose your role';

  @override
  String chameleonIntro(String name) {
    return '$name, you are the Chameleon. Pick the role you will play all game.';
  }

  @override
  String get chameleonPickHint => 'Pick a role';

  @override
  String get comingSoon => 'Coming in a later update.';

  @override
  String countAlive(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString alive';
  }

  @override
  String countEliminated(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString eliminated';
  }

  @override
  String get dayDiscussionHint => 'The town talks it over. Start voting when they are ready.';

  @override
  String dayEliminate(String name) {
    return 'Eliminate $name';
  }

  @override
  String dayOfVoters(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return ' of $countString voted';
  }

  @override
  String get dayResultTitle => 'The town has spoken.';

  @override
  String get dayStartVoting => 'Start voting';

  @override
  String get dayTapToVote => 'Tap a player to add a vote';

  @override
  String get dayTimerHint => 'Discussion timer';

  @override
  String get dayTitle => 'Who is lying?';

  @override
  String get dayUndoVote => 'Undo last vote';

  @override
  String get dayVoting => 'Voting';

  @override
  String get detectiveBlockedTitle => 'The Detective is blocked';

  @override
  String detectiveChecked(String name) {
    return 'The Detective checked $name';
  }

  @override
  String get detectiveDone => 'Continue the night';

  @override
  String get detectiveNoAnswer => 'No answer';

  @override
  String get detectiveSignalHint => 'Signal this to the Detective without a word.';

  @override
  String get gameOverBackHome => 'Back to home';

  @override
  String gameOverSummary(int nights, int alive) {
    final intl.NumberFormat nightsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String nightsString = nightsNumberFormat.format(nights);
    final intl.NumberFormat aliveNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String aliveString = aliveNumberFormat.format(alive);

    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: 'After $nightsString nights',
      one: 'After 1 night',
    );
    return '$_temp0 · $aliveString still standing';
  }

  @override
  String homeContinueAt(String stage) {
    return 'Continue · $stage';
  }

  @override
  String get homeGreetingAfternoon => 'Good afternoon, Host';

  @override
  String get homeGreetingEvening => 'Good evening, Host';

  @override
  String get homeGreetingMorning => 'Good morning, Host';

  @override
  String homeHeroAlive(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString still alive';
  }

  @override
  String get homeHeroEmpty => 'Add the players and deal the cards.';

  @override
  String get homeHeroInProgress => 'In progress';

  @override
  String homeHeroLastTable(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString players from your last game',
      one: '1 player from your last game',
    );
    return '$_temp0';
  }

  @override
  String homeHeroReady(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString at the table';
  }

  @override
  String get homeHeroTag => 'Tonight';

  @override
  String get homeHeroTitle => 'Tonight\'s table';

  @override
  String get homeRecentEmpty => 'Finished games will show up here.';

  @override
  String get homeStartGame => 'Start a game';

  @override
  String get homeTitle => 'The city sleeps.';

  @override
  String get homeYourTable => 'Your table';

  @override
  String get menuHome => 'Home';

  @override
  String get menuMore => 'More';

  @override
  String get morningReadInOrder => 'Read these out in order';

  @override
  String get morningTitle => 'The town wakes up.';

  @override
  String get navEvents => 'Events';

  @override
  String get navHome => 'Home';

  @override
  String get navPlayers => 'Players';

  @override
  String get nightContinueNoAction => 'Next · no action';

  @override
  String get nightIntroHint => 'Read it out, then begin when the table is quiet.';

  @override
  String get nightPreviousStep => 'Previous step';

  @override
  String get nightReviewHint => 'Tap a step to change it.';

  @override
  String get recentCiviliansWon => 'Civilians won';

  @override
  String recentDetail(int nights, int players) {
    final intl.NumberFormat nightsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String nightsString = nightsNumberFormat.format(nights);
    final intl.NumberFormat playersNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String playersString = playersNumberFormat.format(players);

    return 'Night $nightsString · $playersString players';
  }

  @override
  String get recentMafiaWon => 'Mafia won';

  @override
  String get revealDealing => 'Dealing roles';

  @override
  String get revealHandTo => 'Hand the phone to';

  @override
  String get revealHint => 'Hold the card close, then tap it';

  @override
  String revealProgress(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$currentString of $totalString';
  }

  @override
  String get setupAddPlayersHint => 'Add the players around the table';

  @override
  String get setupAutoBalance => 'Auto-balance';

  @override
  String get setupBombTakesDown => 'Bomb takes down';

  @override
  String get setupBombTakesDownHint => 'Players chosen when the Bomb dies';

  @override
  String get setupHouseRulesHint => 'Doctor, Bomb, Chameleon and tie rules';

  @override
  String get setupPlayersAtTable => 'Players at the table';

  @override
  String get setupRolesHint => 'Tap a role to add one, hold to remove one.';

  @override
  String get statNone => '–';

  @override
  String get timerPaused => 'paused';

  @override
  String get eventsTitle => 'Game nights';

  @override
  String get eventsPast => 'Past nights';

  @override
  String get eventsEmpty => 'Your game nights will show up here once a game is finished.';

  @override
  String get eventsPlanningSoon => 'Planning nights ahead and RSVPs arrive with player accounts.';

  @override
  String eventsNightDetail(int games, int players) {
    final intl.NumberFormat gamesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String gamesString = gamesNumberFormat.format(games);
    final intl.NumberFormat playersNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String playersString = playersNumberFormat.format(players);

    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$gamesString games',
      one: '1 game',
    );
    return '$_temp0 · $playersString players';
  }

  @override
  String get eventsGameNight => 'Game night';

  @override
  String eventsTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String eventsAttendees(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString at the table',
      one: '1 at the table',
    );
    return '$_temp0';
  }

  @override
  String get eventsGamesPlayed => 'Games played';

  @override
  String get homeSeeStats => 'See stats';

  @override
  String get joinTitle => 'Join a room';

  @override
  String get joinIntro => 'Enter the code on the host\'s phone to play from your own phone.';

  @override
  String get joinCodeHint => '4 to 6 letters or numbers';

  @override
  String get joinScanQr => 'Scan QR code';

  @override
  String get joinCta => 'Join';

  @override
  String get joinNotYet => 'Playing from players\' phones is coming in a later update.';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'Ranked by wins across every finished game';

  @override
  String get leaderboardEmpty => 'Finish a game to start the leaderboard.';

  @override
  String leaderboardRowDetail(int games, int rate) {
    final intl.NumberFormat gamesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String gamesString = gamesNumberFormat.format(games);
    final intl.NumberFormat rateNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String rateString = rateNumberFormat.format(rate);

    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$gamesString games',
      one: '1 game',
    );
    return '$_temp0 · $rateString% wins';
  }

  @override
  String leaderboardWins(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString wins',
      one: '1 win',
    );
    return '$_temp0';
  }

  @override
  String get logFilterAll => 'All';

  @override
  String get logFilterKills => 'Kills';

  @override
  String get logFilterSaves => 'Saves';

  @override
  String get logFilterVotes => 'Votes';

  @override
  String get logNothingHere => 'Nothing of this kind yet.';

  @override
  String nightGodfatherConfirms(String name) {
    return 'Godfather confirms: kill $name';
  }

  @override
  String get nightMafiaProposalHint =>
      'Hold a player to mark a Mafia proposal; tap to choose the kill.';

  @override
  String get profileFavoriteRole => 'Favorite role';

  @override
  String profileLastPlayed(String date) {
    return 'Last played $date';
  }

  @override
  String get profileNoGames => 'No finished games yet.';

  @override
  String get profileRoleHistory => 'Role history';

  @override
  String get profileWinRate => 'Win rate';

  @override
  String get settingsDefaultsHint =>
      'Every new game starts with these; change them per game in setup.';

  @override
  String get settingsDefaultsSection => 'Game defaults';

  @override
  String get settingsFeedbackSection => 'Sound & touch';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsHapticsSubtitle => 'A light tap on picks, card flips and when time runs out';

  @override
  String get setupDiscussionTimerMinutes => 'Discussion timer (minutes)';

  @override
  String get settingsDeviceShort => 'Device';

  @override
  String get setupRolesHow => 'How players get their roles';

  @override
  String get setupModePhone => 'Pass the phone';

  @override
  String get setupModeCards => 'Physical cards';

  @override
  String get setupModePhoneHint => 'Each player taps the phone to see their role.';

  @override
  String get setupModeCardsHint => 'Hand out the cards, then tap who holds each one on night 1.';

  @override
  String get setupCardsDealt => 'I\'ve handed out the cards';

  @override
  String get cardsOverline => 'Night 1 · Who has which card';

  @override
  String cardsWake(String role) {
    return '$role wakes up';
  }

  @override
  String get cardsLine => 'If you hold this card, open your eyes.';

  @override
  String cardsPicked(int picked, int total) {
    final intl.NumberFormat pickedNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String pickedString = pickedNumberFormat.format(picked);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Tap who holds it · $pickedString of $totalString';
  }

  @override
  String cardsNextRole(String role) {
    return 'Next: $role';
  }

  @override
  String get cardsChameleonNext => 'Choose the Chameleon\'s role';

  @override
  String get cardsReviewStep => 'Check';

  @override
  String get cardsReviewTitle => 'Check the cards';

  @override
  String get cardsReviewHint => 'Tap a card to fix it. Everyone else holds a Civilian card.';

  @override
  String get cardsReviewCheck => 'Check the cards';
}
