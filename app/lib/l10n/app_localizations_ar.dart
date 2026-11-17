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
  String get rolePotana => 'بوتانا';

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
  String get setupBombVictims => 'ضحايا القنبلة';

  @override
  String get setupRevealRole => 'كشف الدور عند الموت';

  @override
  String get setupDiscussionTimer => 'مؤقت النقاش';

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
      few: '$countString دقائق',
      two: 'دقيقتان',
      one: 'دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get setupHouseRules => 'قواعد إضافية';

  @override
  String get ruleDoctorSaveBlocksJoker => 'إنقاذ الطبيب يحمي من الجوكر أيضًا';

  @override
  String get ruleDoctorCanSaveBombVictims => 'يمكن للطبيب إنقاذ ضحايا القنبلة';

  @override
  String get ruleBlockedBombExplodes => 'القنبلة الممنوعة تنفجر رغم ذلك';

  @override
  String get ruleChameleonMafia => 'يمكن للحرباء اختيار أدوار المافيا';

  @override
  String get ruleTieVote => 'عند تعادل الأصوات';

  @override
  String get tieRevote => 'إعادة التصويت';

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

    return 'أضف $minString لاعبين على الأقل.';
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
  String get dealChameleonPlaysAs => 'دور الحرباء';

  @override
  String get dealChameleonMissing => 'يجب أن تختار كل حرباء دورًا.';

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
  String get nightWakePotana => 'أيقظ البوتانا. من يمنع؟';

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
  String get nightBlockedWarning =>
      'ممنوع من البوتانا الليلة — لن يكون لهذا الفعل أي أثر. دعه يختار على أي حال.';

  @override
  String get nightDoctorLastNight => 'تم إنقاذه الليلة الماضية';

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
  String actionPotanaBlock(String actor, String target) {
    return '$actor منع $target';
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
  String hostBombDefused(String name) {
    return 'القنبلة ($name) كانت ممنوعة ولم تنفجر.';
  }

  @override
  String bombPick(String name, int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString لاعب',
      many: '$countString لاعبًا',
      few: '$countString لاعبين',
      two: 'لاعبَين',
      one: 'لاعبًا واحدًا',
    );
    return 'القنبلة هي $name. اختر $_temp0 للموت معها.';
  }

  @override
  String bombDetonate(String selected, String required) {
    return 'تفجير ($selected/$required)';
  }

  @override
  String get morningStartDay => 'ابدأ النهار';

  @override
  String get dayDiscussion => 'النقاش';

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
  String dayTieHostDecides(String names) {
    return 'تعادل بين $names. من يخرج؟';
  }

  @override
  String dayTieRevote(String names) {
    return 'تعادل بين $names. أعيدوا التصويت.';
  }

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
}
