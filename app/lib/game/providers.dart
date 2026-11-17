import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../data/database.dart';
import '../data/game_repository.dart';
import 'game_input.dart';
import 'game_session.dart';
import 'role_mix.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final gameRepositoryProvider = Provider((ref) => GameRepository(ref.watch(databaseProvider)));

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
  const AppPreferences({this.locale, this.themeMode = ThemeMode.system, this.soundEnabled = true});

  /// Null follows the device language.
  final Locale? locale;
  final ThemeMode themeMode;

  /// Night and morning sound cues.
  final bool soundEnabled;
}

final preferencesProvider = AsyncNotifierProvider<PreferencesController, AppPreferences>(
  PreferencesController.new,
);

class PreferencesController extends AsyncNotifier<AppPreferences> {
  static const _localeKey = 'locale';
  static const _themeKey = 'themeMode';
  static const _soundKey = 'soundEnabled';

  GameRepository get _repo => ref.read(gameRepositoryProvider);

  @override
  Future<AppPreferences> build() async {
    final repo = ref.watch(gameRepositoryProvider);
    final locale = await repo.preference(_localeKey);
    final theme = await repo.preference(_themeKey);
    final sound = await repo.preference(_soundKey);
    return AppPreferences(
      locale: locale == null ? null : Locale(locale),
      themeMode: ThemeMode.values.asNameMap()[theme] ?? ThemeMode.system,
      soundEnabled: sound != 'false',
    );
  }

  Future<void> setLocale(Locale? locale) async {
    final c = _current;
    state = AsyncData(
      AppPreferences(locale: locale, themeMode: c.themeMode, soundEnabled: c.soundEnabled),
    );
    await _repo.setPreference(_localeKey, locale?.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final c = _current;
    state = AsyncData(
      AppPreferences(locale: c.locale, themeMode: mode, soundEnabled: c.soundEnabled),
    );
    await _repo.setPreference(_themeKey, mode.name);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final c = _current;
    state = AsyncData(
      AppPreferences(locale: c.locale, themeMode: c.themeMode, soundEnabled: enabled),
    );
    await _repo.setPreference(_soundKey, '$enabled');
  }

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
    this.discussionSeconds = 0,
  });

  final List<String> names;
  final Map<Role, int> mix;

  /// True once the host edits the mix; until then it follows the suggestion.
  final bool customMix;
  final GameSettings settings;
  final int discussionSeconds;

  int countOf(Role role) => mix[role] ?? 0;
  int get civilianCount => names.length - mix.values.fold(0, (a, b) => a + b);
  SetupProblem? get problem => validateSetup(names, mix);

  SetupDraft copyWith({
    List<String>? names,
    Map<Role, int>? mix,
    bool? customMix,
    GameSettings? settings,
    int? discussionSeconds,
  }) => SetupDraft(
    names: names ?? this.names,
    mix: mix ?? this.mix,
    customMix: customMix ?? this.customMix,
    settings: settings ?? this.settings,
    discussionSeconds: discussionSeconds ?? this.discussionSeconds,
  );
}

final setupDraftProvider = NotifierProvider<SetupController, SetupDraft>(SetupController.new);

class SetupController extends Notifier<SetupDraft> {
  @override
  SetupDraft build() => SetupDraft(mix: suggestedRoleMix(0));

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

  int maxCount(Role role) => role == Role.godfather ? 1 : state.names.length;

  void useSuggestedMix() =>
      state = state.copyWith(mix: suggestedRoleMix(state.names.length), customMix: false);

  void updateSettings(GameSettings settings) => state = state.copyWith(settings: settings);

  void setDiscussionSeconds(int seconds) => state = state.copyWith(discussionSeconds: seconds);

  void _setNames(List<String> names) {
    state = state.copyWith(
      names: names,
      mix: state.customMix ? state.mix : suggestedRoleMix(names.length),
    );
  }
}
