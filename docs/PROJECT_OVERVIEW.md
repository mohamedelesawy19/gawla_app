# 🎮 Gawla Project Overview

> A real-time multiplayer party game built with Flutter & Firebase.
>
> Players join fast tournaments consisting of multiple mini-games.
> After each round, a portion of the players is eliminated until only one winner remains.

---

# Vision

Create the most fun real-time party game on mobile without requiring complex graphics.

The focus is on:
- Fast gameplay
- Skill & knowledge
- Competition
- Weekly rewards
- Endless replayability

The game should feel like joining a live tournament rather than playing a single game.

Elimination is the emotional core of that feeling: it should never be predictable. Every mini-game carries **its own elimination rule** — ranked cutoff, single-mistake fail, head-to-head duel, survival timer, or team result — so players never know exactly how the next round will cut the pool. See `MINI_GAMES_LIBRARY.md` for the full elimination taxonomy and every mini-game's spec.

---

# Core Principles

- Matches last 5–8 minutes.
- Every tournament contains multiple mini-games.
- Each mini-game lasts 30–90 seconds.
- Players are eliminated after each round.
- **Elimination method varies per mini-game** — there is no single fixed elimination formula. Each mini-game declares its own elimination type (ranked cutoff, single-mistake fail, duel, survival timer, or team result), so the *how* of elimination stays unpredictable across a tournament, not just the *who*.
- Easy to learn.
- Hard to master.
- No complex 3D graphics.
- Built for scalability.

---

# Match Flow

```
Home
  ↓
Create Room / Join Room
  ↓
Room Settings
  ↓
Waiting Room
  ↓
Tournament Starts
  ↓
Mini Game 1 → Results
  ↓
Mini Game 2 → Results
  ↓
Mini Game 3 → Results
  ↓
Final Round
  ↓
Winner Screen
  ↓
Leaderboard Update
```

---

# Example Tournament

Elimination *types* are deliberately mixed across rounds — not just player counts. See `MINI_GAMES_LIBRARY.md §6` for the taxonomy behind each tag below.

```
24 Players
  ↓ Reaction Tap        (ranked cutoff)
16 Players
  ↓ Tile Trap            (single-mistake fail)
10 Players
  ↓ Tug of Power         (team result)
6 Players
  ↓ Odd One Out          (head-to-head duel)
3 Players
  ↓ Boss Round           (composite finale)
Winner
```

---

# Room Settings

Host can configure:

- Public / Private
- Mini-game Rotation

---

# Game Modes

### Public Room

Anyone can join until the room reaches its player limit.

### Private Room

Players join using an invite code shared by the host.

---

# Mini-Games

> Full specs (mechanics, interaction, timing, elimination rule, anti-cheat notes) for every mini-game below live in **`MINI_GAMES_LIBRARY.md`**. This section is a quick-reference index only.

## Tier A — MVP Set

| Mini-Game | ID | Skill Type | Elimination Type | Cheat Risk | Notes |
|---|---|---|---|---|---|
| Reaction Tap | `reaction_tap` | Reflex | Ranked cutoff | High — timestamp spoofing | Requires server-authoritative timing |
| Quick Trivia | `quick_trivia` | Knowledge | Ranked cutoff | Medium | Answer pool must rotate to prevent memorization/sharing |
| Memory Cards | `memory_cards` | Memory | Ranked cutoff | Low | — |
| Find the Difference | `find_the_difference` | Precision/Perception | Ranked cutoff | Low | — |
| Color Challenge | `color_challenge` | Reflex/Attention | Ranked cutoff | Medium | Same timing risk as Reaction Tap |
| Math Rush | `math_rush` | Knowledge/Speed | Ranked cutoff | Medium | Watch for calculator/macro assistance |
| Sequence Order | `sequence_order` | Memory | Single-mistake fail / Ranked cutoff | Low | — |
| Speed Typing | `speed_typing` | Precision/Speed | Ranked cutoff | Medium | Device keyboard latency varies — needs normalization |
| True or False | `true_or_false` | Knowledge | Ranked cutoff | Low | — |
| Hidden Object | `hidden_object` | Perception | Ranked cutoff | Low | — |

