import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../data/database.dart';
import '../data/game_repository.dart';
import 'game_input.dart';
import 'game_session.dart';
import 'role_mix.dart';

/// The current time. Overridden in goldens so time-of-day copy is stable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final gameRepositoryProvider = Provider((ref) => GameRepository(ref.watch(databaseProvider)));

/// Home "Your table" totals; refreshed whenever the active game changes.
final tableStatsProvider = FutureProvider<TableStats>((ref) {
  ref.watch(activeGameProvider);
  return ref.watch(gameRepositoryProvider).tableStats();
});

/// Leaderboard / player profiles.
final playerRecordsProvider = FutureProvider<List<PlayerRecord>>((ref) {
  ref.watch(activeGameProvider);
  return ref.watch(gameRepositoryProvider).playerRecords();
});

/// Past game nights (Events).
final gameNightsProvider = FutureProvider<List<GameNight>>((ref) {
  ref.watch(activeGameProvider);
  return ref.watch(gameRepositoryProvider).gameNights();
});

/// Names from the last game (Home hero card).
final lastPlayerNamesProvider = FutureProvider<List<String>>((ref) {
  ref.watch(activeGameProvider);
  return ref.watch(gameRepositoryProvider).lastPlayerNames();
});

final recentGamesProvider = FutureProvider<List<GameSummary>>((ref) {
  ref.watch(activeGameProvider);
  return ref.watch(gameRepositoryProvider).recentGames();
});

/// The game in progress (null when none). Every change is saved immediately,
/// so the host can close the app mid-game and continue later.
final activeGameProvider = AsyncNotifierProvider<ActiveGameController, GameSession?>(
  ActiveGameController.new,
);

class ActiveGameController extends AsyncNotifier<GameSession?> {
  GameRepository get _repo => ref.read(gameRepositoryProvider);

  @override
  Future<GameSession?> build() => ref.watch(gameRepositoryProvider).loadActiveGame();

  Future<void> start(GameSetup setup) async {
    final id = await _repo.createGame(setup);
    state = AsyncData(GameSession.start(id, setup));
  }

  /// Throws [InvalidActionException] if the engine rejects the input.
  Future<void> apply(GameInput input) => _update(state.requireValue!.apply(input));

  Future<void> undo() => _update(state.requireValue!.undo());

  Future<void> abandon() async {
    final session = state.value;
    if (session != null) await _repo.abandon(session.gameId);
    state = const AsyncData(null);
  }

  /// Leaves a finished game (it stays stored as finished).
  void close() => state = const AsyncData(null);

  Future<void> _update(GameSession next) async {
    state = AsyncData(next);
    await _repo.save(next);
  }
}

// ---------------------------------------------------------------------------
// App preferences

@immutable
class AppPreferences {
  const AppPreferences({
    this.locale,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.defaultRevealRole = false,
    this.cardsMode = false,
  });

  /// Null follows the device language.
  final Locale? locale;

  /// Night and morning sound cues.
  final bool soundEnabled;

  /// Taps, card flips and the timer buzz.
  final bool hapticsEnabled;

  /// Starting value for a new game's setup.
  final bool defaultRevealRole;

  /// Physical cards: the host records who holds each card on night 1
  /// instead of passing the phone around. Remembered from the last setup.
  final bool cardsMode;

  AppPreferences copyWith({
    Locale? Function()? locale,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? defaultRevealRole,
    bool? cardsMode,
  }) => AppPreferences(
    locale: locale == null ? this.locale : locale(),
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    defaultRevealRole: defaultRevealRole ?? this.defaultRevealRole,
    cardsMode: cardsMode ?? this.cardsMode,
  );
}

final preferencesProvider = AsyncNotifierProvider<PreferencesController, AppPreferences>(
  PreferencesController.new,
);

class PreferencesController extends AsyncNotifier<AppPreferences> {
  static const _localeKey = 'locale';
  static const _soundKey = 'soundEnabled';
  static const _hapticsKey = 'hapticsEnabled';
  static const _revealKey = 'defaultRevealRole';
  static const _cardsKey = 'cardsMode';

  GameRepository get _repo => ref.read(gameRepositoryProvider);

  @override
  Future<AppPreferences> build() async {
    final repo = ref.watch(gameRepositoryProvider);
    final locale = await repo.preference(_localeKey);
    return AppPreferences(
      locale: locale == null ? null : Locale(locale),
      soundEnabled: await repo.preference(_soundKey) != 'false',
      hapticsEnabled: await repo.preference(_hapticsKey) != 'false',
      defaultRevealRole: await repo.preference(_revealKey) == 'true',
      cardsMode: await repo.preference(_cardsKey) == 'true',
    );
  }

