# 🕹️ Gawla — Mini-Games Library

> Companion document to `PROJECT_OVERVIEW.md`.
> Full gameplay specs for every mini-game: mechanics, interaction, timing, elimination rule, and anti-cheat notes.

This library is split into three tiers:

- **Tier A — MVP Core Set**: the original 10 games, detailed for implementation.
- **Tier B — Signature Elimination Games**: new games built around the core vision — *large group in, one rule per round, unpredictable elimination method, tension escalates as the pool shrinks.* This is the set that pushes Gawla toward the "live elimination tournament" feeling.
- **Tier C — Future Concepts**: short-form ideas kept for later roadmap passes.

---

## 1. Elimination Rule Taxonomy

Every mini-game in this library is tagged with one elimination type below. This is the key structural idea for the "different rule per round" vision — the **Tournament Engine** doesn't apply one global formula; each mini-game config declares its own `EliminationType` and `eliminationTarget` (a count or percentage), and the engine just executes whatever the selected game defines.

| Type | ID | Description | Typical Target |
|---|---|---|---|
| Threshold / Rank | `rank_cutoff` | Players ranked by score/time; bottom X% or bottom N eliminated | 25–50% of pool |
| Binary Pass/Fail | `binary_fail` | One wrong action/choice = instant elimination, no ranking needed | Variable, often the majority |
| Duel | `duel_loser` | Players paired 1v1 (or small groups); losers of each pairing eliminated | ~50% per round |
| Survival Timer | `survival_fail` | Must maintain a state (stay in zone, stay alive) for the full duration; failing at any point = out | Variable |
| Team Result | `team_loss` | Two (or more) teams compete; losing team, or its weakest members, eliminated | ~50% (whole team) or bottom contributors |
| Composite / Boss | `composite_final` | Finale-only: mixes two mechanics, resolves to a single winner | All but 1 |

Mixing these across a tournament's mini-game rotation is what creates the Squid-Game-style unpredictability — players never know if the next round will cut them by score, by a single mistake, by a coin-flip duel, or by team loyalty.

---

## 2. Common Data Contract

To keep every mini-game plug-and-play inside `features/mini_games/`, each game should implement the same shape so the Tournament Engine can run any of them interchangeably:

**MiniGameConfig** (per round, generated/pulled from Remote Config or room settings)
- `gameId` (string, unique — matches the IDs below)
- `roundDurationSec`
- `eliminationType` (from taxonomy above)
- `eliminationTarget` (int or %)
- `difficultyModifier` (optional, scales with round number)

**MiniGameResult** (submitted per player, per round)
- `playerId`
- `gameId`
- `roundId`
- `rawMetric` (time, score, choice, or pass/fail — game-specific)
- `serverTimestamp` (never trust client-sent time)
- `submissionToken` (one-time, idempotent — see Anti-Cheat table in overview)

Cloud Functions own the ranking/resolution logic per `eliminationType`, never the client.

---

## 3. Tier A — MVP Core Set

### 3.1 Reaction Tap
- **ID:** `reaction_tap`
- **Skill Type:** Reflex
- **Description:** A signal (color flash / shape) appears at a random moment. Players must tap the instant it appears.
- **Mechanics:** Server picks and broadcasts the trigger timestamp; each client's tap is timestamped server-side on arrival; reaction time = `serverTapTime - serverTriggerTime`.
- **Interaction:** Single full-screen tap target; screen flashes green on trigger.
- **Round Duration:** 10–15s (very short, high pressure).
- **Elimination Type:** `rank_cutoff` — slowest 25–50% of reactors eliminated; anyone tapping before the trigger is auto-eliminated (false start).
- **Notes:** Highest cheat risk in the whole library — see anti-cheat table. Never accept client-reported reaction time.

### 3.2 Quick Trivia
- **ID:** `quick_trivia`
- **Skill Type:** Knowledge
- **Description:** Multiple-choice question, short timer, fastest correct answers rank highest.
- **Mechanics:** Question + 4 options pulled from a rotating server-side pool (never shipped in the client build); answer + response time submitted together.
- **Interaction:** 4 large tap buttons.
- **Round Duration:** 8–12s per question, 2–3 questions per round.
- **Elimination Type:** `rank_cutoff` — wrong answers ranked last automatically; among correct answers, slowest cut first.
- **Notes:** Pool must rotate per season to prevent players sharing/memorizing answers.

