# Mafia Host — UI Design Spec

Approved concept: https://claude.ai/artifact/CRhCUYTZYkKQJutv1diSo8
Reference mockups: `docs/design/mockups/*.dc.html`. They are HTML with inline styles: open one to read the exact
spacing, sizes, colors and copy of a screen. Match them; do not invent a different look.
Tokens: `lib/theme/app_theme.dart` (colors, type, spacing, radii, motion). Never hard-code a value that exists there.

## Visual language

- **Noir, two worlds.** Night screens use `MafiaColors.night` (ink black, moon-blue glow). Morning and Day screens use
  `MafiaColors.day` (warm brown-black, amber sun). Switch with `AnimatedTheme` (`Motion.phaseChange`): the color
  lerp IS the signature transition.
- **Teams:** Mafia = `mafia` red, Civilians = `civilian` gold. Used for team meaning only, never decoration.
- **Glass cards:** fill `surface`, 1 px border `surfaceBorder`, radius `Radii.card` (24) or `Radii.tile` (18).
  A card about a team or event uses the tint: fill `tint(color, 0.08–0.14)`, border `tint(color, 0.25–0.40)`.
- **Atmosphere:** one soft radial glow per screen (`glow`), positioned off-screen at a corner, behind content.
  Max one per screen.
- **Type:** Unbounded for display (titles, numbers, role names), Inter for body. Arabic: Cairo + IBM Plex Sans Arabic.
  Overline labels: `labelSmall`, uppercase, letter-spaced.
- **Icons:** thin stroke icons (1.8 px, rounded caps), e.g. `lucide_icons` or custom `CustomPainter`. No emoji.
- **One primary action per screen**, bottom-anchored, `Sizes.primaryButton` (60) tall, radius 20, with a soft colored
  shadow (`BoxShadow(color: cta 30–35%, blurRadius: 30, offset: (0, 10))`).

## Components (lib/ui/) — build these first, then the screens

| Widget | Spec | Used on |
|---|---|---|
| `GlassCard` | surface fill, border, radius 24, padding 18; optional `tintColor` | everywhere |
| `PrimaryActionButton` | 60 h, radius 20, color = `primaryCta` or `mafia` for eliminations, label + optional trailing arrow, shadow | all |
| `IconCircleButton` | 44×44, radius 22, glass fill, `aria`/semantics label required | headers |
| `PhaseHeader` | moon/sun icon + "Night 3" / "Day 3" in `headlineSmall`, trailing "Game log" pill | Night, Day |
| `StepRail` | N equal segments, 4 px bars + 11 px labels; done = `stepDone`, current = `civilian` bold, next = white 10% | Night |
| `PromptCard` | 52 px tinted icon box + title (`titleLarge`) + the line the host reads aloud (quoted, `bodyMedium` muted) | Night |
| `PlayerTile` | 80 h, radius 18, avatar 32 + name; states: idle, selected (2 px civilian border + tint + gold avatar), disabled with reason note ("Eliminated" struck-through, "Saved last night"), 0.45 opacity | Night, Bomb picker |
| `PlayerTargetGrid` | 3 columns, gap 8 | Night |
| `RoleChip` | 64 h tile: 36 px tinted icon box, role name, count badge (Mafia badge solid red, Civilian badge gold tint) | Setup |
| `TeamBalanceBar` | 10 px split bar red/gold with 3 px gap + labels under | Setup |
| `SegmentedPill` | 4 px padded track (white 5–6%), selected segment solid `text` color with dark label | Home, Setup, Day |
| `RoleCard` | 270×390, radius 28, 3D flip (`Motion.cardFlip`, perspective 0.0012, `Motion.flip` curve), back = gold crest + "TAP TO REVEAL"; front = team pill, 104 px role emblem, role name `displayMedium`, ability text, "Your family" chips for Mafia | Reveal |
| `AnnouncementItem` | numbered circle (30 px, event color) + headline 16/600 + muted detail; tint card per event type (death = mafia, bomb = bomb, save = saved) | Morning |
| `HostOnlyNote` | dashed border, lock icon, muted text, never shown on shared/player screens | Morning |
| `VoteRow` | 64 h, progress fill behind content (directional: starts at `start`), leader = red border + red avatar | Day |
| `CountdownRing` | 76 px ring, 6 px stroke, `primaryCta`, time in Unbounded 15 | Day |
| `StatTile` | number (Unbounded 22) + label; optional team tint | Home, Profile |

## Screens (approved)

