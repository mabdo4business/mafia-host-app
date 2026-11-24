# Mafia Town — Game Rules (source of truth)

> Converted from the official **Mafia Town Game Guide** (PDF, 4 pages).
> This file replaces the role and rule descriptions in `CLAUDE.md` and in the earlier product spec.
> Section 1–3 = the guide, faithfully. Section 4 = what changes in the app. Section 5 = proposed engine order.
> Section 6 = open questions — implement each as a `GameSettings` flag with the listed default, never hard-code.

---

## 1. Teams and roles

**Mafia Town** is a social strategy game of mystery, deception, observation and trust. Every player has a secret role.
Some players work together in secret (Mafia Team); the others (Civilians Team) try to uncover them first.

### 1.1 Mafia Team (6 roles)

| Role | Card tagline | Ability (from the guide) | When |
|---|---|---|---|
| **Godfather** | Mafia boss decides who dies. | Leader of the Mafia. At night the Mafia has **20 seconds** to discuss the target, but the **final decision belongs to the Godfather**, who shows the chosen player's number. **If the Godfather is eliminated by the day vote, he may take one player with him** and both leave the game. | Every night · on day-vote elimination |
| **Mafia** | Mafia works for the boss, attacks at night. | The Godfather's team. At night every Mafia player may advise the Godfather about the target. **If the Godfather is no longer in the game**, all remaining Mafia players have **20 seconds to agree** and must show the **same player's number**. **Different numbers cancel the murder.** | Every night |
| **Putana** | Blocks good players' powers at night. | **First night only:** wakes with the Mafia to recognize her team. After that she wakes **separately** and **blocks one player's night ability** each night. **If she becomes the only remaining Mafia Team player, she becomes a regular Mafia and can kill at night.** | Night 1 with Mafia; every night after |
| **Lawyer** | Protects one Mafia; Detective sees them as good. | Each night protects **one Mafia player** from the Detective's investigation. If the Detective checks that same protected player that night, the Host shows the Detective that the player is a **Civilian**. | Every night |
| **Witch** | One soul, many fates. Once per game, at night, choose two players to link their souls. If one of the linked players dies at night, the other dies too. | **Second night only:** chooses **two Civilians** and **links** them. If either linked player is **killed during the night**, the other dies too. **Voting does not trigger the link.** Once created, the link **stays active even if the Witch later dies.** | Night 2 only |

> Note: "Putana" is the guide's spelling (earlier docs used "Potana").

### 1.2 Civilians Team (10 roles)

| Role | Card tagline | Ability (from the guide) | When |
|---|---|---|---|
| **Detective** | Checks one player to know if it's Mafia. | Investigates one suspected player each night; the Host confirms whether that player is **Mafia**. **Chain rule:** if the Detective completes **three investigations** and correctly identifies **two Mafia players**, then if the Detective is **later killed**, those **two identified Mafia players die with the Detective**. | Every night |
| **Doctor** | Saves one person from dying. | Saves another player **or themselves** from a night kill. May protect the **same person two nights in a row, but not three**; on the third night must choose a different player. | Every night |
| **Joker** | Tries to expose Mafia and kills one person each night. | Plays with the Civilians but **also kills at night**. Each night chooses one player they suspect is Mafia Team and attempts to eliminate them. | Every night |
| **Switchman** ("The Immortal") | If killed at night, wakes up and shoots someone. | If someone tries to kill the Switchman at night, the Host wakes them and they **redirect the bullet to another player of their choice**. The Switchman can only be killed at night **if Putana blocks their ability on that same night**. | When targeted at night |
| **Silencer** | Silences someone; they can't talk next day. | Chooses one player to **silence for one full round**. The silenced player **cannot join Free Chat**, **does not get their 30-second Speech**, and **cannot vote** that round. | Every night |
| **Bomb** | If killed, explodes and kills players he planted bombs on. | **Wakes once, after the first day**, and secretly **places bombs on two players**. If the Bomb later **dies at night or by voting**, those two players die too. **If voted out on the first day** (before planting), may instead take the **two players sitting directly beside them**, or take **no one**. | Night 2 (plant) · on death |
| **Shapeshifter** | One soul, many roles. Each night you play the roles in this order: Detective → Doctor → Joker. | Changes ability **every night in a fixed order: Detective, Doctor, Joker, then repeats**. Uses that night's ability while **always remaining on the Civilians Team**. | Every night (rotating) |
| **Chameleon** | Chooses any role he wants on the third night. | Wakes on the **third night**. The Host secretly goes through five roles: **Mafia, Detective, Doctor, Joker, Switchman**. The Chameleon chooses one and **keeps that role and its abilities for the rest of the game**. | Night 3 (choose) · then as chosen role |
| **TNT** | Explodes and kills the players sitting right and left (neighbors). | If TNT is **eliminated from the game** (any way), the players sitting **directly to the right and left** are eliminated too. | On elimination |
| **Civilian** | No powers, just tries to stay alive. | No night ability. Uses observation, discussion, suspicion and voting. | Day only |

