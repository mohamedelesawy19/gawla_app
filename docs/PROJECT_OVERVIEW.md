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

---

# Core Principles

- Matches last 5–8 minutes.
- Every tournament contains multiple mini-games.
- Each mini-game lasts 30–90 seconds.
- Players are eliminated after each round.
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

```
24 Players
  ↓ Reaction Challenge
18 Players
  ↓ Memory Challenge
12 Players
  ↓ Trivia Challenge
8 Players
  ↓ Find the Difference
4 Players
  ↓ Final Challenge
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

## MVP Set

| Mini-Game | Skill Type | Cheat Risk | Notes |
|---|---|---|---|
| Reaction Tap | Reflex | High — timestamp spoofing | Requires server-authoritative timing |
| Quick Trivia | Knowledge | Medium | Answer pool must rotate to prevent memorization/sharing |
| Memory Cards | Memory | Low | — |
| Find the Difference | Precision/Perception | Low | — |
| Color Challenge | Reflex/Attention | Medium | Same timing risk as Reaction Tap |
| Math Rush | Knowledge/Speed | Medium | Watch for calculator/macro assistance |
| Sequence Order | Memory | Low | — |
| Speed Typing | Precision/Speed | Medium | Device keyboard latency varies — needs normalization |
| True or False | Knowledge | Low | — |
| Hidden Object | Perception | Low | — |

## Future Mini-Games

- Drawing Guess
- Bluff Game
- Spy Game
- Geography Challenge
- Audio Guess
- Emoji Puzzle
- Pattern Memory
- Team Battle
- Boss Round

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