1. **Home** (`Main.dc.html`) — greeting overline + "The city sleeps."; tonight's event hero card (red-tinted, moon
   glyph, avatar stack, "Start a game" red CTA); mode `SegmentedPill` (Host only · Cards / Players' phones);
   "Your table" 3 `StatTile`s; recent games list; floating bottom nav (64 h, radius 22, 4 tabs).
2. **Game setup** (`Setup.dc.html`) — back button + "New game"; player count card with stepper and
   `TeamBalanceBar`; "Roles" 2-column `RoleChip` grid + "Auto-balance" link; Bomb 2/3 `SegmentedPill`;
   CTA "Shuffle & deal roles".
3. **Role reveal** (`Reveal.dc.html`) — 11-segment progress; "Hand the phone to **Layla**"; `RoleCard`; glow
   changes to team color on flip; haptic on flip; CTA "Hide & pass to next player" appears only after flip.
4. **Night wizard** (`Night.dc.html`) — `PhaseHeader`, `StepRail`, `PromptCard`, `PlayerTargetGrid`;
   bottom: back `IconCircleButton` + CTA that reads "Pick a player to save" (disabled) → "Save Layla".
   One screen, state changes per step; the CTA verb follows the role (Block / Protect / Kill / Save / Check).
5. **Morning** (`Morning.dc.html`) — `day` theme with dawn gradient (`bgTop` → `bg`) and sun glyph; "Morning 3 /
   The town wakes up."; `AnnouncementItem`s appear one by one (`Motion.announceStagger`); `HostOnlyNote` for the
   Detective result; alive/eliminated counts; "Read aloud" (TTS) + "Start the day" CTA.
6. **Day vote** (`Vote.dc.html`) — "Day 3 / Who is lying?" + `CountdownRing`; Discussion/Voting pill; `VoteRow`s
   (tap = +1 vote, "Undo last vote"); CTA "Eliminate {leader}" in `mafia` red.
7. **Arabic RTL** (`NightAr.dc.html`) — the same Night screen mirrored. Every screen must look like this in `ar`.

## New screens — design them in the same language

Follow the components and rules above. One primary action, one glow, glass cards, team colors for meaning only.

| Screen | Theme | Key content |
|---|---|---|
| Chameleon choice | night | Grid of role chips to pick from, the picked one becomes a `RoleCard` preview; CTA "Become {role}" |
| Mafia kill step | night | Same as Night wizard; prompt card and selection in `mafia` red; shows the Mafia's proposed targets with small vote dots; Godfather confirms |
| Detective result | night | Full-screen card for the host only: target name + big result "Mafia" (red) / "Civilian" (gold); "Blocked tonight" state |
| Bomb victims picker | day or night (current phase) | `bomb` orange accent, "Choose 2 players"; counter chip "1 / 2"; CTA "Detonate" |
| Game over | warm if Civilians won / red if Mafia won | Big winning team title, confetti-free: slow glow pulse; full role reveal list (avatar, name, role chip, alive/dead); CTAs "Play again" and "Back to event" |
| Game log | current phase | Timeline grouped by Night/Day, each entry an icon + one line; filter pills (All / Kills / Saves / Votes) |
| Events list | night | Upcoming hero card (like Home) + past events list with result chips |
| Event detail | night | Date/time/place header, RSVP `SegmentedPill` (Going / Maybe / Not going), attendee avatars, games played that night |
| Player profile | night | Large avatar, name, `StatTile` row (Games, Win rate, Favorite role), role history bars |
| Leaderboard | night | Top 3 podium cards (gold/silver/bronze tints), then ranked rows |
| Settings | night | Language (English / العربية) as pill, sound, haptics, reveal-role-on-death, default Bomb count, timer lengths |
| Players' phones: join room | night | Big 4–6 char room code input, "Scan QR" secondary, CTA "Join" |

## Motion checklist

- Screen entrances: content fades + slides 12 px up, 240 ms, staggered 40 ms per block (`flutter_animate`).
- Night → Morning: `AnimatedTheme` 800 ms + moon sets / sun rises (simple `AnimatedPositioned`).
- Role card flip 700 ms + `HapticFeedback.mediumImpact()`.
- Selection: tile border/fill animate 160 ms; light haptic on pick.
- Announcements: 400 ms stagger, deaths with a subtle scale-in from 0.96.
- `MediaQuery.disableAnimationsOf(context)` → jump to end states.

## Done = matches the mockup

For each screen: side-by-side compare with its mockup at 390×844 (iPhone 14/15 simulator), in English and Arabic.
Add golden tests for both locales.
