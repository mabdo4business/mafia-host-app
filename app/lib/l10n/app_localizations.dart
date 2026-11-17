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

  /// No description provided for @rolePotana.
  ///
  /// In en, this message translates to:
  /// **'Potana'**
  String get rolePotana;

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

  /// No description provided for @setupBombVictims.
  ///
  /// In en, this message translates to:
  /// **'Bomb victims'**
  String get setupBombVictims;

  /// No description provided for @setupRevealRole.
  ///
  /// In en, this message translates to:
  /// **'Reveal role on death'**
  String get setupRevealRole;

  /// No description provided for @setupDiscussionTimer.
  ///
  /// In en, this message translates to:
  /// **'Discussion timer'**
  String get setupDiscussionTimer;

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

  /// No description provided for @ruleDoctorSaveBlocksJoker.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s save also stops the Joker'**
  String get ruleDoctorSaveBlocksJoker;

  /// No description provided for @ruleDoctorCanSaveBombVictims.
  ///
  /// In en, this message translates to:
  /// **'Doctor can save Bomb victims'**
  String get ruleDoctorCanSaveBombVictims;

  /// No description provided for @ruleBlockedBombExplodes.
  ///
  /// In en, this message translates to:
  /// **'Blocked Bomb still explodes'**
  String get ruleBlockedBombExplodes;

  /// No description provided for @ruleChameleonMafia.
  ///
  /// In en, this message translates to:
  /// **'Chameleon can pick Mafia roles'**
  String get ruleChameleonMafia;

  /// No description provided for @ruleTieVote.
  ///
  /// In en, this message translates to:
  /// **'Tied vote'**
  String get ruleTieVote;

  /// No description provided for @tieRevote.
  ///
  /// In en, this message translates to:
  /// **'Revote'**
  String get tieRevote;

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
  /// **'Add at least {min} players.'**
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

  /// No description provided for @dealChameleonPlaysAs.
  ///
  /// In en, this message translates to:
  /// **'Chameleon plays as'**
  String get dealChameleonPlaysAs;

  /// No description provided for @dealChameleonMissing.
  ///
  /// In en, this message translates to:
  /// **'Each Chameleon must choose a role.'**
  String get dealChameleonMissing;

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

  /// No description provided for @nightWakePotana.
  ///
  /// In en, this message translates to:
  /// **'Wake the Potana. Who do they block?'**
  String get nightWakePotana;

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

  /// No description provided for @nightBlockedWarning.
  ///
  /// In en, this message translates to:
  /// **'Blocked by the Potana tonight — this action will have no effect. Let them choose anyway.'**
  String get nightBlockedWarning;

  /// No description provided for @nightDoctorLastNight.
  ///
  /// In en, this message translates to:
  /// **'Saved last night'**
  String get nightDoctorLastNight;

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

  /// No description provided for @actionPotanaBlock.
  ///
  /// In en, this message translates to:
  /// **'{actor} blocked {target}'**
  String actionPotanaBlock(String actor, String target);

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

  /// No description provided for @hostBombDefused.
  ///
  /// In en, this message translates to:
  /// **'{name} (Bomb) was blocked and did not explode.'**
  String hostBombDefused(String name);

  /// No description provided for @bombPick.
  ///
  /// In en, this message translates to:
  /// **'{name} was the Bomb. Choose {count, plural, =1{1 player} other{{count} players}} to die with them.'**
  String bombPick(String name, int count);

  /// No description provided for @bombDetonate.
  ///
  /// In en, this message translates to:
  /// **'Detonate ({selected}/{required})'**
  String bombDetonate(String selected, String required);

  /// No description provided for @morningStartDay.
  ///
  /// In en, this message translates to:
  /// **'Start the day'**
  String get morningStartDay;

  /// No description provided for @dayDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get dayDiscussion;

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

  /// No description provided for @dayTieHostDecides.
  ///
  /// In en, this message translates to:
  /// **'Tie between {names}. Who is out?'**
  String dayTieHostDecides(String names);

  /// No description provided for @dayTieRevote.
  ///
  /// In en, this message translates to:
  /// **'Tie between {names}. Vote again.'**
  String dayTieRevote(String names);

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
