// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مضيف المافيا';

  @override
  String get homeTagline => 'أدِر ليالي المافيا بالبطاقات الورقية — هاتف واحد ودون إنترنت.';

  @override
  String get homeNewGame => 'لعبة جديدة';

  @override
  String get homeContinueGame => 'متابعة';

  @override
  String get newGameConfirmTitle => 'بدء لعبة جديدة؟';

  @override
  String get newGameConfirmBody => 'سيتم إغلاق اللعبة الجارية.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsSystemDefault => 'إعداد الجهاز';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsSoundSection => 'الصوت';

  @override
  String get settingsSound => 'المؤثرات الصوتية';

  @override
  String get settingsSoundSubtitle => 'نغمة عند حلول الليل وعند طلوع الصباح';

  @override
  String get roleCivilian => 'مواطن';

  @override
  String get roleDoctor => 'طبيب';

  @override
  String get roleDetective => 'محقق';

  @override
  String get roleBomb => 'قنبلة';

  @override
  String get roleJoker => 'جوكر';

  @override
  String get roleChameleon => 'حرباء';

  @override
  String get roleMafia => 'مافيا';

  @override
  String get roleGodfather => 'عرّاب';

  @override
  String get roleLawyer => 'محامي';

  @override
  String get teamCivilians => 'المواطنون';

  @override
  String get teamMafia => 'المافيا';

  @override
  String chameleonAs(String role) {
    return 'حرباء بدور $role';
  }

  @override
  String get listSeparator => '، ';

  @override
  String stageNight(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'الليلة $roundString';
  }

  @override
  String stageMorning(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'الصباح $roundString';
  }

  @override
  String stageDay(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'النهار $roundString';
  }

  @override
  String get stageGameOver => 'انتهت اللعبة';

  @override
  String get readAloud => 'اقرأ بصوت عالٍ';

  @override
  String get stopReading => 'إيقاف القراءة';

  @override
  String get hostOnly => 'للمضيف فقط';

  @override
  String get cancel => 'إلغاء';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get decrease => 'إنقاص';

  @override
  String get increase => 'زيادة';

  @override
  String get setupTitle => 'لعبة جديدة';

  @override
  String get setupPlayersSection => 'اللاعبون (حسب الجلوس)';

  @override
  String playerCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString لاعب',
      many: '$countString لاعبًا',
      few: '$countString لاعبين',
      two: 'لاعبان',
      one: 'لاعب واحد',
      zero: 'لا لاعبين بعد',
    );
    return '$_temp0';
  }

  @override
  String get setupPlayerNameHint => 'اسم اللاعب';

  @override
  String get setupAddPlayer => 'إضافة لاعب';

  @override
  String get setupRemovePlayer => 'حذف';

  @override
  String get setupRolesSection => 'الأدوار';

  @override
  String get setupSuggestedMix => 'التوزيع المقترح';

  @override
  String get setupOptionsSection => 'الخيارات';

  @override
  String get setupRevealRole => 'كشف الدور عند الموت';

  @override
  String get timerOff => 'بدون';

  @override
  String minutes(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString دقيقة',
      many: '$countString دقيقة',
      few: '$countString دقائق',
      two: 'دقيقتان',
      one: 'دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get setupHouseRules => 'قواعد إضافية';

  @override
  String get tieNoElimination => 'لا إقصاء';

  @override
  String get tieHostDecides => 'المضيف يقرر';

  @override
  String get setupDealRoles => 'توزيع الأدوار';

  @override
  String setupProblemTooFewPlayers(int min) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minString = minNumberFormat.format(min);

    String _temp0 = intl.Intl.pluralLogic(
      min,
      locale: localeName,
      other: '$minString لاعب',
      many: '$minString لاعبًا',
      few: '$minString لاعبين',
      two: 'لاعبَين',
      one: 'لاعبًا واحدًا',
    );
    return 'أضف $_temp0 على الأقل.';
  }

  @override
  String get setupProblemDuplicateName => 'يوجد لاعبان بنفس الاسم.';

  @override
  String get setupProblemTooManyRoles => 'عدد الأدوار أكبر من عدد اللاعبين.';

  @override
  String get setupProblemNoMafia => 'أضف دورًا واحدًا على الأقل من المافيا.';

  @override
  String get setupProblemMafiaTooStrong => 'يجب أن يكون عدد المافيا أقل من فريق المواطنين.';

  @override
  String get dealTitle => 'وزّع البطاقات';

  @override
  String get dealInstructions =>
      'أعطِ كل لاعب البطاقة الظاهرة بجانب اسمه. لا تُظهر هذه الشاشة لأحد.';

  @override
  String get dealReshuffle => 'إعادة الخلط';

  @override
  String get dealStartGame => 'ابدأ الليلة الأولى';

  @override
  String get logTitle => 'سجل اللعبة';

  @override
  String get menuUndo => 'تراجع عن آخر خطوة';

  @override
  String get menuEndGame => 'إنهاء اللعبة';

  @override
  String get undoDone => 'تم التراجع عن آخر خطوة.';

  @override
  String get endGameConfirmTitle => 'إنهاء هذه اللعبة؟';

  @override
  String get endGameConfirmBody => 'سيتم إغلاق اللعبة ولن يمكن متابعتها.';

  @override
  String get nightIntro => 'الجميع، أغمضوا أعينكم.';

  @override
  String get nightBegin => 'ابدأ الليل';

  @override
  String nightStepCounter(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'الخطوة $currentString من $totalString';
  }

  @override
  String nightMafiaDecider(String name) {
    return 'القرار الأخير لـ$name';
  }

  @override
  String nightActor(String name) {
    return 'صاحب البطاقة: $name';
  }

  @override
  String get nightWakeLawyer => 'أيقظ المحامي. من يحمي؟';

  @override
  String get nightWakeMafia => 'أيقظ المافيا. من يقتلون؟';

  @override
  String get nightWakeJoker => 'أيقظ الجوكر. من يقتل؟';

  @override
  String get nightWakeDoctor => 'أيقظ الطبيب. من ينقذ؟';

  @override
  String get nightWakeDetective => 'أيقظ المحقق. من يفحص؟';

  @override
  String get nightNoAction => 'بلا فعل';

  @override
  String get nightDetectiveShow => 'أشِر للمحقق:';

  @override
  String get nightDetectiveBlocked => 'المحقق ممنوع الليلة — لا تعطه أي إجابة.';

  @override
  String get nightReviewTitle => 'الجميع نائمون. راجع أحداث الليل.';

  @override
  String reviewNoAction(String actor) {
    return '$actor: بلا فعل';
  }

  @override
  String get nightResolve => 'حسم الليل';

  @override
  String get resultMafia => 'مافيا';

  @override
  String get resultCivilian => 'مواطن';

  @override
  String actorWithRole(String name, String role) {
    return '$name ($role)';
  }

  @override
  String actionLawyerProtect(String actor, String target) {
    return '$actor حمى $target';
  }

  @override
  String actionMafiaKill(String actor, String target) {
    return '$actor اختار قتل $target';
  }

  @override
  String actionJokerKill(String actor, String target) {
    return '$actor اختار قتل $target';
  }

  @override
  String actionDoctorSave(String actor, String target) {
    return '$actor أنقذ $target';
  }

  @override
  String actionDetectiveCheck(String actor, String target) {
    return '$actor فحص $target';
  }

  @override
  String get announceNobodyDied => 'لم يمت أحد الليلة الماضية.';

  @override
  String announceKilled(String name) {
    return 'تم قتل $name.';
  }

  @override
  String announceVotedOut(String name) {
    return 'تم إقصاء $name بالتصويت.';
  }

  @override
  String announceBombVictim(String name) {
    return 'تم قتل $name بانفجار القنبلة.';
  }

  @override
  String announceCard(String role) {
    return 'البطاقة: $role.';
  }

  @override
  String announceBomb(String name) {
    return 'القنبلة هي $name!';
  }

  @override
  String get announceNoElimination => 'لم يتم إقصاء أحد.';

  @override
  String announceTie(String names) {
    return 'تعادل التصويت بين $names.';
  }

  @override
  String get winMafia => 'فازت المافيا!';

  @override
  String get winCivilians => 'فاز المواطنون!';

  @override
  String hostBlocked(String name) {
    return 'تم منع $name.';
  }

  @override
  String hostProtected(String name) {
    return 'تمت حماية $name من قِبل المحامي.';
  }

  @override
  String hostSaved(String name) {
    return 'أنقذ الطبيب $name.';
  }

  @override
  String hostDetective(String target, String result) {
    return 'نتيجة فحص المحقق لـ$target: $result';
  }

  @override
  String get morningStartDay => 'ابدأ النهار';

  @override
  String get timerStart => 'ابدأ';

  @override
  String get timerPause => 'إيقاف مؤقت';

  @override
  String get timerReset => 'إعادة';

  @override
  String get timerDone => 'انتهى الوقت!';

  @override
  String get dayVoteTitle => 'التصويت';

  @override
  String get dayVoteHint => 'افتح اسم اللاعب واضغط على كل من صوّت ضده.';

  @override
  String voteCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString صوت',
      many: '$countString صوتًا',
      few: '$countString أصوات',
      two: 'صوتان',
      one: 'صوت واحد',
      zero: 'لا أصوات',
    );
    return '$_temp0';
  }

  @override
  String get daySkipVote => 'بلا تصويت اليوم';

  @override
  String get dayCountVotes => 'احسب الأصوات';

  @override
  String dayStartNight(int round) {
    final intl.NumberFormat roundNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String roundString = roundNumberFormat.format(round);

    return 'ابدأ الليلة $roundString';
  }

  @override
  String get gameOverAllRoles => 'كل الأدوار';

  @override
  String get statusAlive => 'حي';

  @override
  String get statusDead => 'ميت';

  @override
  String get gameOverPlayAgain => 'لعبة جديدة';

  @override
  String get logEmpty => 'لم يحدث شيء بعد.';

  @override
  String get logNoActions => 'لا أفعال ليلية';

  @override
  String logVote(String voter, String target) {
    return '$voter صوّت ضد $target';
  }

  @override
  String logAbstain(String voter) {
    return '$voter لم يصوّت';
  }

  @override
  String get logNoVote => 'لم يُجرَ تصويت';

  @override
  String logTieBreak(String name) {
    return 'اختار المضيف $name';
  }

  @override
  String logBomb(String bomb, String victims) {
    return 'القنبلة ($bomb) أخذت معها: $victims';
  }

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String teamCount(String team, String count) {
    return '$team $count';
  }

  @override
  String get teamLabelMafia => 'فريق المافيا';

  @override
  String get teamLabelCivilians => 'فريق المدنيين';

  @override
  String get revealTapToReveal => 'اضغط للكشف';

  @override
  String get revealNoOneLooking => 'تأكد أن لا أحد ينظر';

  @override
  String get revealYourFamily => 'عائلتك';

  @override
  String get revealRole => 'اكشف الدور';

  @override
  String get hideRole => 'أخفِ الدور';

  @override
  String familyMember(String name, String role) {
    return '$name · $role';
  }

  @override
  String get abilityCivilian => 'لا قدرة لك في الليل. اكشف المافيا وصوّت لإخراجهم في النهار.';

  @override
  String get abilityJoker => 'تقتل لاعبًا كل ليلة. أنت مع المدنيين، لكن لا أحد في مأمن.';

  @override
  String get abilityLawyer => 'كل ليلة، احمِ أحد أفراد المافيا: يراه المحقق مدنيًا.';

  @override
  String get timeLeft => 'متبقٍ';

  @override
  String get statusEliminated => 'خرج';

  @override
  String get nightWakeTitleLawyer => 'أيقظ المحامي';

  @override
  String get nightWakeTitleMafia => 'أيقظ المافيا';

  @override
  String get nightWakeTitleJoker => 'أيقظ الجوكر';

  @override
  String get nightWakeTitleDoctor => 'أيقظ الطبيب';

  @override
  String get nightWakeTitleDetective => 'أيقظ المحقق';

  @override
  String get nightLineLawyer => 'أيها المحامي، افتح عينيك. من ستحمي الليلة؟';

  @override
  String get nightLineMafia => 'أيتها المافيا، افتحوا أعينكم. من يموت الليلة؟';

  @override
  String get nightLineJoker => 'أيها الجوكر، افتح عينيك. من ستقتل الليلة؟';

  @override
  String get nightLineDoctor => 'أيها الطبيب، افتح عينيك. من ستنقذ الليلة؟';

  @override
  String get nightLineDetective => 'أيها المحقق، افتح عينيك. من ستفحص الليلة؟';

  @override
  String hostOnlyDetective(String name, String result) {
    return 'للمضيف فقط: فحص المحقق $name ← $result';
  }

  @override
  String actionBlock(String name) {
    return 'تعطيل $name';
  }

  @override
  String actionProtect(String name) {
    return 'حماية $name';
  }

  @override
  String actionKill(String name) {
    return 'قتل $name';
  }

  @override
  String actionSave(String name) {
    return 'إنقاذ $name';
  }

  @override
  String actionCheck(String name) {
    return 'فحص $name';
  }

  @override
  String get nightPickToBlock => 'اختر لاعبًا لتعطيله';

  @override
  String get nightPickToProtect => 'اختر لاعبًا لحمايته';

  @override
  String get nightPickToKill => 'اختر لاعبًا لقتله';

  @override
  String get nightPickToSave => 'اختر لاعبًا لإنقاذه';

  @override
  String get nightPickToCheck => 'اختر لاعبًا لفحصه';

  @override
  String get nightBlockedShort => 'معطَّل الليلة: لا أثر لهذا الفعل.';

  @override
  String get setupShuffleDeal => 'اخلط ووزّع الأدوار';

  @override
  String get revealPassNext => 'أخفِ ومرّر للاعب التالي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String setupBalancedFor(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'متوازن لـ $countString';
  }

  @override
  String get setupProblemMafiaTooStrongShort => 'المافيا أقوى من اللازم';

  @override
  String get announceRoleSecret => 'يبقى الدور سرًّا حتى نهاية اللعبة';

  @override
  String announceBombTakes(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يأخذ معه $countString لاعبًا:',
      few: 'يأخذ معه $countString لاعبين:',
      two: 'يأخذ معه لاعبَين:',
      one: 'يأخذ معه لاعبًا واحدًا:',
    );
    return '$_temp0';
  }

  @override
  String get announceSomeoneSaved => 'أنقذ الطبيب أحدهم.';

  @override
  String get announceDontSayWho => 'لا تذكر من';

  @override
  String get statGames => 'ألعاب';

  @override
  String get statMafiaWins => 'فوز المافيا';

  @override
  String get statCivilianWins => 'فوز المدنيين';

  @override
  String percent(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString٪';
  }

  @override
  String get modeHostOnly => 'المضيف فقط · بطاقات';

  @override
  String get modePlayersPhones => 'هواتف اللاعبين';

  @override
  String logVotesFor(String name, int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString صوت',
      many: '$countString صوتًا',
      few: '$countString أصوات',
      two: 'صوتان',
      one: 'صوت واحد',
    );
    return '$name: $_temp0';
  }

  @override
  String announceWasBomb(String headline) {
    return '$headline وكان القنبلة.';
  }

  @override
  String bombWasTheBomb(String name) {
    return '$name كان القنبلة';
  }

  @override
  String chameleonBecome(String role) {
    return 'كن $role';
  }

  @override
  String get chameleonPickHint => 'اختر دورًا';

  @override
  String get comingSoon => 'قريبًا في تحديث قادم.';

  @override
  String countAlive(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString أحياء';
  }

  @override
  String countEliminated(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString خارج اللعبة';
  }

  @override
  String dayEliminate(String name) {
    return 'إخراج $name';
  }

  @override
  String dayOfVoters(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return ' من $countString صوّتوا';
  }

  @override
  String get dayResultTitle => 'قالت البلدة كلمتها.';

  @override
  String get dayStartVoting => 'ابدأ التصويت';

  @override
  String get dayTapToVote => 'اضغط على لاعب لإضافة صوت';

  @override
  String get dayTitle => 'من يكذب؟';

  @override
  String get dayUndoVote => 'تراجع عن آخر صوت';

  @override
  String get dayVoting => 'التصويت';

  @override
  String get detectiveBlockedTitle => 'المحقق معطَّل';

  @override
  String detectiveChecked(String name) {
    return 'فحص المحقق $name';
  }

  @override
  String get detectiveDone => 'تابع الليل';

  @override
  String get detectiveNoAnswer => 'لا إجابة';

  @override
  String get detectiveSignalHint => 'أشر بهذا للمحقق دون كلام.';

  @override
  String get gameOverBackHome => 'العودة للرئيسية';

  @override
  String gameOverSummary(int nights, int alive) {
    final intl.NumberFormat nightsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String nightsString = nightsNumberFormat.format(nights);
    final intl.NumberFormat aliveNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String aliveString = aliveNumberFormat.format(alive);

    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: 'بعد $nightsString ليلة',
      many: 'بعد $nightsString ليلة',
      few: 'بعد $nightsString ليالٍ',
      two: 'بعد ليلتين',
      one: 'بعد ليلة واحدة',
    );
    String _temp1 = intl.Intl.pluralLogic(
      alive,
      locale: localeName,
      other: '$aliveString ما زالوا صامدين',
      two: 'اثنان ما زالا صامدَين',
      one: 'واحد ما زال صامدًا',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String homeContinueAt(String stage) {
    return 'متابعة · $stage';
  }

  @override
  String get homeGreetingAfternoon => 'مساء الخير أيها المضيف';

  @override
  String get homeGreetingEvening => 'مساء الخير أيها المضيف';

  @override
  String get homeGreetingMorning => 'صباح الخير أيها المضيف';

  @override
  String homeHeroAlive(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ما زالوا أحياء';
  }

  @override
  String get homeHeroEmpty => 'أضف اللاعبين ووزّع البطاقات.';

  @override
  String get homeHeroInProgress => 'جارية';

  @override
  String homeHeroLastTable(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString لاعب من لعبتك الأخيرة',
      many: '$countString لاعبًا من لعبتك الأخيرة',
      few: '$countString لاعبين من لعبتك الأخيرة',
      two: 'لاعبان من لعبتك الأخيرة',
      one: 'لاعب واحد من لعبتك الأخيرة',
    );
    return '$_temp0';
  }

  @override
  String homeHeroReady(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString حول الطاولة';
  }

  @override
  String get homeHeroTag => 'الليلة';

  @override
  String get homeHeroTitle => 'طاولة الليلة';

  @override
  String get homeRecentEmpty => 'ستظهر الألعاب المنتهية هنا.';

  @override
  String get homeStartGame => 'ابدأ لعبة';

  @override
  String get homeTitle => 'المدينة نائمة.';

  @override
  String get homeYourTable => 'طاولتك';

  @override
  String get menuHome => 'الرئيسية';

  @override
  String get menuMore => 'المزيد';

  @override
  String get morningReadInOrder => 'اقرأها بالترتيب';

  @override
  String get morningTitle => 'البلدة تستيقظ.';

  @override
  String get navEvents => 'الفعاليات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPlayers => 'اللاعبون';

  @override
  String get nightContinueNoAction => 'التالي · بلا فعل';

  @override
  String get nightIntroHint => 'اقرأها بصوت عالٍ، ثم ابدأ حين تهدأ الطاولة.';

  @override
  String get nightPreviousStep => 'الخطوة السابقة';

  @override
  String get nightReviewHint => 'اضغط على خطوة لتعديلها.';

  @override
  String get recentCiviliansWon => 'فاز المدنيون';

  @override
  String recentDetail(int nights, int players) {
    final intl.NumberFormat nightsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String nightsString = nightsNumberFormat.format(nights);
    final intl.NumberFormat playersNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String playersString = playersNumberFormat.format(players);

    String _temp0 = intl.Intl.pluralLogic(
      players,
      locale: localeName,
      other: '$playersString لاعب',
      many: '$playersString لاعبًا',
      few: '$playersString لاعبين',
      two: 'لاعبان',
      one: 'لاعب واحد',
    );
    return 'الليلة $nightsString · $_temp0';
  }

  @override
  String get recentMafiaWon => 'فازت المافيا';

  @override
  String get revealDealing => 'توزيع الأدوار';

  @override
  String get revealHandTo => 'سلّم الهاتف إلى';

  @override
  String get revealHint => 'قرّب البطاقة منك ثم اضغط عليها';

  @override
  String revealProgress(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$currentString من $totalString';
  }

  @override
  String get setupAddPlayersHint => 'أضف اللاعبين حول الطاولة';

  @override
  String get setupAutoBalance => 'توازن تلقائي';

  @override
  String get setupPlayersAtTable => 'اللاعبون حول الطاولة';

  @override
  String get setupRolesHint => 'اضغط على دور لإضافته، واضغط مطولًا لإزالته.';

  @override
  String get statNone => '–';

  @override
  String get timerPaused => 'متوقف';

  @override
  String get eventsTitle => 'ليالي اللعب';

  @override
  String get eventsPast => 'ليالٍ سابقة';

  @override
  String get eventsEmpty => 'ستظهر ليالي اللعب هنا بعد انتهاء أول لعبة.';

  @override
  String get eventsPlanningSoon =>
      'التخطيط المسبق للّيالي وتأكيد الحضور يأتيان مع حسابات اللاعبين.';

  @override
  String eventsNightDetail(int games, int players) {
    final intl.NumberFormat gamesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String gamesString = gamesNumberFormat.format(games);
    final intl.NumberFormat playersNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String playersString = playersNumberFormat.format(players);

    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$gamesString لعبة',
      many: '$gamesString لعبة',
      few: '$gamesString ألعاب',
      two: 'لعبتان',
      one: 'لعبة واحدة',
    );
    String _temp1 = intl.Intl.pluralLogic(
      players,
      locale: localeName,
      other: '$playersString لاعب',
      many: '$playersString لاعبًا',
      few: '$playersString لاعبين',
      two: 'لاعبان',
      one: 'لاعب واحد',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get eventsGameNight => 'ليلة لعب';

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
      other: '$countString حول الطاولة',
      few: '$countString حول الطاولة',
      two: 'اثنان حول الطاولة',
      one: 'واحد حول الطاولة',
    );
    return '$_temp0';
  }

  @override
  String get eventsGamesPlayed => 'الألعاب';

  @override
  String get homeSeeStats => 'الإحصاءات';

  @override
  String get joinTitle => 'انضم إلى غرفة';

  @override
  String get joinIntro => 'أدخل الرمز الظاهر على هاتف المضيف لتلعب من هاتفك.';

  @override
  String get joinCodeHint => 'من 4 إلى 6 أحرف أو أرقام';

  @override
  String get joinScanQr => 'امسح رمز QR';

  @override
  String get joinCta => 'انضم';

  @override
  String get joinNotYet => 'اللعب من هواتف اللاعبين قادم في تحديث لاحق.';

  @override
  String get leaderboardTitle => 'المتصدرون';

  @override
  String get leaderboardSubtitle => 'الترتيب حسب الانتصارات في كل الألعاب المنتهية';

  @override
  String get leaderboardEmpty => 'أنهِ لعبة لتبدأ قائمة المتصدرين.';

  @override
  String leaderboardRowDetail(int games, int rate) {
    final intl.NumberFormat gamesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String gamesString = gamesNumberFormat.format(games);
    final intl.NumberFormat rateNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String rateString = rateNumberFormat.format(rate);

    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$gamesString لعبة',
      many: '$gamesString لعبة',
      few: '$gamesString ألعاب',
      two: 'لعبتان',
      one: 'لعبة واحدة',
    );
    return '$_temp0 · فوز $rateString٪';
  }

  @override
  String leaderboardWins(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString انتصار',
      many: '$countString انتصارًا',
      few: '$countString انتصارات',
      two: 'فوزان',
      one: 'فوز واحد',
      zero: 'بلا فوز',
    );
    return '$_temp0';
  }

  @override
  String get logFilterAll => 'الكل';

  @override
  String get logFilterKills => 'القتل';

  @override
  String get logFilterSaves => 'الإنقاذ';

  @override
  String get logFilterVotes => 'التصويت';

  @override
  String get logNothingHere => 'لا شيء من هذا النوع بعد.';

  @override
  String nightGodfatherConfirms(String name) {
    return 'العرّاب يؤكد: قتل $name';
  }

  @override
  String get nightMafiaProposalHint =>
      'اضغط مطولًا على لاعب لتسجيل اقتراح من المافيا، واضغط مرة لاختيار الضحية.';

  @override
  String get profileFavoriteRole => 'الدور المفضل';

  @override
  String profileLastPlayed(String date) {
    return 'آخر لعب $date';
  }

  @override
  String get profileNoGames => 'لا ألعاب منتهية بعد.';

  @override
  String get profileRoleHistory => 'سجل الأدوار';

  @override
  String get profileWinRate => 'نسبة الفوز';

  @override
  String get settingsDefaultsHint => 'تبدأ كل لعبة جديدة بهذه القيم، ويمكنك تغييرها لكل لعبة.';

  @override
  String get settingsDefaultsSection => 'إعدادات اللعبة الافتراضية';

  @override
  String get settingsFeedbackSection => 'الصوت واللمس';

  @override
  String get settingsHaptics => 'الاهتزاز';

  @override
  String get settingsHapticsSubtitle => 'اهتزاز خفيف عند الاختيار وقلب البطاقة وانتهاء الوقت';

  @override
  String get settingsDeviceShort => 'الجهاز';

  @override
  String get setupRolesHow => 'كيف يعرف اللاعبون أدوارهم';

  @override
  String get setupModePhone => 'تمرير الهاتف';

  @override
  String get setupModeCards => 'بطاقات ورقية';

  @override
  String get setupModePhoneHint => 'كل لاعب يلمس الهاتف ليرى دوره.';

  @override
  String get setupModeCardsHint => 'وزّع البطاقات، ثم حدّد من يحمل كل بطاقة في الليلة الأولى.';

  @override
  String get setupCardsDealt => 'وزّعتُ البطاقات';

  @override
  String get cardsOverline => 'الليلة الأولى · من يحمل أي بطاقة';

  @override
  String cardsWake(String role) {
    return 'يستيقظ $role';
  }

  @override
  String get cardsLine => 'من يحمل هذه البطاقة، فليفتح عينيه.';

  @override
  String cardsPicked(int picked, int total) {
    final intl.NumberFormat pickedNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String pickedString = pickedNumberFormat.format(picked);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'اختر من يحملها · $pickedString من $totalString';
  }

  @override
  String cardsNextRole(String role) {
    return 'التالي: $role';
  }

  @override
  String get cardsReviewStep => 'مراجعة';

  @override
  String get cardsReviewTitle => 'راجع البطاقات';

  @override
  String get cardsReviewHint => 'اضغط على أي بطاقة لتصحيحها. البقية يحملون بطاقة مواطن.';

  @override
  String get cardsReviewCheck => 'راجع البطاقات';

  @override
  String get rolePutana => 'بوتانا';

  @override
  String get roleWitch => 'ساحرة';

  @override
  String get roleSwitchman => 'محوِّل';

  @override
  String get roleSilencer => 'مُسكِت';

  @override
  String get roleShapeshifter => 'متحوِّل';

  @override
  String get roleTnt => 'تي إن تي';

  @override
  String get abilityPutana =>
      'الليلة الأولى: استيقظي مع المافيا لتعرفي فريقك. بعدها عطّلي قدرة لاعب كل ليلة. إن بقيتِ وحدك من فريق المافيا تقتلين كالمافيا.';

  @override
  String get abilityWitch =>
      'مرة واحدة في الليلة الثانية، اربطي روحَي مدنيَّين. إن قُتل أحدهما ليلًا مات الآخر معه. التصويت لا يُفعّل الرابط، ويبقى بعد موتك.';

  @override
  String get abilitySwitchman =>
      'إن حاول أحد قتلك ليلًا تستيقظ وترسل الرصاصة إلى لاعب تختاره. لا تموت ليلًا إلا إذا عطّلتك البوتانا تلك الليلة.';

  @override
  String get abilitySilencer =>
      'كل ليلة، أسكِت لاعبًا لليوم التالي: لا حديث حر، ولا كلمة، ولا تصويت.';

  @override
  String get abilityShapeshifter =>
      'تتغير قدرتك كل ليلة بالترتيب: محقق، ثم طبيب، ثم جوكر، ثم من جديد. تبقى دائمًا في فريق المدنيين.';

  @override
  String get abilityTnt => 'إن خرجت من اللعبة بأي طريقة، يخرج معك الجالسان على يمينك ويسارك.';

  @override
  String get abilityDoctor =>
      'أنقذ لاعبًا كل ليلة، ولو نفسك. يمكنك إنقاذ اللاعب نفسه ليلتين متتاليتين، لا ثلاثًا.';

  @override
  String get abilityDetective =>
      'افحص لاعبًا كل ليلة، وسيخبرك المضيف إن كان من المافيا. بعد ثلاث فحوص تكشف فيها اثنين من المافيا، يموت الاثنان معك إن قُتلت.';

  @override
  String get abilityBomb =>
      'بعد اليوم الأول، ازرع قنبلتين على لاعبَين. عندما تموت، ليلًا أو بالتصويت، يموتان معك. إن أُقصيت في اليوم الأول: خذ جارَيك معًا أو لا أحد.';

  @override
  String get abilityChameleon =>
      'في الليلة الثالثة، اختر: مافيا أو محقق أو طبيب أو جوكر أو محوِّل، واحتفظ بالدور حتى نهاية اللعبة.';

  @override
  String get abilityGodfather =>
      'لك الكلمة الأخيرة في من تقتله المافيا. إن أُقصيت بالتصويت يمكنك أخذ لاعب واحد معك.';

  @override
  String get abilityMafia =>
      'كل ليلة، أشِر على العرّاب بمن يموت. إن غاب، يجب أن يُظهر كل المافيا الرقم نفسه، وإلا لا يموت أحد.';

  @override
  String get nightWakeTitleRecognition => 'استيقظ يا فريق المافيا';

  @override
  String get nightLineRecognition =>
      'يا فريق المافيا، افتحوا أعينكم وتعرّفوا على بعضكم. وأنتِ أيضًا يا بوتانا.';

  @override
  String get nightRecognitionHint => 'في الليلة الأولى فقط. لا أحد يتصرف بعد.';

  @override
  String get nightRecognized => 'تعرّفوا على بعضهم';

  @override
  String get reviewRecognition => 'تعرّف فريق المافيا على بعضهم';

  @override
  String get nightWakeTitlePutana => 'أيقظ البوتانا';

  @override
  String get nightLinePutana => 'يا بوتانا، افتحي عينيك. قدرة من تعطّلين الليلة؟';

  @override
  String get nightWakeTitleWitch => 'أيقظ الساحرة';

  @override
  String get nightLineWitch => 'أيتها الساحرة، افتحي عينيك. أي روحين تربطين؟';

  @override
  String get nightWakeTitleSilencer => 'أيقظ المُسكِت';

  @override
  String get nightLineSilencer => 'أيها المُسكِت، افتح عينيك. من يصمت غدًا؟';

  @override
  String get nightWakeTitleShapeshifter => 'أيقظ المتحوِّل';

  @override
  String nightLineShapeshifter(String role) {
    return 'أيها المتحوِّل، افتح عينيك. أنت الليلة $role.';
  }

  @override
  String get nightWakeTitleBomb => 'أيقظ القنبلة';

  @override
  String get nightLineBomb => 'أيتها القنبلة، افتحي عينيك. على من تزرعين القنبلتين؟';

  @override
  String get nightWakeTitleChameleon => 'أيقظ الحرباء';

  @override
  String get nightLineChameleonChoose =>
      'أيتها الحرباء، افتحي عينيك. مافيا أم محقق أم طبيب أم جوكر أم محوِّل: أيها تحتفظين به حتى النهاية؟';

  @override
  String nightLineChameleonAs(String role) {
    return 'أيتها الحرباء، افتحي عينيك. أنتِ تلعبين دور $role.';
  }

  @override
  String get nightWakeTitleSwitchman => 'أيقظ المحوِّل';

  @override
  String get nightLineSwitchman =>
      'أيها المحوِّل، افتح عينيك. أطلق أحدهم عليك النار. من يتلقى الرصاصة؟';

  @override
  String nightLineSwitchmanBullet(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'أيها المحوِّل، افتح عينيك. الرصاصة $currentString من $totalString: من يتلقاها؟';
  }

  @override
  String get nightBlockedWarning =>
      'معطَّل من البوتانا الليلة: لن يكون لهذا الفعل أي أثر. دعه يختار على أي حال.';

  @override
  String nightBlockedDecider(String name) {
    return 'عطّلت البوتانا $name: الليلة يُحسب رقم بقية المافيا.';
  }

  @override
  String get nightDoctorTwoNights => 'أُنقذ ليلتين متتاليتين';

  @override
  String get nightMafiaTalk => 'نقاش المافيا';

  @override
  String get nightMafiaTalkHint => 'يتفقون على ضحية، والقرار للعرّاب.';

  @override
  String get nightMafiaMustAgree =>
      'لا عرّاب: يجب أن يُظهر كل المافيا الرقم نفسه. الأرقام المختلفة تلغي القتل.';

  @override
  String get nightMafiaNoMatch => 'الأرقام لم تتطابق';

  @override
  String get nightPickToSilence => 'اختر لاعبًا لإسكاته';

  @override
  String get nightPickTwoToLink => 'اختر لاعبَين لربطهما';

  @override
  String get nightPickTwoToPlant => 'اختر لاعبَين للقنبلتين';

  @override
  String get nightPickToRedirect => 'اختر من يتلقى الرصاصة';

  @override
  String actionLink(String first, String second) {
    return 'ربط $first و$second';
  }

  @override
  String actionPlant(String first, String second) {
    return 'زرع على $first و$second';
  }

  @override
  String actionSilenceShort(String name) {
    return 'إسكات $name';
  }

  @override
  String actionRedirectTo(String name) {
    return 'أرسلها إلى $name';
  }

  @override
  String actionPutanaBlock(String actor, String target) {
    return '$actor عطّل $target';
  }

  @override
  String actionSilence(String actor, String target) {
    return '$actor أسكت $target';
  }

  @override
  String actionRedirect(String actor, String target) {
    return '$actor أرسل الرصاصة إلى $target';
  }

  @override
  String actionWitchLink(String actor, String first, String second) {
    return '$actor ربط $first و$second';
  }

  @override
  String actionBombPlant(String actor, String first, String second) {
    return '$actor زرع قنبلتين على $first و$second';
  }

  @override
  String actionChameleonChoose(String actor, String role) {
    return '$actor اختار دور $role';
  }

  @override
  String hostLinked(String first, String second) {
    return 'ربطت الساحرة $first و$second.';
  }

  @override
  String hostBombPlanted(String bomb, String first, String second) {
    return '$bomb (القنبلة) زرع على $first و$second.';
  }

  @override
  String hostChameleonChose(String name, String role) {
    return '$name (الحرباء) أصبح $role.';
  }

  @override
  String get hostMafiaCancelled => 'أظهرت المافيا أرقامًا مختلفة: لا قتل.';

  @override
  String hostRedirected(String switchman, String target) {
    return '$switchman (المحوِّل) أرسل رصاصة إلى $target.';
  }

  @override
  String hostDodged(String name) {
    return 'أُطلق النار على $name (المحوِّل) ونجا.';
  }

  @override
  String hostChainArmed(String detective, String names) {
    return '$detective (المحقق) كشف $names: يموتان معه.';
  }

  @override
  String hostPutanaPromoted(String name) {
    return '$name (البوتانا) آخر فريق المافيا وأصبحت تقتل.';
  }

  @override
  String announceRemoved(String name) {
    return 'تم إخراج $name من الطاولة.';
  }

  @override
  String announceTntVictim(String name) {
    return 'سقط $name في انفجار التي إن تي.';
  }

  @override
  String announceGodfatherVictim(String name) {
    return 'أخذ العرّاب $name معه.';
  }

  @override
  String announceWasTnt(String headline) {
    return '$headline وكان التي إن تي.';
  }

  @override
  String announceSilenced(String name) {
    return '$name مُسكَت اليوم.';
  }

  @override
  String get announceSilencedRule => 'لا حديث حر، ولا كلمة، ولا تصويت';

  @override
  String get announceGodfatherChoosing => 'يمكنه أخذ لاعب واحد معه: اختر الآن.';

  @override
  String get announceBombNeighborsChoosing => 'يذهب معه جاراه معًا أو لا أحد: اختر الآن.';

  @override
  String choiceWasGodfather(String name) {
    return '$name كان العرّاب';
  }

  @override
  String get choiceGodfatherHint => 'بعد إقصائه يمكنه أخذ لاعب واحد معه، أو لا أحد.';

  @override
  String get choiceBombNeighborsHint =>
      'أُقصي قبل زرع القنبلتين: يأخذ الجالسَين بجانبه معًا، أو لا أحد.';

  @override
  String choiceTake(String names) {
    return 'خذ $names';
  }

  @override
  String get choiceTakeNoOne => 'لا أحد';

  @override
  String get dayFreeChat => 'حديث حر';

  @override
  String get dayFreeChatHint => 'يتحدث الجميع ويتّهمون ويدافعون.';

  @override
  String get daySpeeches => 'الكلمات';

  @override
  String get daySpeech => 'الكلمة';

  @override
  String get dayFoul => 'فاول';

  @override
  String get dayStartSpeeches => 'ابدأ الكلمات';

  @override
  String daySpeechCounter(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'الكلمة $currentString من $totalString';
  }

  @override
  String get daySpeechHint => 'وقته الخاص. لا يرد أحد حتى ينتهي.';

  @override
  String get dayOnFoul => 'على فاول: كلمة إضافية';

  @override
  String dayTakeFoul(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'فاول +$secondsString ث';
  }

  @override
  String get daySpeechOrder => 'ترتيب الكلام (حسب المقاعد)';

  @override
  String dayNextSpeaker(String name) {
    return 'التالي: $name';
  }

  @override
  String get dayPreviousSpeaker => 'المتحدث السابق';

  @override
  String get dayNoSpeakers => 'لا أحد يتحدث اليوم.';

  @override
  String daySilencedToday(String names) {
    return 'مُسكَتون اليوم: $names';
  }

  @override
  String daySilencedNoVote(String names) {
    return 'مُسكَتون لا يصوّتون: $names';
  }

  @override
  String dayTieRevote(String names) {
    return 'تعادل بين $names. أعيدوا التصويت بينهم.';
  }

  @override
  String dayTieHostDecides(String names) {
    return 'تعادل مجددًا بين $names. من يخرج؟';
  }

  @override
  String dayTieDrawLots(String names) {
    return 'تعادل مجددًا بين $names. اسحبوا القرعة.';
  }

  @override
  String get dayDrawLots => 'اسحب القرعة';

  @override
  String get statusSilenced => 'مُسكَت';

  @override
  String statusFouls(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString فاول',
      many: '$countString فاولًا',
      few: '$countString فاولات',
      two: 'فاولان',
      one: 'فاول واحد',
      zero: 'لا فاولات',
    );
    return '$_temp0';
  }

  @override
  String logChoice(String name, String victims) {
    return '$name أخذ $victims';
  }

  @override
  String logChoiceNone(String name) {
    return '$name لم يأخذ أحدًا';
  }

  @override
  String logFoul(String name) {
    return '$name أخذ فاول';
  }

  @override
  String get menuRemovePlayer => 'إخراج لاعب';

  @override
  String get removePlayerHint =>
      'لمن يخالف قواعد الطاولة مرارًا. يخرج من اللعبة، والتي إن تي ينفجر رغم ذلك.';

  @override
  String removePlayerConfirmTitle(String name) {
    return 'إخراج $name؟';
  }

  @override
  String get removePlayerConfirmBody => 'سيخرج من اللعبة نهائيًا. يمكنك التراجع من القائمة.';

  @override
  String get removePlayerConfirm => 'إخراج';

  @override
  String get setupSeatOrderHint =>
      'ترتيب المقاعد مهم: القائمة تدور حول الطاولة، وآخر لاعب يجلس بجانب الأول.';

  @override
  String get setupSeatOrderSheetHint =>
      'أضف اللاعبين بترتيب جلوسهم حول الطاولة. اسحب لتعديل الترتيب.';

  @override
  String get setupTimers => 'المؤقتات';

  @override
  String get setupTimersHint => 'اضغط على المؤقت أثناء اللعب لتشغيله';

  @override
  String minutesShort(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString:٠٠';
  }

  @override
  String secondsShort(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ث';
  }

  @override
  String get setupHouseRulesHint => 'المسائل المفتوحة في القواعد';

  @override
  String get setupHouseRulesSheetHint => 'الدليل يترك هذه مفتوحة. الافتراضي يتبع ملف قواعد اللعبة.';

  @override
  String get ruleGodfatherAppearsCivilian => 'المحقق يرى العرّاب مدنيًا';

  @override
  String get rulePutanaCanBlockMafia => 'البوتانا تستطيع تعطيل فريق المافيا';

  @override
  String get ruleChameleonMafiaJoins => 'الحرباء المافيا تنضم لفريق المافيا';

  @override
  String get ruleDetectiveChainOnVote => 'سلسلة المحقق عند الإقصاء أيضًا';

  @override
  String get ruleBlockedChecksCount => 'الفحص المعطَّل يُحسب من الثلاثة';

  @override
  String get ruleDoctorBlocksChainDeaths => 'الطبيب ينقذ من موت السلسلة';

  @override
  String get ruleSwitchmanRedirectsEach => 'المحوِّل يحوّل كل رصاصة';

  @override
  String get ruleDoctorSavesRedirected => 'الطبيب ينقذ من الرصاصة المحوَّلة';

  @override
  String get ruleBombNoEffectBeforePlant => 'القنبلة المقتولة في الليلة الأولى بلا أثر';

  @override
  String get ruleSilenceLastsNextDay => 'الإسكات لليوم التالي فقط';

  @override
  String get ruleWitchCiviliansOnly => 'الساحرة تربط المدنيين فقط';

  @override
  String get ruleMafiaWinsAtParity => 'تفوز المافيا عند تساويها مع المدنيين';

  @override
  String get ruleSecondTie => 'إذا تعادلت إعادة التصويت';

  @override
  String get tieRandom => 'قرعة';

  @override
  String hostOnlyCheckBy(String checker, String name, String result) {
    return 'للمضيف فقط: فحص $checker $name ← $result';
  }
}
