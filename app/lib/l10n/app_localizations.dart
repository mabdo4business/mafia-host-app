import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mafia Host'**
  String get appTitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Run Mafia nights with physical cards — one phone, fully offline.'**
  String get homeTagline;

  /// No description provided for @homeNewGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get homeNewGame;

  /// No description provided for @homeContinueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeContinueGame;

  /// No description provided for @newGameConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new game?'**
  String get newGameConfirmTitle;

  /// No description provided for @newGameConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The game in progress will be closed.'**
  String get newGameConfirmBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'Device setting'**
  String get settingsSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsSoundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSoundSection;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSound;

  /// No description provided for @settingsSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A chime when night falls and when morning comes'**
  String get settingsSoundSubtitle;

  /// No description provided for @roleCivilian.
  ///
  /// In en, this message translates to:
  /// **'Civilian'**
  String get roleCivilian;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// No description provided for @roleDetective.
  ///
  /// In en, this message translates to:
  /// **'Detective'**
  String get roleDetective;

  /// No description provided for @roleBomb.
  ///
  /// In en, this message translates to:
  /// **'Bomb'**
  String get roleBomb;

  /// No description provided for @roleJoker.
  ///
  /// In en, this message translates to:
  /// **'Joker'**
  String get roleJoker;

  /// No description provided for @roleChameleon.
  ///
  /// In en, this message translates to:
  /// **'Chameleon'**
  String get roleChameleon;

  /// No description provided for @roleMafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia'**
  String get roleMafia;

  /// No description provided for @roleGodfather.
  ///
  /// In en, this message translates to:
  /// **'Godfather'**
  String get roleGodfather;

  /// No description provided for @roleLawyer.
  ///
  /// In en, this message translates to:
  /// **'Lawyer'**
  String get roleLawyer;

  /// No description provided for @teamCivilians.
  ///
  /// In en, this message translates to:
  /// **'Civilians'**
  String get teamCivilians;

  /// No description provided for @teamMafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia'**
  String get teamMafia;

  /// No description provided for @chameleonAs.
  ///
  /// In en, this message translates to:
  /// **'Chameleon as {role}'**
  String chameleonAs(String role);

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @stageNight.
  ///
  /// In en, this message translates to:
  /// **'Night {round}'**
  String stageNight(int round);

  /// No description provided for @stageMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning {round}'**
  String stageMorning(int round);

  /// No description provided for @stageDay.
  ///
  /// In en, this message translates to:
  /// **'Day {round}'**
  String stageDay(int round);

  /// No description provided for @stageGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get stageGameOver;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @hostOnly.
  ///
  /// In en, this message translates to:
  /// **'Host only'**
  String get hostOnly;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get setupTitle;

  /// No description provided for @setupPlayersSection.
  ///
  /// In en, this message translates to:
  /// **'Players (seating order)'**
  String get setupPlayersSection;

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No players yet} =1{1 player} other{{count} players}}'**
  String playerCount(int count);

  /// No description provided for @setupPlayerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get setupPlayerNameHint;

  /// No description provided for @setupAddPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get setupAddPlayer;

  /// No description provided for @setupRemovePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get setupRemovePlayer;

  /// No description provided for @setupRolesSection.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get setupRolesSection;

  /// No description provided for @setupSuggestedMix.
  ///
  /// In en, this message translates to:
  /// **'Suggested mix'**
  String get setupSuggestedMix;

  /// No description provided for @setupOptionsSection.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get setupOptionsSection;

  /// No description provided for @setupRevealRole.
  ///
  /// In en, this message translates to:
  /// **'Reveal role on death'**
  String get setupRevealRole;

  /// No description provided for @timerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get timerOff;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min} other{{count} min}}'**
  String minutes(int count);

  /// No description provided for @setupHouseRules.
  ///
  /// In en, this message translates to:
  /// **'House rules'**
  String get setupHouseRules;

  /// No description provided for @tieNoElimination.
  ///
  /// In en, this message translates to:
  /// **'Nobody out'**
  String get tieNoElimination;

  /// No description provided for @tieHostDecides.
  ///
  /// In en, this message translates to:
  /// **'Host decides'**
  String get tieHostDecides;

  /// No description provided for @setupDealRoles.
  ///
  /// In en, this message translates to:
  /// **'Deal roles'**
  String get setupDealRoles;

  /// No description provided for @setupProblemTooFewPlayers.
  ///
  /// In en, this message translates to:
  /// **'Add at least {min, plural, =1{1 player} other{{min} players}}.'**
  String setupProblemTooFewPlayers(int min);

  /// No description provided for @setupProblemDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'Two players have the same name.'**
  String get setupProblemDuplicateName;

  /// No description provided for @setupProblemTooManyRoles.
  ///
  /// In en, this message translates to:
  /// **'There are more roles than players.'**
  String get setupProblemTooManyRoles;

  /// No description provided for @setupProblemNoMafia.
  ///
  /// In en, this message translates to:
  /// **'Add at least one Mafia role.'**
  String get setupProblemNoMafia;

  /// No description provided for @setupProblemMafiaTooStrong.
  ///
  /// In en, this message translates to:
  /// **'The Mafia must be fewer than the civilian team.'**
  String get setupProblemMafiaTooStrong;

  /// No description provided for @dealTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand out the cards'**
  String get dealTitle;

  /// No description provided for @dealInstructions.
  ///
  /// In en, this message translates to:
  /// **'Give each player the card shown next to their name. Keep this screen hidden from the table.'**
  String get dealInstructions;

  /// No description provided for @dealReshuffle.
  ///
  /// In en, this message translates to:
  /// **'Reshuffle'**
  String get dealReshuffle;

  /// No description provided for @dealStartGame.
  ///
  /// In en, this message translates to:
  /// **'Start night 1'**
  String get dealStartGame;

  /// No description provided for @logTitle.
  ///
  /// In en, this message translates to:
  /// **'Game log'**
  String get logTitle;

  /// No description provided for @menuUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo last step'**
  String get menuUndo;

  /// No description provided for @menuEndGame.
  ///
  /// In en, this message translates to:
  /// **'End game'**
  String get menuEndGame;

  /// No description provided for @undoDone.
  ///
  /// In en, this message translates to:
  /// **'Last step undone.'**
  String get undoDone;

  /// No description provided for @endGameConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End this game?'**
  String get endGameConfirmTitle;

  /// No description provided for @endGameConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The game will be closed and can\'t be continued.'**
  String get endGameConfirmBody;

  /// No description provided for @nightIntro.
  ///
  /// In en, this message translates to:
  /// **'Everyone, close your eyes.'**
  String get nightIntro;

  /// No description provided for @nightBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin the night'**
  String get nightBegin;

  /// No description provided for @nightStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String nightStepCounter(int current, int total);

  /// No description provided for @nightMafiaDecider.
  ///
  /// In en, this message translates to:
  /// **'{name} has the final say'**
  String nightMafiaDecider(String name);

  /// No description provided for @nightActor.
  ///
  /// In en, this message translates to:
  /// **'Card holder: {name}'**
  String nightActor(String name);

  /// No description provided for @nightWakeLawyer.
  ///
  /// In en, this message translates to:
  /// **'Wake the Lawyer. Who do they protect?'**
  String get nightWakeLawyer;

  /// No description provided for @nightWakeMafia.
  ///
  /// In en, this message translates to:
  /// **'Wake the Mafia. Who do they kill?'**
  String get nightWakeMafia;

  /// No description provided for @nightWakeJoker.
  ///
  /// In en, this message translates to:
  /// **'Wake the Joker. Who do they kill?'**
  String get nightWakeJoker;

  /// No description provided for @nightWakeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Wake the Doctor. Who do they save?'**
  String get nightWakeDoctor;

  /// No description provided for @nightWakeDetective.
  ///
  /// In en, this message translates to:
  /// **'Wake the Detective. Who do they check?'**
  String get nightWakeDetective;

  /// No description provided for @nightNoAction.
  ///
  /// In en, this message translates to:
  /// **'No action'**
  String get nightNoAction;

  /// No description provided for @nightDetectiveShow.
  ///
  /// In en, this message translates to:
  /// **'Show the Detective:'**
  String get nightDetectiveShow;

  /// No description provided for @nightDetectiveBlocked.
  ///
  /// In en, this message translates to:
  /// **'The Detective is blocked tonight — give no answer.'**
  String get nightDetectiveBlocked;

  /// No description provided for @nightReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone is asleep. Review the night.'**
  String get nightReviewTitle;

  /// No description provided for @reviewNoAction.
  ///
  /// In en, this message translates to:
  /// **'{actor}: no action'**
  String reviewNoAction(String actor);

  /// No description provided for @nightResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve the night'**
  String get nightResolve;

  /// No description provided for @resultMafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia'**
  String get resultMafia;

  /// No description provided for @resultCivilian.
  ///
  /// In en, this message translates to:
  /// **'Civilian'**
  String get resultCivilian;

  /// No description provided for @actorWithRole.
  ///
  /// In en, this message translates to:
  /// **'{name} ({role})'**
  String actorWithRole(String name, String role);

  /// No description provided for @actionLawyerProtect.
  ///
  /// In en, this message translates to:
  /// **'{actor} protected {target}'**
  String actionLawyerProtect(String actor, String target);

  /// No description provided for @actionMafiaKill.
  ///
  /// In en, this message translates to:
  /// **'{actor} chose to kill {target}'**
  String actionMafiaKill(String actor, String target);

  /// No description provided for @actionJokerKill.
  ///
  /// In en, this message translates to:
  /// **'{actor} chose to kill {target}'**
  String actionJokerKill(String actor, String target);

  /// No description provided for @actionDoctorSave.
  ///
  /// In en, this message translates to:
  /// **'{actor} saved {target}'**
  String actionDoctorSave(String actor, String target);

  /// No description provided for @actionDetectiveCheck.
  ///
  /// In en, this message translates to:
  /// **'{actor} checked {target}'**
  String actionDetectiveCheck(String actor, String target);

  /// No description provided for @announceNobodyDied.
  ///
  /// In en, this message translates to:
  /// **'Nobody died last night.'**
  String get announceNobodyDied;

  /// No description provided for @announceKilled.
  ///
  /// In en, this message translates to:
  /// **'{name} was killed.'**
  String announceKilled(String name);

  /// No description provided for @announceVotedOut.
  ///
  /// In en, this message translates to:
  /// **'{name} was voted out.'**
  String announceVotedOut(String name);

  /// No description provided for @announceBombVictim.
  ///
  /// In en, this message translates to:
  /// **'{name} was killed by the Bomb.'**
  String announceBombVictim(String name);

  /// No description provided for @announceCard.
  ///
  /// In en, this message translates to:
  /// **'Card: {role}.'**
  String announceCard(String role);

  /// No description provided for @announceBomb.
  ///
  /// In en, this message translates to:
  /// **'{name} was the Bomb!'**
  String announceBomb(String name);

  /// No description provided for @announceNoElimination.
  ///
  /// In en, this message translates to:
  /// **'Nobody was voted out.'**
  String get announceNoElimination;

  /// No description provided for @announceTie.
  ///
  /// In en, this message translates to:
  /// **'The vote is tied between {names}.'**
  String announceTie(String names);

  /// No description provided for @winMafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia win!'**
  String get winMafia;

  /// No description provided for @winCivilians.
  ///
  /// In en, this message translates to:
  /// **'Civilians win!'**
  String get winCivilians;

  /// No description provided for @hostBlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} was blocked.'**
  String hostBlocked(String name);

  /// No description provided for @hostProtected.
  ///
  /// In en, this message translates to:
  /// **'{name} was protected by the Lawyer.'**
  String hostProtected(String name);

  /// No description provided for @hostSaved.
  ///
  /// In en, this message translates to:
  /// **'The Doctor saved {name}.'**
  String hostSaved(String name);

  /// No description provided for @hostDetective.
  ///
  /// In en, this message translates to:
  /// **'Detective\'s check on {target}: {result}'**
  String hostDetective(String target, String result);

  /// No description provided for @morningStartDay.
  ///
  /// In en, this message translates to:
  /// **'Start the day'**
  String get morningStartDay;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timerReset;

  /// No description provided for @timerDone.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get timerDone;

  /// No description provided for @dayVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get dayVoteTitle;

  /// No description provided for @dayVoteHint.
  ///
  /// In en, this message translates to:
  /// **'Open a player and tap everyone who voted for them.'**
  String get dayVoteHint;

  /// No description provided for @voteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No votes} =1{1 vote} other{{count} votes}}'**
  String voteCount(int count);

  /// No description provided for @daySkipVote.
  ///
  /// In en, this message translates to:
  /// **'No vote today'**
  String get daySkipVote;

  /// No description provided for @dayCountVotes.
  ///
  /// In en, this message translates to:
  /// **'Count votes'**
  String get dayCountVotes;

  /// No description provided for @dayStartNight.
  ///
  /// In en, this message translates to:
  /// **'Start night {round}'**
  String dayStartNight(int round);

  /// No description provided for @gameOverAllRoles.
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get gameOverAllRoles;

  /// No description provided for @statusAlive.
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get statusAlive;

  /// No description provided for @statusDead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get statusDead;

  /// No description provided for @gameOverPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get gameOverPlayAgain;

  /// No description provided for @logEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing has happened yet.'**
  String get logEmpty;

  /// No description provided for @logNoActions.
  ///
  /// In en, this message translates to:
  /// **'No night actions'**
  String get logNoActions;

  /// No description provided for @logVote.
  ///
  /// In en, this message translates to:
  /// **'{voter} voted for {target}'**
  String logVote(String voter, String target);

  /// No description provided for @logAbstain.
  ///
  /// In en, this message translates to:
  /// **'{voter} did not vote'**
  String logAbstain(String voter);

  /// No description provided for @logNoVote.
  ///
  /// In en, this message translates to:
  /// **'No vote'**
  String get logNoVote;

  /// No description provided for @logTieBreak.
  ///
  /// In en, this message translates to:
  /// **'Host chose {name}'**
  String logTieBreak(String name);

  /// No description provided for @logBomb.
  ///
  /// In en, this message translates to:
  /// **'{bomb} (Bomb) took {victims}'**
  String logBomb(String bomb, String victims);

  /// No description provided for @quoted.
  ///
  /// In en, this message translates to:
  /// **'“{text}”'**
  String quoted(String text);

  /// No description provided for @teamCount.
  ///
  /// In en, this message translates to:
  /// **'{team} {count}'**
  String teamCount(String team, String count);

  /// No description provided for @teamLabelMafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia team'**
  String get teamLabelMafia;

  /// No description provided for @teamLabelCivilians.
  ///
  /// In en, this message translates to:
  /// **'Civilian team'**
  String get teamLabelCivilians;

  /// No description provided for @revealTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get revealTapToReveal;

  /// No description provided for @revealNoOneLooking.
  ///
  /// In en, this message translates to:
  /// **'Make sure no one is looking'**
  String get revealNoOneLooking;

  /// No description provided for @revealYourFamily.
  ///
  /// In en, this message translates to:
  /// **'Your family'**
  String get revealYourFamily;

  /// No description provided for @revealRole.
  ///
  /// In en, this message translates to:
  /// **'Reveal role'**
  String get revealRole;

  /// No description provided for @hideRole.
  ///
  /// In en, this message translates to:
  /// **'Hide role'**
  String get hideRole;

  /// No description provided for @familyMember.
  ///
  /// In en, this message translates to:
  /// **'{name} · {role}'**
  String familyMember(String name, String role);

  /// No description provided for @abilityCivilian.
  ///
  /// In en, this message translates to:
  /// **'You have no power at night. Find the Mafia and vote them out by day.'**
  String get abilityCivilian;

  /// No description provided for @abilityJoker.
  ///
  /// In en, this message translates to:
  /// **'You kill one player every night. You play for the Civilians, but nobody is safe.'**
  String get abilityJoker;

  /// No description provided for @abilityLawyer.
  ///
  /// In en, this message translates to:
  /// **'Each night, protect a Mafia member: the Detective sees them as a Civilian.'**
  String get abilityLawyer;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get timeLeft;

  /// No description provided for @statusEliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get statusEliminated;

  /// No description provided for @nightWakeTitleLawyer.
  ///
  /// In en, this message translates to:
  /// **'Wake the Lawyer'**
  String get nightWakeTitleLawyer;

  /// No description provided for @nightWakeTitleMafia.
  ///
  /// In en, this message translates to:
  /// **'Wake the Mafia'**
  String get nightWakeTitleMafia;

  /// No description provided for @nightWakeTitleJoker.
  ///
  /// In en, this message translates to:
  /// **'Wake the Joker'**
  String get nightWakeTitleJoker;

  /// No description provided for @nightWakeTitleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Wake the Doctor'**
  String get nightWakeTitleDoctor;

  /// No description provided for @nightWakeTitleDetective.
  ///
  /// In en, this message translates to:
  /// **'Wake the Detective'**
  String get nightWakeTitleDetective;

  /// No description provided for @nightLineLawyer.
  ///
  /// In en, this message translates to:
  /// **'Lawyer, open your eyes. Who do you protect tonight?'**
  String get nightLineLawyer;

  /// No description provided for @nightLineMafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia, open your eyes. Who dies tonight?'**
  String get nightLineMafia;

  /// No description provided for @nightLineJoker.
  ///
  /// In en, this message translates to:
  /// **'Joker, open your eyes. Who do you kill tonight?'**
  String get nightLineJoker;

  /// No description provided for @nightLineDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor, open your eyes. Who do you save tonight?'**
  String get nightLineDoctor;

  /// No description provided for @nightLineDetective.
  ///
  /// In en, this message translates to:
  /// **'Detective, open your eyes. Who do you check tonight?'**
  String get nightLineDetective;

  /// No description provided for @hostOnlyDetective.
  ///
  /// In en, this message translates to:
  /// **'Host only: Detective checked {name} → {result}'**
  String hostOnlyDetective(String name, String result);

  /// No description provided for @actionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String actionBlock(String name);

  /// No description provided for @actionProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect {name}'**
  String actionProtect(String name);

  /// No description provided for @actionKill.
  ///
  /// In en, this message translates to:
  /// **'Kill {name}'**
  String actionKill(String name);

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save {name}'**
  String actionSave(String name);

  /// No description provided for @actionCheck.
  ///
  /// In en, this message translates to:
  /// **'Check {name}'**
  String actionCheck(String name);

  /// No description provided for @nightPickToBlock.
  ///
  /// In en, this message translates to:
  /// **'Pick a player to block'**
  String get nightPickToBlock;

  /// No description provided for @nightPickToProtect.
  ///
  /// In en, this message translates to:
  /// **'Pick a player to protect'**
  String get nightPickToProtect;

  /// No description provided for @nightPickToKill.
  ///
  /// In en, this message translates to:
  /// **'Pick a player to kill'**
  String get nightPickToKill;

  /// No description provided for @nightPickToSave.
  ///
  /// In en, this message translates to:
  /// **'Pick a player to save'**
  String get nightPickToSave;

  /// No description provided for @nightPickToCheck.
  ///
  /// In en, this message translates to:
  /// **'Pick a player to check'**
  String get nightPickToCheck;

  /// No description provided for @nightBlockedShort.
  ///
  /// In en, this message translates to:
  /// **'Blocked tonight: this action has no effect.'**
  String get nightBlockedShort;

  /// No description provided for @setupShuffleDeal.
  ///
  /// In en, this message translates to:
  /// **'Shuffle & deal roles'**
  String get setupShuffleDeal;

  /// No description provided for @revealPassNext.
  ///
  /// In en, this message translates to:
  /// **'Hide & pass to next player'**
  String get revealPassNext;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @setupBalancedFor.
  ///
  /// In en, this message translates to:
  /// **'Balanced for {count}'**
  String setupBalancedFor(int count);

  /// No description provided for @setupProblemMafiaTooStrongShort.
  ///
  /// In en, this message translates to:
  /// **'Mafia too strong'**
  String get setupProblemMafiaTooStrongShort;

  /// No description provided for @announceRoleSecret.
  ///
  /// In en, this message translates to:
  /// **'Role stays secret until the game ends'**
  String get announceRoleSecret;

  /// No description provided for @announceBombTakes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{They take 1 player down with them:} other{They take {count} players down with them:}}'**
  String announceBombTakes(int count);

  /// No description provided for @announceSomeoneSaved.
  ///
  /// In en, this message translates to:
  /// **'Someone was saved by the Doctor.'**
  String get announceSomeoneSaved;

  /// No description provided for @announceDontSayWho.
  ///
  /// In en, this message translates to:
  /// **'Don\'t say who'**
  String get announceDontSayWho;

  /// No description provided for @statGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get statGames;

  /// No description provided for @statMafiaWins.
  ///
  /// In en, this message translates to:
  /// **'Mafia wins'**
  String get statMafiaWins;

  /// No description provided for @statCivilianWins.
  ///
  /// In en, this message translates to:
  /// **'Civilian wins'**
  String get statCivilianWins;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percent(int value);

  /// No description provided for @modeHostOnly.
  ///
  /// In en, this message translates to:
  /// **'Host only · Cards'**
  String get modeHostOnly;

  /// No description provided for @modePlayersPhones.
  ///
  /// In en, this message translates to:
  /// **'Players\' phones'**
  String get modePlayersPhones;

  /// No description provided for @logVotesFor.
  ///
  /// In en, this message translates to:
  /// **'{name}: {count, plural, =1{1 vote} other{{count} votes}}'**
  String logVotesFor(String name, int count);

  /// No description provided for @announceWasBomb.
  ///
  /// In en, this message translates to:
  /// **'{headline} They were the Bomb.'**
  String announceWasBomb(String headline);

  /// No description provided for @bombWasTheBomb.
  ///
  /// In en, this message translates to:
  /// **'{name} was the Bomb'**
  String bombWasTheBomb(String name);

  /// No description provided for @chameleonBecome.
  ///
  /// In en, this message translates to:
  /// **'Become {role}'**
  String chameleonBecome(String role);

  /// No description provided for @chameleonPickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a role'**
  String get chameleonPickHint;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later update.'**
  String get comingSoon;

  /// No description provided for @countAlive.
  ///
  /// In en, this message translates to:
  /// **'{count} alive'**
  String countAlive(int count);

  /// No description provided for @countEliminated.
  ///
  /// In en, this message translates to:
  /// **'{count} eliminated'**
  String countEliminated(int count);

  /// No description provided for @dayEliminate.
  ///
  /// In en, this message translates to:
  /// **'Eliminate {name}'**
  String dayEliminate(String name);

  /// No description provided for @dayOfVoters.
  ///
  /// In en, this message translates to:
  /// **' of {count} voted'**
  String dayOfVoters(int count);

  /// No description provided for @dayResultTitle.
  ///
  /// In en, this message translates to:
  /// **'The town has spoken.'**
  String get dayResultTitle;

  /// No description provided for @dayStartVoting.
  ///
  /// In en, this message translates to:
  /// **'Start voting'**
  String get dayStartVoting;

  /// No description provided for @dayTapToVote.
  ///
  /// In en, this message translates to:
  /// **'Tap a player to add a vote'**
  String get dayTapToVote;

  /// No description provided for @dayTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is lying?'**
  String get dayTitle;

  /// No description provided for @dayUndoVote.
  ///
  /// In en, this message translates to:
  /// **'Undo last vote'**
  String get dayUndoVote;

  /// No description provided for @dayVoting.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get dayVoting;

  /// No description provided for @detectiveBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'The Detective is blocked'**
  String get detectiveBlockedTitle;

  /// No description provided for @detectiveChecked.
  ///
  /// In en, this message translates to:
  /// **'The Detective checked {name}'**
  String detectiveChecked(String name);

  /// No description provided for @detectiveDone.
  ///
  /// In en, this message translates to:
  /// **'Continue the night'**
  String get detectiveDone;

  /// No description provided for @detectiveNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get detectiveNoAnswer;

  /// No description provided for @detectiveSignalHint.
  ///
  /// In en, this message translates to:
  /// **'Signal this to the Detective without a word.'**
  String get detectiveSignalHint;

  /// No description provided for @gameOverBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get gameOverBackHome;

  /// No description provided for @gameOverSummary.
  ///
  /// In en, this message translates to:
  /// **'{nights, plural, =1{After 1 night} other{After {nights} nights}} · {alive} still standing'**
  String gameOverSummary(int nights, int alive);

  /// No description provided for @homeContinueAt.
  ///
  /// In en, this message translates to:
  /// **'Continue · {stage}'**
  String homeContinueAt(String stage);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, Host'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, Host'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, Host'**
  String get homeGreetingMorning;

  /// No description provided for @homeHeroAlive.
  ///
  /// In en, this message translates to:
  /// **'{count} still alive'**
  String homeHeroAlive(int count);

  /// No description provided for @homeHeroEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add the players and deal the cards.'**
  String get homeHeroEmpty;

  /// No description provided for @homeHeroInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get homeHeroInProgress;

  /// No description provided for @homeHeroLastTable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 player from your last game} other{{count} players from your last game}}'**
  String homeHeroLastTable(int count);

  /// No description provided for @homeHeroReady.
  ///
  /// In en, this message translates to:
  /// **'{count} at the table'**
  String homeHeroReady(int count);

  /// No description provided for @homeHeroTag.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get homeHeroTag;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s table'**
  String get homeHeroTitle;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Finished games will show up here.'**
  String get homeRecentEmpty;

  /// No description provided for @homeStartGame.
  ///
  /// In en, this message translates to:
  /// **'Start a game'**
  String get homeStartGame;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'The city sleeps.'**
  String get homeTitle;

  /// No description provided for @homeYourTable.
  ///
  /// In en, this message translates to:
  /// **'Your table'**
  String get homeYourTable;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menuMore;

  /// No description provided for @morningReadInOrder.
  ///
  /// In en, this message translates to:
  /// **'Read these out in order'**
  String get morningReadInOrder;

  /// No description provided for @morningTitle.
  ///
  /// In en, this message translates to:
  /// **'The town wakes up.'**
  String get morningTitle;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get navPlayers;

  /// No description provided for @nightContinueNoAction.
  ///
  /// In en, this message translates to:
  /// **'Next · no action'**
  String get nightContinueNoAction;

  /// No description provided for @nightIntroHint.
  ///
  /// In en, this message translates to:
  /// **'Read it out, then begin when the table is quiet.'**
  String get nightIntroHint;

  /// No description provided for @nightPreviousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get nightPreviousStep;

  /// No description provided for @nightReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a step to change it.'**
  String get nightReviewHint;

  /// No description provided for @recentCiviliansWon.
  ///
  /// In en, this message translates to:
  /// **'Civilians won'**
  String get recentCiviliansWon;

  /// No description provided for @recentDetail.
  ///
  /// In en, this message translates to:
  /// **'Night {nights} · {players, plural, =1{1 player} other{{players} players}}'**
  String recentDetail(int nights, int players);

  /// No description provided for @recentMafiaWon.
  ///
  /// In en, this message translates to:
  /// **'Mafia won'**
  String get recentMafiaWon;

  /// No description provided for @revealDealing.
  ///
  /// In en, this message translates to:
  /// **'Dealing roles'**
  String get revealDealing;

  /// No description provided for @revealHandTo.
  ///
  /// In en, this message translates to:
  /// **'Hand the phone to'**
  String get revealHandTo;

  /// No description provided for @revealHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the card close, then tap it'**
  String get revealHint;

  /// No description provided for @revealProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String revealProgress(int current, int total);

  /// No description provided for @setupAddPlayersHint.
  ///
  /// In en, this message translates to:
  /// **'Add the players around the table'**
  String get setupAddPlayersHint;

  /// No description provided for @setupAutoBalance.
  ///
  /// In en, this message translates to:
  /// **'Auto-balance'**
  String get setupAutoBalance;

  /// No description provided for @setupPlayersAtTable.
  ///
  /// In en, this message translates to:
  /// **'Players at the table'**
  String get setupPlayersAtTable;

  /// No description provided for @setupRolesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a role to add one, hold to remove one.'**
  String get setupRolesHint;

  /// No description provided for @statNone.
  ///
  /// In en, this message translates to:
  /// **'–'**
  String get statNone;

  /// No description provided for @timerPaused.
  ///
  /// In en, this message translates to:
  /// **'paused'**
  String get timerPaused;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Game nights'**
  String get eventsTitle;

  /// No description provided for @eventsPast.
  ///
  /// In en, this message translates to:
  /// **'Past nights'**
  String get eventsPast;

  /// No description provided for @eventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your game nights will show up here once a game is finished.'**
  String get eventsEmpty;

  /// No description provided for @eventsPlanningSoon.
  ///
  /// In en, this message translates to:
  /// **'Planning nights ahead and RSVPs arrive with player accounts.'**
  String get eventsPlanningSoon;

  /// No description provided for @eventsNightDetail.
  ///
  /// In en, this message translates to:
  /// **'{games, plural, =1{1 game} other{{games} games}} · {players, plural, =1{1 player} other{{players} players}}'**
  String eventsNightDetail(int games, int players);

  /// No description provided for @eventsGameNight.
  ///
  /// In en, this message translates to:
  /// **'Game night'**
  String get eventsGameNight;

  /// No description provided for @eventsTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String eventsTimeRange(String start, String end);

  /// No description provided for @eventsAttendees.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 at the table} other{{count} at the table}}'**
  String eventsAttendees(int count);

  /// No description provided for @eventsGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get eventsGamesPlayed;

  /// No description provided for @homeSeeStats.
  ///
  /// In en, this message translates to:
  /// **'See stats'**
  String get homeSeeStats;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a room'**
  String get joinTitle;

  /// No description provided for @joinIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the code on the host\'s phone to play from your own phone.'**
  String get joinIntro;

  /// No description provided for @joinCodeHint.
  ///
  /// In en, this message translates to:
  /// **'4 to 6 letters or numbers'**
  String get joinCodeHint;

  /// No description provided for @joinScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get joinScanQr;

  /// No description provided for @joinCta.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinCta;

  /// No description provided for @joinNotYet.
  ///
  /// In en, this message translates to:
  /// **'Playing from players\' phones is coming in a later update.'**
  String get joinNotYet;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ranked by wins across every finished game'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Finish a game to start the leaderboard.'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardRowDetail.
  ///
  /// In en, this message translates to:
  /// **'{games, plural, =1{1 game} other{{games} games}} · {rate}% wins'**
  String leaderboardRowDetail(int games, int rate);

  /// No description provided for @leaderboardWins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 win} other{{count} wins}}'**
  String leaderboardWins(int count);

  /// No description provided for @logFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get logFilterAll;

  /// No description provided for @logFilterKills.
  ///
  /// In en, this message translates to:
  /// **'Kills'**
  String get logFilterKills;

  /// No description provided for @logFilterSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get logFilterSaves;

  /// No description provided for @logFilterVotes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get logFilterVotes;

  /// No description provided for @logNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing of this kind yet.'**
  String get logNothingHere;

  /// No description provided for @nightGodfatherConfirms.
  ///
  /// In en, this message translates to:
  /// **'Godfather confirms: kill {name}'**
  String nightGodfatherConfirms(String name);

  /// No description provided for @nightMafiaProposalHint.
  ///
  /// In en, this message translates to:
  /// **'Hold a player to mark a Mafia proposal; tap to choose the kill.'**
  String get nightMafiaProposalHint;

  /// No description provided for @profileFavoriteRole.
  ///
  /// In en, this message translates to:
  /// **'Favorite role'**
  String get profileFavoriteRole;

  /// No description provided for @profileLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played {date}'**
  String profileLastPlayed(String date);

  /// No description provided for @profileNoGames.
  ///
  /// In en, this message translates to:
  /// **'No finished games yet.'**
  String get profileNoGames;

  /// No description provided for @profileRoleHistory.
  ///
  /// In en, this message translates to:
  /// **'Role history'**
  String get profileRoleHistory;

  /// No description provided for @profileWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get profileWinRate;

  /// No description provided for @settingsDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Every new game starts with these; change them per game in setup.'**
  String get settingsDefaultsHint;

  /// No description provided for @settingsDefaultsSection.
  ///
  /// In en, this message translates to:
  /// **'Game defaults'**
  String get settingsDefaultsSection;

  /// No description provided for @settingsFeedbackSection.
  ///
  /// In en, this message translates to:
  /// **'Sound & touch'**
  String get settingsFeedbackSection;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A light tap on picks, card flips and when time runs out'**
  String get settingsHapticsSubtitle;

  /// No description provided for @settingsDeviceShort.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get settingsDeviceShort;

  /// No description provided for @setupRolesHow.
  ///
  /// In en, this message translates to:
  /// **'How players get their roles'**
  String get setupRolesHow;

  /// No description provided for @setupModePhone.
  ///
  /// In en, this message translates to:
  /// **'Pass the phone'**
  String get setupModePhone;

  /// No description provided for @setupModeCards.
  ///
  /// In en, this message translates to:
  /// **'Physical cards'**
  String get setupModeCards;

  /// No description provided for @setupModePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Each player taps the phone to see their role.'**
  String get setupModePhoneHint;

  /// No description provided for @setupModeCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Hand out the cards, then tap who holds each one on night 1.'**
  String get setupModeCardsHint;

  /// No description provided for @setupCardsDealt.
  ///
  /// In en, this message translates to:
  /// **'I\'ve handed out the cards'**
  String get setupCardsDealt;

  /// No description provided for @cardsOverline.
  ///
  /// In en, this message translates to:
  /// **'Night 1 · Who has which card'**
  String get cardsOverline;

  /// No description provided for @cardsWake.
  ///
  /// In en, this message translates to:
  /// **'{role} wakes up'**
  String cardsWake(String role);

  /// No description provided for @cardsLine.
  ///
  /// In en, this message translates to:
  /// **'If you hold this card, open your eyes.'**
  String get cardsLine;

  /// No description provided for @cardsPicked.
  ///
  /// In en, this message translates to:
  /// **'Tap who holds it · {picked} of {total}'**
  String cardsPicked(int picked, int total);

  /// No description provided for @cardsNextRole.
  ///
  /// In en, this message translates to:
  /// **'Next: {role}'**
  String cardsNextRole(String role);

  /// No description provided for @cardsReviewStep.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get cardsReviewStep;

  /// No description provided for @cardsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the cards'**
  String get cardsReviewTitle;

  /// No description provided for @cardsReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to fix it. Everyone else holds a Civilian card.'**
  String get cardsReviewHint;

  /// No description provided for @cardsReviewCheck.
  ///
  /// In en, this message translates to:
  /// **'Check the cards'**
  String get cardsReviewCheck;

  /// No description provided for @rolePutana.
  ///
  /// In en, this message translates to:
  /// **'Putana'**
  String get rolePutana;

  /// No description provided for @roleWitch.
  ///
  /// In en, this message translates to:
  /// **'Witch'**
  String get roleWitch;

  /// No description provided for @roleSwitchman.
  ///
  /// In en, this message translates to:
  /// **'Switchman'**
  String get roleSwitchman;

  /// No description provided for @roleSilencer.
  ///
  /// In en, this message translates to:
  /// **'Silencer'**
  String get roleSilencer;

  /// No description provided for @roleShapeshifter.
  ///
  /// In en, this message translates to:
  /// **'Shapeshifter'**
  String get roleShapeshifter;

  /// No description provided for @roleTnt.
  ///
  /// In en, this message translates to:
  /// **'TNT'**
  String get roleTnt;

  /// No description provided for @abilityPutana.
  ///
  /// In en, this message translates to:
  /// **'Night 1: wake with the Mafia to know your team. After that, block one player\'s ability each night. Left alone on the Mafia Team, you kill like a Mafia.'**
  String get abilityPutana;

  /// No description provided for @abilityWitch.
  ///
  /// In en, this message translates to:
  /// **'Once, on night 2, link two Civilians\' souls. If one of them is killed at night, the other dies too. Votes don\'t trigger it, and it lasts after you die.'**
  String get abilityWitch;

  /// No description provided for @abilitySwitchman.
  ///
  /// In en, this message translates to:
  /// **'If someone tries to kill you at night, you wake and send the bullet to a player of your choice. You die at night only if the Putana blocks you that night.'**
  String get abilitySwitchman;

  /// No description provided for @abilitySilencer.
  ///
  /// In en, this message translates to:
  /// **'Each night, silence one player for the next day: no Free Chat, no Speech, no vote.'**
  String get abilitySilencer;

  /// No description provided for @abilityShapeshifter.
  ///
  /// In en, this message translates to:
  /// **'Your ability changes every night in order: Detective, Doctor, Joker, then again. You always stay on the Civilians Team.'**
  String get abilityShapeshifter;

  /// No description provided for @abilityTnt.
  ///
  /// In en, this message translates to:
  /// **'If you are eliminated, in any way, the players sitting right and left of you are eliminated too.'**
  String get abilityTnt;

  /// No description provided for @abilityDoctor.
  ///
  /// In en, this message translates to:
  /// **'Save one player each night, yourself included. The same player two nights in a row is fine, but not three.'**
  String get abilityDoctor;

  /// No description provided for @abilityDetective.
  ///
  /// In en, this message translates to:
  /// **'Check one player each night: the host tells you if they are Mafia. Three checks with two Mafia found, and those two die with you if you are killed.'**
  String get abilityDetective;

  /// No description provided for @abilityBomb.
  ///
  /// In en, this message translates to:
  /// **'After the first day, plant bombs on two players. When you die, by night or by vote, they die too. Voted out on day 1: take both neighbors, or no one.'**
  String get abilityBomb;

  /// No description provided for @abilityChameleon.
  ///
  /// In en, this message translates to:
  /// **'On night 3, choose Mafia, Detective, Doctor, Joker or Switchman, and keep that role for the rest of the game.'**
  String get abilityChameleon;

  /// No description provided for @abilityGodfather.
  ///
  /// In en, this message translates to:
  /// **'The final call on who the Mafia kills is yours. Voted out by day, you may take one player with you.'**
  String get abilityGodfather;

  /// No description provided for @abilityMafia.
  ///
  /// In en, this message translates to:
  /// **'Each night, advise the Godfather on who dies. Without him, every Mafia must show the same number, or nobody dies.'**
  String get abilityMafia;

  /// No description provided for @nightWakeTitleRecognition.
  ///
  /// In en, this message translates to:
  /// **'Mafia Team, wake up'**
  String get nightWakeTitleRecognition;

  /// No description provided for @nightLineRecognition.
  ///
  /// In en, this message translates to:
  /// **'Mafia Team, open your eyes and recognize each other. Putana, you too.'**
  String get nightLineRecognition;

  /// No description provided for @nightRecognitionHint.
  ///
  /// In en, this message translates to:
  /// **'Night 1 only. Nobody acts yet.'**
  String get nightRecognitionHint;

  /// No description provided for @nightRecognized.
  ///
  /// In en, this message translates to:
  /// **'They know each other'**
  String get nightRecognized;

  /// No description provided for @reviewRecognition.
  ///
  /// In en, this message translates to:
  /// **'The Mafia Team recognized each other'**
  String get reviewRecognition;

  /// No description provided for @nightWakeTitlePutana.
  ///
  /// In en, this message translates to:
  /// **'Wake the Putana'**
  String get nightWakeTitlePutana;

  /// No description provided for @nightLinePutana.
  ///
  /// In en, this message translates to:
  /// **'Putana, open your eyes. Whose ability do you block tonight?'**
  String get nightLinePutana;

  /// No description provided for @nightWakeTitleWitch.
  ///
  /// In en, this message translates to:
  /// **'Wake the Witch'**
  String get nightWakeTitleWitch;

  /// No description provided for @nightLineWitch.
  ///
  /// In en, this message translates to:
  /// **'Witch, open your eyes. Which two souls do you link?'**
  String get nightLineWitch;

  /// No description provided for @nightWakeTitleSilencer.
  ///
  /// In en, this message translates to:
  /// **'Wake the Silencer'**
  String get nightWakeTitleSilencer;

  /// No description provided for @nightLineSilencer.
  ///
  /// In en, this message translates to:
  /// **'Silencer, open your eyes. Who stays silent tomorrow?'**
  String get nightLineSilencer;

  /// No description provided for @nightWakeTitleShapeshifter.
  ///
  /// In en, this message translates to:
  /// **'Wake the Shapeshifter'**
  String get nightWakeTitleShapeshifter;

  /// No description provided for @nightLineShapeshifter.
  ///
  /// In en, this message translates to:
  /// **'Shapeshifter, open your eyes. Tonight you are the {role}.'**
  String nightLineShapeshifter(String role);

  /// No description provided for @nightWakeTitleBomb.
  ///
  /// In en, this message translates to:
  /// **'Wake the Bomb'**
  String get nightWakeTitleBomb;

  /// No description provided for @nightLineBomb.
  ///
  /// In en, this message translates to:
  /// **'Bomb, open your eyes. Who carries your two bombs?'**
  String get nightLineBomb;

  /// No description provided for @nightWakeTitleChameleon.
  ///
  /// In en, this message translates to:
  /// **'Wake the Chameleon'**
  String get nightWakeTitleChameleon;

  /// No description provided for @nightLineChameleonChoose.
  ///
  /// In en, this message translates to:
  /// **'Chameleon, open your eyes. Mafia, Detective, Doctor, Joker or Switchman: which do you keep for the rest of the game?'**
  String get nightLineChameleonChoose;

  /// No description provided for @nightLineChameleonAs.
  ///
  /// In en, this message translates to:
  /// **'Chameleon, open your eyes. You play the {role}.'**
  String nightLineChameleonAs(String role);

  /// No description provided for @nightWakeTitleSwitchman.
  ///
  /// In en, this message translates to:
  /// **'Wake the Switchman'**
  String get nightWakeTitleSwitchman;

  /// No description provided for @nightLineSwitchman.
  ///
  /// In en, this message translates to:
  /// **'Switchman, open your eyes. Someone shot at you. Who takes the bullet?'**
  String get nightLineSwitchman;

  /// No description provided for @nightLineSwitchmanBullet.
  ///
  /// In en, this message translates to:
  /// **'Switchman, open your eyes. Bullet {current} of {total}: who takes it?'**
  String nightLineSwitchmanBullet(int current, int total);

  /// No description provided for @nightBlockedWarning.
  ///
  /// In en, this message translates to:
  /// **'Blocked by the Putana tonight: this action will have no effect. Let them choose anyway.'**
  String get nightBlockedWarning;

  /// No description provided for @nightBlockedDecider.
  ///
  /// In en, this message translates to:
  /// **'The Putana blocked {name}: the other Mafia\'s number counts tonight.'**
  String nightBlockedDecider(String name);

  /// No description provided for @nightDoctorTwoNights.
  ///
  /// In en, this message translates to:
  /// **'Saved two nights running'**
  String get nightDoctorTwoNights;

  /// No description provided for @nightMafiaTalk.
  ///
  /// In en, this message translates to:
  /// **'Mafia talk'**
  String get nightMafiaTalk;

  /// No description provided for @nightMafiaTalkHint.
  ///
  /// In en, this message translates to:
  /// **'They agree on a target; the Godfather decides.'**
  String get nightMafiaTalkHint;

  /// No description provided for @nightMafiaMustAgree.
  ///
  /// In en, this message translates to:
  /// **'No Godfather: every Mafia must show the same number. Different numbers cancel the murder.'**
  String get nightMafiaMustAgree;

  /// No description provided for @nightMafiaNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Numbers didn\'t match'**
  String get nightMafiaNoMatch;

  /// No description provided for @nightPickToSilence.
  ///
  /// In en, this message translates to:
  /// **'Pick a player to silence'**
  String get nightPickToSilence;

  /// No description provided for @nightPickTwoToLink.
  ///
  /// In en, this message translates to:
  /// **'Pick two players to link'**
  String get nightPickTwoToLink;

  /// No description provided for @nightPickTwoToPlant.
  ///
  /// In en, this message translates to:
  /// **'Pick two players for the bombs'**
  String get nightPickTwoToPlant;

  /// No description provided for @nightPickToRedirect.
  ///
  /// In en, this message translates to:
  /// **'Pick who takes the bullet'**
  String get nightPickToRedirect;

  /// No description provided for @actionLink.
  ///
  /// In en, this message translates to:
  /// **'Link {first} and {second}'**
  String actionLink(String first, String second);

  /// No description provided for @actionPlant.
  ///
  /// In en, this message translates to:
  /// **'Plant on {first} and {second}'**
  String actionPlant(String first, String second);

  /// No description provided for @actionSilenceShort.
  ///
  /// In en, this message translates to:
  /// **'Silence {name}'**
  String actionSilenceShort(String name);

  /// No description provided for @actionRedirectTo.
  ///
  /// In en, this message translates to:
  /// **'Send it to {name}'**
  String actionRedirectTo(String name);

  /// No description provided for @actionPutanaBlock.
  ///
  /// In en, this message translates to:
  /// **'{actor} blocked {target}'**
  String actionPutanaBlock(String actor, String target);

  /// No description provided for @actionSilence.
  ///
  /// In en, this message translates to:
  /// **'{actor} silenced {target}'**
  String actionSilence(String actor, String target);

  /// No description provided for @actionRedirect.
  ///
  /// In en, this message translates to:
  /// **'{actor} sent the bullet to {target}'**
  String actionRedirect(String actor, String target);

  /// No description provided for @actionWitchLink.
  ///
  /// In en, this message translates to:
  /// **'{actor} linked {first} and {second}'**
  String actionWitchLink(String actor, String first, String second);

  /// No description provided for @actionBombPlant.
  ///
  /// In en, this message translates to:
  /// **'{actor} planted bombs on {first} and {second}'**
  String actionBombPlant(String actor, String first, String second);

  /// No description provided for @actionChameleonChoose.
  ///
  /// In en, this message translates to:
  /// **'{actor} chose to be the {role}'**
  String actionChameleonChoose(String actor, String role);

  /// No description provided for @hostLinked.
  ///
  /// In en, this message translates to:
  /// **'The Witch linked {first} and {second}.'**
  String hostLinked(String first, String second);

  /// No description provided for @hostBombPlanted.
  ///
  /// In en, this message translates to:
  /// **'{bomb} (Bomb) planted on {first} and {second}.'**
  String hostBombPlanted(String bomb, String first, String second);

  /// No description provided for @hostChameleonChose.
  ///
  /// In en, this message translates to:
  /// **'{name} (Chameleon) is now the {role}.'**
  String hostChameleonChose(String name, String role);

  /// No description provided for @hostMafiaCancelled.
  ///
  /// In en, this message translates to:
  /// **'The Mafia showed different numbers: no murder.'**
  String get hostMafiaCancelled;

  /// No description provided for @hostRedirected.
  ///
  /// In en, this message translates to:
  /// **'{switchman} (Switchman) sent a bullet to {target}.'**
  String hostRedirected(String switchman, String target);

  /// No description provided for @hostDodged.
  ///
  /// In en, this message translates to:
  /// **'{name} (Switchman) was shot at and survived.'**
  String hostDodged(String name);

  /// No description provided for @hostChainArmed.
  ///
  /// In en, this message translates to:
  /// **'{detective} (Detective) found {names}: they die with the Detective.'**
  String hostChainArmed(String detective, String names);

  /// No description provided for @hostPutanaPromoted.
  ///
  /// In en, this message translates to:
  /// **'{name} (Putana) is the last of the Mafia Team and now kills.'**
  String hostPutanaPromoted(String name);

  /// No description provided for @announceRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} was removed from the table.'**
  String announceRemoved(String name);

  /// No description provided for @announceTntVictim.
  ///
  /// In en, this message translates to:
  /// **'{name} was caught in the TNT blast.'**
  String announceTntVictim(String name);

  /// No description provided for @announceGodfatherVictim.
  ///
  /// In en, this message translates to:
  /// **'{name} was taken by the Godfather.'**
  String announceGodfatherVictim(String name);

  /// No description provided for @announceWasTnt.
  ///
  /// In en, this message translates to:
  /// **'{headline} They were the TNT.'**
  String announceWasTnt(String headline);

  /// No description provided for @announceSilenced.
  ///
  /// In en, this message translates to:
  /// **'{name} is silenced today.'**
  String announceSilenced(String name);

  /// No description provided for @announceSilencedRule.
  ///
  /// In en, this message translates to:
  /// **'No Free Chat, no Speech, no vote'**
  String get announceSilencedRule;

  /// No description provided for @announceGodfatherChoosing.
  ///
  /// In en, this message translates to:
  /// **'He may take one player with him: choose now.'**
  String get announceGodfatherChoosing;

  /// No description provided for @announceBombNeighborsChoosing.
  ///
  /// In en, this message translates to:
  /// **'Both neighbors go with them, or no one: choose now.'**
  String get announceBombNeighborsChoosing;

  /// No description provided for @choiceWasGodfather.
  ///
  /// In en, this message translates to:
  /// **'{name} was the Godfather'**
  String choiceWasGodfather(String name);

  /// No description provided for @choiceGodfatherHint.
  ///
  /// In en, this message translates to:
  /// **'Voted out, he may take one player with him, or no one.'**
  String get choiceGodfatherHint;

  /// No description provided for @choiceBombNeighborsHint.
  ///
  /// In en, this message translates to:
  /// **'Voted out before planting: take both players sitting beside them, or no one.'**
  String get choiceBombNeighborsHint;

  /// No description provided for @choiceTake.
  ///
  /// In en, this message translates to:
  /// **'Take {names}'**
  String choiceTake(String names);

  /// No description provided for @choiceTakeNoOne.
  ///
  /// In en, this message translates to:
  /// **'Take no one'**
  String get choiceTakeNoOne;

  /// No description provided for @dayFreeChat.
  ///
  /// In en, this message translates to:
  /// **'Free Chat'**
  String get dayFreeChat;

  /// No description provided for @dayFreeChatHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone may talk, suspect and defend.'**
  String get dayFreeChatHint;

  /// No description provided for @daySpeeches.
  ///
  /// In en, this message translates to:
  /// **'Speeches'**
  String get daySpeeches;

  /// No description provided for @daySpeech.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get daySpeech;

  /// No description provided for @dayFoul.
  ///
  /// In en, this message translates to:
  /// **'Foul'**
  String get dayFoul;

  /// No description provided for @dayStartSpeeches.
  ///
  /// In en, this message translates to:
  /// **'Start the speeches'**
  String get dayStartSpeeches;

  /// No description provided for @daySpeechCounter.
  ///
  /// In en, this message translates to:
  /// **'Speech {current} of {total}'**
  String daySpeechCounter(int current, int total);

  /// No description provided for @daySpeechHint.
  ///
  /// In en, this message translates to:
  /// **'Their time. Nobody answers until it ends.'**
  String get daySpeechHint;

  /// No description provided for @dayOnFoul.
  ///
  /// In en, this message translates to:
  /// **'On a Foul: an extra speech'**
  String get dayOnFoul;

  /// No description provided for @dayTakeFoul.
  ///
  /// In en, this message translates to:
  /// **'Foul +{seconds}s'**
  String dayTakeFoul(int seconds);

  /// No description provided for @daySpeechOrder.
  ///
  /// In en, this message translates to:
  /// **'Speaking order (seats)'**
  String get daySpeechOrder;

  /// No description provided for @dayNextSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String dayNextSpeaker(String name);

  /// No description provided for @dayPreviousSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Previous speaker'**
  String get dayPreviousSpeaker;

  /// No description provided for @dayNoSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Nobody may speak today.'**
  String get dayNoSpeakers;

  /// No description provided for @daySilencedToday.
  ///
  /// In en, this message translates to:
  /// **'Silenced today: {names}'**
  String daySilencedToday(String names);

  /// No description provided for @daySilencedNoVote.
  ///
  /// In en, this message translates to:
  /// **'Silenced, can\'t vote: {names}'**
  String daySilencedNoVote(String names);

  /// No description provided for @dayTieRevote.
  ///
  /// In en, this message translates to:
  /// **'Tie between {names}. Re-vote between them.'**
  String dayTieRevote(String names);

  /// No description provided for @dayTieHostDecides.
  ///
  /// In en, this message translates to:
  /// **'Tied again between {names}. Who is out?'**
  String dayTieHostDecides(String names);

  /// No description provided for @dayTieDrawLots.
  ///
  /// In en, this message translates to:
  /// **'Tied again between {names}. Draw lots.'**
  String dayTieDrawLots(String names);

  /// No description provided for @dayDrawLots.
  ///
  /// In en, this message translates to:
  /// **'Draw lots'**
  String get dayDrawLots;

  /// No description provided for @statusSilenced.
  ///
  /// In en, this message translates to:
  /// **'Silenced'**
  String get statusSilenced;

  /// No description provided for @statusFouls.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No fouls} =1{1 foul} other{{count} fouls}}'**
  String statusFouls(int count);

  /// No description provided for @logChoice.
  ///
  /// In en, this message translates to:
  /// **'{name} took {victims}'**
  String logChoice(String name, String victims);

  /// No description provided for @logChoiceNone.
  ///
  /// In en, this message translates to:
  /// **'{name} took no one'**
  String logChoiceNone(String name);

  /// No description provided for @logFoul.
  ///
  /// In en, this message translates to:
  /// **'{name} took a Foul'**
  String logFoul(String name);

  /// No description provided for @menuRemovePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove a player'**
  String get menuRemovePlayer;

  /// No description provided for @removePlayerHint.
  ///
  /// In en, this message translates to:
  /// **'For repeatedly breaking the table rules. They leave the game; a TNT still explodes.'**
  String get removePlayerHint;

  /// No description provided for @removePlayerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removePlayerConfirmTitle(String name);

  /// No description provided for @removePlayerConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They leave the game for good. You can undo it from the menu.'**
  String get removePlayerConfirmBody;

  /// No description provided for @removePlayerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePlayerConfirm;

  /// No description provided for @setupSeatOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Seat order matters: the list goes around the table, and the last player sits next to the first.'**
  String get setupSeatOrderHint;

  /// No description provided for @setupSeatOrderSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Add players in seat order, going around the table. Drag to fix the order.'**
  String get setupSeatOrderSheetHint;

  /// No description provided for @setupTimers.
  ///
  /// In en, this message translates to:
  /// **'Timers'**
  String get setupTimers;

  /// No description provided for @setupTimersHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a timer during the game to start it'**
  String get setupTimersHint;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count}:00'**
  String minutesShort(int count);

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String secondsShort(int count);

  /// No description provided for @setupHouseRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Open questions in the rules'**
  String get setupHouseRulesHint;

  /// No description provided for @setupHouseRulesSheetHint.
  ///
  /// In en, this message translates to:
  /// **'The guide leaves these open. Defaults follow docs/GAME_RULES.md.'**
  String get setupHouseRulesSheetHint;

  /// No description provided for @ruleGodfatherAppearsCivilian.
  ///
  /// In en, this message translates to:
  /// **'Detective sees the Godfather as Civilian'**
  String get ruleGodfatherAppearsCivilian;

  /// No description provided for @rulePutanaCanBlockMafia.
  ///
  /// In en, this message translates to:
  /// **'Putana can block Mafia Team players'**
  String get rulePutanaCanBlockMafia;

  /// No description provided for @ruleChameleonMafiaJoins.
  ///
  /// In en, this message translates to:
  /// **'A Mafia Chameleon joins the Mafia Team'**
  String get ruleChameleonMafiaJoins;

  /// No description provided for @ruleDetectiveChainOnVote.
  ///
  /// In en, this message translates to:
  /// **'Detective chain also when voted out'**
  String get ruleDetectiveChainOnVote;

  /// No description provided for @ruleBlockedChecksCount.
  ///
  /// In en, this message translates to:
  /// **'Blocked checks count toward the three'**
  String get ruleBlockedChecksCount;

  /// No description provided for @ruleDoctorBlocksChainDeaths.
  ///
  /// In en, this message translates to:
  /// **'Doctor saves from chain deaths'**
  String get ruleDoctorBlocksChainDeaths;

  /// No description provided for @ruleSwitchmanRedirectsEach.
  ///
  /// In en, this message translates to:
  /// **'Switchman redirects every bullet'**
  String get ruleSwitchmanRedirectsEach;

  /// No description provided for @ruleDoctorSavesRedirected.
  ///
  /// In en, this message translates to:
  /// **'Doctor saves from a redirected bullet'**
  String get ruleDoctorSavesRedirected;

  /// No description provided for @ruleBombNoEffectBeforePlant.
  ///
  /// In en, this message translates to:
  /// **'Bomb killed on night 1 has no effect'**
  String get ruleBombNoEffectBeforePlant;

  /// No description provided for @ruleSilenceLastsNextDay.
  ///
  /// In en, this message translates to:
  /// **'Silence lasts the next day only'**
  String get ruleSilenceLastsNextDay;

  /// No description provided for @ruleWitchCiviliansOnly.
  ///
  /// In en, this message translates to:
  /// **'Witch links Civilians only'**
  String get ruleWitchCiviliansOnly;

  /// No description provided for @ruleMafiaWinsAtParity.
  ///
  /// In en, this message translates to:
  /// **'Mafia win when equal to the Civilians'**
  String get ruleMafiaWinsAtParity;

  /// No description provided for @ruleSecondTie.
  ///
  /// In en, this message translates to:
  /// **'If the re-vote ties again'**
  String get ruleSecondTie;

  /// No description provided for @tieRandom.
  ///
  /// In en, this message translates to:
  /// **'Draw lots'**
  String get tieRandom;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