---

## 2. Day phase (Game rules)

| Step | Duration | Rule |
|---|---|---|
| **Free Chat** | 2 minutes | Everyone may discuss, suspect, defend and share thoughts. |
| **30-second Speech** | 30 s per player | Each player's personal time to deliver their message. |
| **Foul speech** | 15 s | A player may take a **Foul** to get an additional 15-second speech. |
| **Voting** | — | Vote for the player you suspect most. |
| **Equal votes** | — | If two or more players share the highest vote count, **there is a re-vote**. |

Silenced players (Silencer) skip Free Chat, their Speech, and the vote for that round.

## 3. Table rules (shown to players; Host enforces)

"Strict but fair": the Host may remove a player from the table only if the rules are **repeatedly** broken.

1. Speak only during Free Chat, your own 30-second Speech, or a Foul (extra 15 s).
2. Do not respond to accusations during another player's speaking time; wait for your turn.
3. Never reveal your role — do not tell or show anyone.
4. No swearing, offensive gestures or personal insults.
5. Keep it in the game: attack the role, strategy or suspicion — never the person.
6. Play hard, bluff, defend and accuse — but always keep it respectful.

---

## 4. What changes in the app (vs current CLAUDE.md / spec)

| Area | Before | Now (guide) |
|---|---|---|
| Roles | 10 roles | **16 roles**: add **Witch, Switchman, Silencer, Shapeshifter, TNT**; rename Potana → **Putana** |
| Seating | Not modelled | **Seat order is required** (TNT neighbors, Bomb day-1 neighbors). Setup must capture players in table order (circular). |
| Godfather | Appears as Civilian to Detective; final kill call | Final kill call + **takes one player with him if voted out**. Guide does **not** say he appears innocent → see Q1. |
| Mafia kill | Godfather decides | Godfather decides (20 s timer). **If Godfather is dead: all Mafia must pick the same number, else no kill.** |
| Putana | Blocks civilian roles only, every night | **Night 1: recognizes team only (no block).** From night 2 blocks **one player's** ability. **Becomes a killer if last Mafia Team player.** |
| Doctor | Cannot save same player 2 nights in a row | **Can** save the same player 2 nights in a row, **not 3**. |
| Detective | Checks team | Checks Mafia yes/no + **chain rule** (3 checks, 2 Mafia found → those 2 die when Detective dies). Track per Detective: checks done, Mafia identified. |
| Bomb | On death picks 2–3 victims (host setting) | **Plants on 2 players on night 2**; they die when Bomb dies (night or vote). **Day-1 vote-out:** take both neighbors or no one. **Remove the 2/3 setting.** |
| Chameleon | Picks any role at game start | **Picks on night 3** from: Mafia, Detective, Doctor, Joker, Switchman. |
| Day phase | Discussion timer + vote | **Free Chat 2:00 → each player's 30 s Speech (+15 s Foul) → Vote → tie = re-vote.** |
| Players | — | Track **fouls** per player and **silenced** state per round; host can **remove** a player. |
| Night prompts | — | Night 1 has a "Mafia team, open your eyes and recognize each other" step (with Putana). |

New state the engine needs: `seatIndex` per player, `witchLink: (a, b)?`, `bombTargets: [a, b]?`, `bombPlanted`,
`detectiveChecks`, `detectiveConfirmedMafia: [ids]`, `doctorSaveStreak (playerId, count)`, `silencedForRound`,
`chameleonChosenRole`, `shapeshifterRoleForNight = [Detective, Doctor, Joker][(night - 1) % 3]`, `fouls` per player.