### 3.3 Memory Cards
- **ID:** `memory_cards`
- **Skill Type:** Memory
- **Description:** A grid of cards flashes briefly, then hides; players must recall and tap the matching positions/pattern.
- **Mechanics:** Server generates the grid pattern; client shows it for a fixed reveal window then blanks it; player taps blind; result = correct-cell count.
- **Interaction:** Tap grid cells in sequence.
- **Round Duration:** 30–45s (reveal + recall phases).
- **Elimination Type:** `rank_cutoff` — lowest correct-match counts eliminated.

### 3.4 Find the Difference
- **ID:** `find_the_difference`
- **Skill Type:** Precision / Perception
- **Description:** Two near-identical images side by side; player taps the differing spot(s) fastest.
- **Mechanics:** Difference coordinates + tolerance radius stored server-side; tap validated against radius + timestamped.
- **Interaction:** Tap on the differing region of either image.
- **Round Duration:** 30–60s, multiple difference-pairs per round.
- **Elimination Type:** `rank_cutoff` — fewest correct finds / slowest finds cut.

### 3.5 Color Challenge
- **ID:** `color_challenge`
- **Skill Type:** Reflex / Attention
- **Description:** A stream of color words/tiles appears; players tap only when word and color match (or per a stated rule) — a Stroop-style attention test.
- **Mechanics:** Same server-authoritative timing model as Reaction Tap; correctness + latency both scored.
- **Interaction:** Tap "Match" / "No Match" buttons, or tap the tile itself.
- **Round Duration:** 30–45s, rapid-fire sequence.
- **Elimination Type:** `rank_cutoff` — combined accuracy + speed score, bottom % cut.

### 3.6 Math Rush
- **ID:** `math_rush`
- **Skill Type:** Knowledge / Speed
- **Description:** Quick arithmetic problems, answer as many correctly as possible before time runs out.
- **Mechanics:** Server-generated problem stream (per-player seed, not shared, to reduce shout-out cheating in the same room); submissions batched with timestamps.
- **Interaction:** Numeric keypad or multiple-choice tap answers.
- **Round Duration:** 30–45s.
- **Elimination Type:** `rank_cutoff` — lowest correct-answer count cut.
- **Notes:** Watch for calculator/macro assistance; per-player unique problem sets reduce answer-sharing value.

### 3.7 Sequence Order
- **ID:** `sequence_order`
- **Skill Type:** Memory
- **Description:** A sequence of icons/sounds/positions is shown; players must reproduce it in the exact order.
- **Mechanics:** Server-generated sequence, length scales with round/difficulty; client submits ordered taps; compared server-side.
- **Interaction:** Tap icons in the remembered order.
- **Round Duration:** 30–45s.
- **Elimination Type:** `binary_fail` (first wrong step ends the attempt) or `rank_cutoff` (partial credit by longest correct streak) — configurable per round.

### 3.8 Speed Typing
- **ID:** `speed_typing`
- **Skill Type:** Precision / Speed
- **Description:** A short word/phrase appears; players type it as fast and accurately as possible.
- **Mechanics:** Client measures keystroke timings locally for UX feedback only; final score = server-validated completion time + accuracy against the target string.
- **Interaction:** On-screen or system keyboard input.
- **Round Duration:** 20–30s.
- **Elimination Type:** `rank_cutoff` — slowest/least accurate cut.
- **Notes:** Device keyboard latency varies — normalize by measuring first-keystroke-to-submit rather than raw device timestamps.

### 3.9 True or False
- **ID:** `true_or_false`
- **Skill Type:** Knowledge
- **Description:** Rapid-fire true/false statements; player taps their answer before the timer runs out.
- **Mechanics:** Same pattern as Quick Trivia but binary choice, faster pace.
- **Interaction:** Two large buttons (True / False).
- **Round Duration:** 20–30s, several statements per round.
- **Elimination Type:** `rank_cutoff`.

### 3.10 Hidden Object
- **ID:** `hidden_object`
- **Skill Type:** Perception
- **Description:** A busy scene contains a small hidden target object; find and tap it fastest.
- **Mechanics:** Object coordinates + tap-tolerance radius server-side; timestamp on find.
- **Interaction:** Pan/zoom scene, tap the object.
- **Round Duration:** 30–60s.
- **Elimination Type:** `rank_cutoff`.

---

## 4. Tier B — Signature Elimination Games

*Inspired by classic large-group elimination formats (red-light/green-light, glass-bridge crossings, tug-of-war, marble duels, steady-hand tracing) — reimagined as fast, server-fair, mobile-native mini-games. These are the games meant to make a Gawla tournament feel like a live elimination event rather than a quiz app.*