  Future<void> _set(AppPreferences next, String key, String? value) async {
    state = AsyncData(next);
    await _repo.setPreference(key, value);
  }

  Future<void> setLocale(Locale? locale) =>
      _set(_current.copyWith(locale: () => locale), _localeKey, locale?.languageCode);

  Future<void> setSoundEnabled(bool on) =>
      _set(_current.copyWith(soundEnabled: on), _soundKey, '$on');

  Future<void> setHapticsEnabled(bool on) =>
      _set(_current.copyWith(hapticsEnabled: on), _hapticsKey, '$on');

  Future<void> setDefaultRevealRole(bool on) =>
      _set(_current.copyWith(defaultRevealRole: on), _revealKey, '$on');

  Future<void> setCardsMode(bool on) => _set(_current.copyWith(cardsMode: on), _cardsKey, '$on');

  AppPreferences get _current => state.value ?? const AppPreferences();
}

// ---------------------------------------------------------------------------
// New game setup draft (kept while the host goes back and forth to the deal)

@immutable
class SetupDraft {
  const SetupDraft({
    this.names = const [],
    this.mix = const {},
    this.customMix = false,
    this.settings = const GameSettings(),
    this.cardsMode = false,
  });

  final List<String> names;
  final Map<Role, int> mix;

  /// True once the host edits the mix; until then it follows the suggestion.
  final bool customMix;
  final GameSettings settings;

  /// Physical cards (see [AppPreferences.cardsMode]).
  final bool cardsMode;

  int countOf(Role role) => mix[role] ?? 0;
  int get civilianCount => names.length - mix.values.fold(0, (a, b) => a + b);
  SetupProblem? get problem => validateSetup(names, mix);

  SetupDraft copyWith({
    List<String>? names,
    Map<Role, int>? mix,
    bool? customMix,
    GameSettings? settings,
    bool? cardsMode,
  }) => SetupDraft(
    names: names ?? this.names,
    mix: mix ?? this.mix,
    customMix: customMix ?? this.customMix,
    settings: settings ?? this.settings,
    cardsMode: cardsMode ?? this.cardsMode,
  );
}

final setupDraftProvider = NotifierProvider<SetupController, SetupDraft>(SetupController.new);

class SetupController extends Notifier<SetupDraft> {
  @override
  SetupDraft build() {
    final prefs = ref.read(preferencesProvider).value ?? const AppPreferences();
    return SetupDraft(
      mix: suggestedRoleMix(0),
      settings: GameSettings(revealRoleOnDeath: prefs.defaultRevealRole),
      cardsMode: prefs.cardsMode,
    );
  }

  /// Fills in last game's players if the list is still empty.
  Future<void> prefillNames() async {
    if (state.names.isNotEmpty) return;
    final names = await ref.read(gameRepositoryProvider).lastPlayerNames();
    if (names.isNotEmpty && state.names.isEmpty) _setNames(names);
  }

  /// Returns false if the name is empty or already taken.
  bool addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (state.names.any((n) => n.toLowerCase() == trimmed.toLowerCase())) return false;
    _setNames([...state.names, trimmed]);
    return true;
  }

  void removePlayer(int index) => _setNames([...state.names]..removeAt(index));

  /// [newIndex] is the position after removing the item at [oldIndex].
  void reorder(int oldIndex, int newIndex) {
    final names = [...state.names];
    final name = names.removeAt(oldIndex);
    names.insert(newIndex, name);
    state = state.copyWith(names: names);
  }

  void setRoleCount(Role role, int count) {
    state = state.copyWith(
      mix: {...state.mix, role: count.clamp(0, maxCount(role))},
      customMix: true,
    );
  }

  int maxCount(Role role) => maxRoleCount(role, state.names.length);

  void useSuggestedMix() =>
      state = state.copyWith(mix: suggestedRoleMix(state.names.length), customMix: false);

  void updateSettings(GameSettings settings) => state = state.copyWith(settings: settings);

  /// Also remembered as the default for the next game.
  void setCardsMode(bool on) {
    state = state.copyWith(cardsMode: on);
    ref.read(preferencesProvider.notifier).setCardsMode(on);
  }

  void _setNames(List<String> names) {
    state = state.copyWith(
      names: names,
      mix: state.customMix ? state.mix : suggestedRoleMix(names.length),
    );
  }
}
