# Mafia Host App

Mobile app (iOS + Android) that helps a Mafia party-game host run games and organize game nights.
Full spec: https://claude.ai/artifact/S6NEFiZMKb8wGVu5cGVtzX

## Current phase: Phase 1
1. Game engine (pure Dart, fully unit tested)
2. Host-only mode (one phone, physical cards, offline) — **UI must match the approved design (see Design below)**
3. Arabic + English with full RTL

## Design (approved — follow exactly)
- Spec: `docs/design/DESIGN.md` — components, screens, new-screen guidance, motion
- Mockups: `docs/design/mockups/*.dc.html` — HTML with inline styles; read them for exact sizes, colors, copy
- Tokens: `app/lib/theme/app_theme.dart` — the ONLY source of colors, fonts, spacing, radii, durations
- Build `app/lib/ui/` components first, then screens from them. No screen uses raw Material widgets for its look.
- Packages: flutter_riverpod, go_router, google_fonts, flutter_animate, lucide_icons, flutter_localizations, intl

Later: Phase 2 = events, player profiles, stats (Supabase). Phase 3 = players' phones mode (Supabase Realtime).

## Tech
- Flutter (stable), Dart 3, null safety
- State: Riverpod
- Local storage: Drift (SQLite)
- Localization: `flutter_localizations` + ARB files in `lib/l10n/` (`app_en.arb`, `app_ar.arb`)
- Tests: `flutter test`; engine coverage target 90%+

## Structure
```
packages/
  mafia_engine/        # pure Dart, NO Flutter imports
    lib/src/roles.dart
    lib/src/game_state.dart
    lib/src/night_resolver.dart
    lib/src/day_resolver.dart
    lib/src/win_checker.dart
    test/
app/                   # Flutter app, depends on mafia_engine
  lib/features/setup/
  lib/features/night/
  lib/features/morning/
  lib/features/day/
  lib/features/game_log/
  lib/l10n/
```

## Roles
| Role | Team | Ability |
|---|---|---|
| Civilian | Civilians | No power, votes by day |
| Doctor | Civilians | Saves 1 player per night. May save himself. Cannot save the same player two nights in a row |
| Detective | Civilians | Checks 1 player per night → Mafia / Civilian |
| Bomb | Civilians | On death (night OR day vote) picks N victims who die immediately. N = 2 or 3, host sets at setup |
| Joker | Civilians | Kills 1 player every night. No penalty for killing civilians |
| Chameleon | Civilians | Picks one role at game start, plays it all game |
| Mafia | Mafia | Proposes the night kill |
| Godfather | Mafia | Final say on the Mafia kill. Detective sees him as Civilian |
| Potana | Mafia | Blocks 1 civilian-team player's power for the night (civilian roles only) |
| Lawyer | Mafia | Protects 1 Mafia member per night: Detective sees them as Civilian |

## Night resolution (collect all actions, then resolve in this order)
1. Potana block → blocked player's action has no effect
2. Lawyer protection
3. Mafia kill (Godfather decides; if dead, remaining Mafia decide)
4. Joker kill (unless blocked)
5. Doctor save (unless blocked)
6. Detective check (unless blocked); Godfather + Lawyer-protected → "Civilian"
7. Deaths applied → Bomb trigger if Bomb died
8. Win check → morning announcement

## Unconfirmed rules — implement as GameSettings flags, never hard-code
- `doctorSaveBlocksJokerKill` (default true)
- `doctorCanSaveBombVictims` (default false)
- `blockedBombStillExplodes` (default true)
- `chameleonCanPickMafiaRoles` (default false)
- `revealRoleOnDeath` (default false)
- `tieVoteRule`: revote | noElimination | hostDecides (default hostDecides)
- Win: Civilians win when no Mafia left; Mafia win when Mafia >= civilian team alive

## UI rules
- Dark only. Night screens use `AppTheme.night`, Morning/Day use `AppTheme.day`, switched with `AnimatedTheme`
- Never `Colors.*`, hex literals, raw font sizes or `EdgeInsets.only(left/right)` in widgets
- One primary action per screen, bottom-anchored, 60 px
- Every screen ships with golden tests in `en` and `ar`

## Conventions
- Engine is deterministic and immutable: `GameState resolveNight(GameState, List<NightAction>)` returns a new state + list of `GameEvent`s
- Every rule change gets a unit test first
- No user-facing strings in code; all text via ARB keys
- Use `EdgeInsetsDirectional` / `AlignmentDirectional` so RTL mirrors correctly
- Commit after each working step with a clear message