Default timers (`GameSettings`, editable): Mafia discussion 20 s, Free Chat 120 s, Speech 30 s, Foul 15 s.

---

## 5. Proposed night order (engine) — not in the guide, confirm with Host

The guide does not state a wake order. Proposed so every rule resolves deterministically:

**Wake order (host prompts)**
1. *Night 1 only:* Mafia Team + Putana open eyes to recognize each other.
2. Putana — block (from night 2).
3. Lawyer — protect one Mafia.
4. Mafia / Godfather — kill (20 s).
5. Witch — link two Civilians (night 2 only).
6. Joker — kill.
7. Silencer — silence.
8. Doctor — save.
9. Shapeshifter — tonight's role (Detective / Doctor / Joker).
10. Detective — check.
11. Bomb — plant on two players (night 2 only).
12. Chameleon — choose role (night 3 only; from night 4 wakes as the chosen role).

**Resolution**
1. Apply Putana's block (blocked player's action has no effect tonight).
2. Collect kill attempts (Mafia, Joker, Shapeshifter-as-Joker, Chameleon-as-Mafia/Joker).
3. Switchman: if targeted and **not blocked**, attempt is redirected to the Switchman's chosen player (Host wakes Switchman).
4. Apply Doctor (and Shapeshifter-as-Doctor) saves.
5. Detective results (Lawyer protection applied).
6. Deaths applied → chain triggers in a loop until no new deaths: Witch link (night deaths only), Bomb planted targets, TNT neighbors, Detective chain.
7. Putana promotion if she is the last Mafia Team player.
8. Win check → morning announcement.

**Day vote elimination chains:** Godfather takes one player · Bomb planted targets (or day-1 neighbors / no one) ·
TNT neighbors · Detective chain if the voted-out player is the Detective (see Q5). Witch link does **not** trigger.

---

## 6. Open questions — implement as `GameSettings` flags (default in bold)

| # | Question | Flag | Default |
|---|---|---|---|
| Q1 | Does the Godfather appear as Civilian to the Detective? (Guide is silent; earlier rule said yes.) | `godfatherAppearsCivilian` | **false** (follow guide) |
| Q2 | Can Putana block Mafia Team players too, or only Civilians? (Guide: "one player's night ability".) | `putanaCanBlockMafia` | **true** |
| Q3 | Re-vote ends in a tie again → ? | `secondTieRule`: noElimination / hostDecides / randomAmongTied | **noElimination** |
| Q4 | Chameleon picks **Mafia** → does he switch to the Mafia Team (win condition, Detective result)? | `chameleonMafiaJoinsMafiaTeam` | **true** |
| Q5 | Detective chain: does it trigger only on night kill, or also when voted out? ("later killed") | `detectiveChainOnVote` | **false** |
| Q6 | Detective chain: does a check blocked by Putana, or a Lawyer-protected "Civilian" result, count toward the 3 investigations? | `blockedChecksCount` | **false** (only completed checks count; Lawyer-masked results count as a check but not as a Mafia found) |
| Q7 | Can the Doctor save a player from chain deaths (Witch link, Bomb, TNT, Detective chain)? | `doctorBlocksChainDeaths` | **false** (Doctor only stops direct night kills) |
| Q8 | Switchman targeted by two attackers in one night (e.g. Mafia + Joker) → one redirect or one per bullet? | `switchmanRedirectsEach` | **true** |
| Q9 | Can the Switchman redirect onto a player the Doctor saved (does the save still protect)? | `doctorSavesRedirectedBullet` | **true** |
| Q10 | Bomb dies on night 1 (before planting) → no explosion? | `bombNoEffectBeforePlant` | **true** |
| Q11 | Does Silencer's silence apply to the next day only ("one full round" = the following day)? | `silenceLastsNextDay` | **true** |
| Q12 | Witch: the rule text says "two Civilians", the card says "two players". Civilians Team only, or anyone? | `witchCiviliansOnly` | **true** |
| Q13 | Win conditions (not in the guide) | `winRule` | **Civilians: all Mafia Team gone. Mafia: Mafia Team ≥ Civilians Team alive.** |
| Q14 | Do killed players' roles get revealed? (Not in the guide.) | `revealRoleOnDeath` | **false** |
| Q15 | Is Joker's kill blocked by Putana? (Putana blocks "one player's night ability".) | — | **yes** (follows Q2) |