### 4.1 Freeze Frenzy
*("Red Light / Green Light" reimagined)*
- **ID:** `freeze_frenzy`
- **Skill Type:** Reflex / Self-control
- **Description:** Players hold a button to advance a runner toward the finish line. The signal randomly flips between GREEN (move freely) and RED (freeze instantly). Anyone who moves during RED is out.
- **Mechanics:** Server owns the GREEN/RED schedule and broadcasts the switch with an authoritative timestamp. Client streams the hold/release state; the server checks whether any hold-input occurred within a small grace window after a RED switch.
- **Interaction:** One large "MOVE" hold-button; runner avatar advances while held; screen border flashes red/green as the state changes.
- **Round Duration:** 45–60s, or until a player reaches the finish line.
- **Elimination Type:** `binary_fail` — caught moving during RED = eliminated instantly. Anyone who hasn't reached the finish line when time runs out is also eliminated.
- **Anti-Cheat:** Grace window must be tuned server-side (not client-configurable); flag inputs with suspiciously consistent zero-latency stopping (possible automation/macro).

### 4.2 Tile Trap
*("Glass Bridge" reimagined)*
- **ID:** `tile_trap`
- **Skill Type:** Risk Assessment / Memory
- **Description:** A bridge of tile pairs stretches ahead of each player; one tile in each pair is safe, the other breaks. Players choose a tile per step to cross before their path collapses.
- **Mechanics:** Server generates a unique hidden safe-path per player (never sent to the client in advance). Each step has a short countdown forcing a decision; a wrong pick immediately eliminates that player and reveals the break animation.
- **Interaction:** A row of paired tiles ahead of the player avatar; tap a tile to commit to it.
- **Round Duration:** 60–90s, ~5s per step decision window.
- **Elimination Type:** `binary_fail` — one wrong tile ends the run; timing out on a step also counts as a wrong pick.
- **Anti-Cheat:** The safe path must exist only server-side until the moment of choice — never bundle it in the client payload, even encrypted, since a Flutter client is inherently inspectable.

### 4.3 Musical Freeze
*("Musical Chairs" reimagined)*
- **ID:** `musical_freeze`
- **Skill Type:** Timing / Reflex
- **Description:** Music/animation plays; the instant it stops, players must tap "Freeze!" — slowest reactions (and false starts) are cut.
- **Mechanics:** Server owns the stop-moment broadcast; every tap timestamped on arrival relative to that moment; a tap that arrives before the stop event is an automatic false-start elimination.
- **Interaction:** Dance/animation visual; one big "Freeze!" button appears exactly at the stop moment.
- **Round Duration:** 30–45s across 2–3 unpredictable stop points.
- **Elimination Type:** `rank_cutoff` — bottom % by reaction latency cut each stop; false starts always cut regardless of rank.
- **Anti-Cheat:** Same server-authoritative timestamp pattern as Reaction Tap.

### 4.4 Steady Hands
*("Balance the pieces" reimagined)*
- **ID:** `steady_hands`
- **Skill Type:** Precision / Control
- **Description:** Players must keep an on-screen marker inside a shrinking target zone by tilting the device (or dragging, on devices without reliable sensors) — losing control drops you out.
- **Mechanics:** Device gyroscope/accelerometer tilt (with a touch-drag fallback) maps to marker position; target zone shrinks over the round; cumulative time-outside-zone is tracked.
- **Interaction:** Tilt phone / drag marker to stay inside a circular zone that gradually shrinks.
- **Round Duration:** 30–45s.
- **Elimination Type:** `survival_fail` — cumulative time outside the zone beyond a threshold = eliminated at the moment it's crossed.
- **Anti-Cheat:** Sensor spoofing risk is lower than timing games, but flag physically-impossible marker stability (perfectly zero jitter for the full duration) for review.

### 4.5 Trace the Shape
*("Honeycomb tracing" reimagined)*
- **ID:** `trace_the_shape`
- **Skill Type:** Precision / Steadiness
- **Description:** An outline shape appears; players trace it with a finger, staying inside a tolerance margin, without breaking the line before completing enough of it.
- **Mechanics:** Finger-drag path recorded and compared against the target vector shape; tolerance margin shrinks as difficulty increases; a required completion percentage must be reached within the round.
- **Interaction:** Drag-trace along the shape outline shown on screen; live progress/tolerance bar.
- **Round Duration:** 45–60s.
- **Elimination Type:** `binary_fail` — breaking tolerance more than a small allowed number of times, or failing to reach the required completion %, eliminates the player.
- **Anti-Cheat:** Server validates the submitted path against shape geometry and timestamps; a mathematically "too perfect" trace (bot-like) can be flagged for review.