## Tier B — Signature Elimination Games

*The set built specifically around the "live elimination tournament" vision — one unpredictable rule per round.*

| Mini-Game | ID | Skill Type | Elimination Type | Notes |
|---|---|---|---|---|
| Freeze Frenzy | `freeze_frenzy` | Reflex/Self-control | Single-mistake fail | Server-owned red/green signal |
| Tile Trap | `tile_trap` | Risk/Memory | Single-mistake fail | Per-player hidden safe path |
| Musical Freeze | `musical_freeze` | Timing/Reflex | Ranked cutoff | False starts always eliminated |
| Steady Hands | `steady_hands` | Precision/Control | Survival timer | Gyroscope + touch-drag fallback |
| Trace the Shape | `trace_the_shape` | Precision/Steadiness | Single-mistake fail | Path validated against shape geometry |
| Odd One Out | `odd_one_out` | Psychology/Deduction | Head-to-head duel | Commit-then-reveal choice pattern |
| Tug of Power | `tug_of_power` | Speed/Team | Team result | Per-user tap-rate cap required |
| Boss Round | `boss_round` | Mixed (finale only) | Composite finale | Replaces the generic "Final Round" step |

## Tier C — Future Concepts

- Drawing Guess
- Bluff Game
- Spy Game
- Geography Challenge
- Audio Guess
- Emoji Puzzle
- Pattern Memory
- Season Events (cosmetic reskins of Tier B games)

---

# Technical Architecture

## Frontend

- Flutter / Dart
- **Architecture:** Clean Architecture, Feature-First, BLoC, Repository Pattern, Dependency Injection (GetIt)

## Backend — Firebase

Authentication · Realtime Database · Cloud Functions · Storage · Remote Config · Analytics · Crashlytics · App Check

---

## App Architecture (`lib/`)

```
core/
features/
  auth/
  home/
  room/
  tournament/
  mini_games/
  leaderboard/
  profile/
  rewards/
  settings/
shared/
```

---

## Anti-Cheat & Security

| Threat | Mitigation |
|---|---|
| Client-reported timestamps (reflex games) | All timing decided server-side via authoritative server timestamp, not client clock |
| Impossible results (e.g. <100ms human reaction) | Statistical outlier detection in Cloud Functions; auto-flag for review or auto-void the round result |
| Replay / result resubmission | One-time submission tokens per round, idempotent Cloud Functions |
| Client tampering (Flutter client is inherently inspectable) | Treat the client as **semi-trusted only** — never trust a client-submitted score without a server-side plausibility check |
| Abuse/rate abuse on Cloud Functions | Per-user rate limiting on match/result submission endpoints |


---

# Reward System

- **Achievements, XP, Badges** — long-tail goals for retained players.

---

# Monetization

- **Rewarded Ads** — opt-in only, frequency-capped (e.g., max 1 per N minutes) to protect session flow; never forced mid-match.
- **Cosmetics / Emotes / Themes** — direct purchase.

**No Pay-to-Win.** Purchases must never affect gameplay speed, accuracy, or odds of winning — cosmetic and convenience only.

---

# Performance Targets

| Metric | Target |
|---|---|
| Room Join | < 1 sec |
| Realtime Update | < 150 ms |
| Frame Rate | 60 FPS |
| Crash-Free Rate | > 99.5% |

---

## Future Features

Friends List · Voice Chat · Spectator Mode · Replay · Season Events

---

## Success Metrics & KPI Targets

| Metric | Indicative Target |
|---|---|
| D1 Retention | 35–40% |
| D7 Retention | 15–20% |
| D30 Retention | 5–8% |
| Avg. Matches per DAU | 3+ |
| Avg. Session Length | 5–8 min (by design) |
| Crash-Free Rate | > 99.5% |
| Revenue (ARPDAU) | To be set after soft launch benchmarking |

---

# Design Philosophy

Simple. Fast. Competitive. Social. Replayable.
