# Mafia Host (app)

Flutter app for hosting Mafia with physical cards on one phone, fully offline.
Game rules live in `../packages/mafia_engine`; this app only collects the host's
input and shows results.

## Run

```sh
flutter pub get
flutter run            # iOS simulator or Android emulator
flutter test
```

After changing `lib/data/database.dart`, regenerate Drift code:

```sh
dart run build_runner build
```

Translations live in `lib/l10n/app_en.arb` (template) and `app_ar.arb`;
`flutter gen-l10n` (or any build) regenerates `app_localizations*.dart`.

## How a game is stored

A game is its setup (players, roles, settings) plus the ordered list of host
inputs (night actions, votes, Bomb victims, "next" taps) in `GameInputs`.
`GameSession.replay` feeds them through the engine to rebuild the exact state
and the game log. This is what makes **Continue game** after a restart and
**Undo last step** work.

## Layout

```
lib/
  game/           session (replay, stages), codec, role mix, providers, flow screen
  data/           Drift database + repository
  common/         l10n helpers, event → sentence text, shared widgets
  features/
    home/ settings/ setup/ night/ morning/ day/ game_log/ game_over/
  l10n/           ARB files + generated localizations
```