### 4.6 Odd One Out
*("Marble duel" reimagined)*
- **ID:** `odd_one_out`
- **Skill Type:** Psychology / Deduction
- **Description:** Remaining players are randomly paired 1v1; each secretly locks in a choice (Odd/Even, or Rock-Paper-Scissors-style); the loser of each duel is eliminated.
- **Mechanics:** Both players' choices are locked (hashed/committed) server-side before either is revealed, then resolved simultaneously — no one can see or react to the opponent's pick.
- **Interaction:** Two (or three) large choice buttons; countdown to lock-in; reveal animation.
- **Round Duration:** 15–20s per duel; several duel waves fill a ~60–90s round.
- **Elimination Type:** `duel_loser` — loser out each duel; ties trigger an immediate sudden-death rematch.
- **Anti-Cheat:** Commit-then-reveal pattern is mandatory — never let a client see the opponent's choice before its own is submitted.

### 4.7 Tug of Power
*("Tug of war" reimagined)*
- **ID:** `tug_of_power`
- **Skill Type:** Speed / Team Coordination
- **Description:** Players are split into two teams; rapid tapping contributes "pulling power"; the team that gets pulled past their line loses.
- **Mechanics:** Tap-rate per player aggregated server-side into a live team total via Realtime Database; rope position streamed to all clients in near real time.
- **Interaction:** One large "Pull!" tap button; shared rope visual with a live team power meter.
- **Round Duration:** 30–45s.
- **Elimination Type:** `team_loss` — configurable per round: either the entire losing team is eliminated, or only its lowest-contributing members (keeps strong teammates alive, adds internal pressure).
- **Anti-Cheat:** Hard per-user tap-rate cap enforced server-side to block auto-tap macros/bots from inflating team totals.

### 4.8 Boss Round
*(Finale-only composite challenge)*
- **ID:** `boss_round`
- **Skill Type:** Mixed (Reflex + Memory + Knowledge, drawn from earlier rounds)
- **Description:** The last stage before the Winner Screen. Combines two mechanics from the mini-games the finalists already played, to crown a single winner from the last few survivors.
- **Mechanics:** Engine picks 2 sub-mechanics from a curated pool sized to the number of finalists (e.g. a duel-style decider for 2 players, a rank-cutoff sprint for 3–4); reuses the anti-cheat pattern of whichever sub-mechanics are composed.
- **Interaction:** Adapts to whichever sub-mechanics are selected (inherits their UI).
- **Round Duration:** 60–90s.
- **Elimination Type:** `composite_final` — all but one finalist eliminated; ties resolved by an immediate sudden-death sub-round.
- **Notes:** This is the natural replacement for the generic "Final Round" step in the match flow — it's not a fixed game, it's a composition rule.

---

## 5. Tier C — Future Concepts (short-form, roadmap)

These are kept lightweight for now — full specs to be written when scheduled for a build.

| Concept | Skill Type | Rough Idea |
|---|---|---|
| Drawing Guess | Creativity / Knowledge | One player draws a prompt, others guess fastest — could plug into `rank_cutoff` or `binary_fail` |
| Bluff Game | Psychology / Deduction | Players submit statements, others vote true/false about who's bluffing — pairs well with `duel_loser` or `rank_cutoff` |
| Spy Game | Social Deduction | Hidden-role round layered on top of another mini-game; needs its own reveal/vote phase design |
| Geography Challenge | Knowledge | Map-tap or country-guess trivia variant of Quick Trivia |
| Audio Guess | Perception / Knowledge | Identify a sound/clip fastest — same shape as Quick Trivia with an audio prompt |
| Emoji Puzzle | Knowledge / Pattern | Decode a phrase/title from an emoji sequence |
| Pattern Memory | Memory | Simon-Says style expanding pattern repeat — natural sibling to Sequence Order, could use `survival_fail` (one strike and you're out, pattern keeps growing) |
| Season Events | N/A | Time-limited variants of Tier B games with cosmetic reskins, not a new mechanic |

---

## 6. Suggested Tournament Composition

To keep the "never know what's next" tension the vision calls for, mix elimination types within a single tournament rather than stacking the same type back-to-back. Example for a 24-player tournament:

```
24 Players
  ↓ Reaction Tap        (rank_cutoff)
16 Players
  ↓ Tile Trap            (binary_fail)
10 Players
  ↓ Tug of Power         (team_loss)
6 Players
  ↓ Odd One Out          (duel_loser)
3 Players
  ↓ Boss Round           (composite_final)
Winner
```

The `MiniGameConfig` for each round (see §2) is what makes this composition data-driven — new mini-games can be dropped into the rotation pool without touching the Tournament Engine itself.
