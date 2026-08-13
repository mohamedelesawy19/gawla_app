# Cloud Functions — structure

Feature-first layout. Each top-level folder under `src/` is a domain; nothing
outside `shared/` is imported across domains except through explicit,
narrow interfaces (e.g. `tournament/elimination`'s `EliminationStrategy`).

```
functions/
├── src/
│   ├── index.ts                     # Deployed entry points only — re-exports, no logic
│   ├── shared/                      # Cross-domain infrastructure, nothing domain-specific
│   │   ├── firestore.ts             #   shared `db` client
│   │   └── rtdb.ts                  #   shared `rtdb` client
│   ├── players/                     # Player-profile domain (grows with rewards/bots-style features)
│   │   └── on_user_created.ts
│   └── tournament/                  # Tournament domain
│       ├── tournament_types.ts      # Firestore doc shapes + enums (the domain's public contract)
│       ├── mini_game_catalog.ts     # Remote Config → MiniGameConfig resolution
│       ├── start_tournament.ts      # onCall: room → tournament
│       ├── submit_round_result.ts   # onCall: player result submission + duel commit/reveal
│       ├── advance_stale_tournament_rounds.ts  # onSchedule: force-close timed-out rounds
│       ├── tournament_round_closer.ts          # shared close/advance orchestration
│       ├── elimination/             # One EliminationStrategy per EliminationType
│       │   ├── elimination_strategy.ts          # interface
│       │   ├── elimination_strategy_registry.ts # type -> strategy lookup
│       │   ├── elimination_utils.ts
│       │   ├── rank_cutoff_strategy.ts
│       │   ├── binary_fail_strategy.ts
│       │   ├── survival_fail_strategy.ts
│       │   ├── duel_loser_strategy.ts
│       │   ├── team_loss_strategy.ts
│       │   └── composite_final_strategy.ts
│       └── mini_games/              # One MiniGameDefinition per game id, by elimination family
│           ├── mini_game_definition.ts          # interface
│           ├── mini_game_registry.ts             # gameId -> definition lookup
│           ├── scored_games.ts
│           ├── binary_fail_games.ts
│           ├── survival_games.ts
│           ├── team_games.ts
│           ├── duel_games.ts
│           ├── tug_of_power/drive_tug_of_power_round.ts     # RTDB live-meter driver
│           ├── freeze_frenzy/drive_freeze_frenzy_round.ts   # server-owned round clock
│           └── quiz/fetch_quiz_pool.ts                      # server-only question pool access
├── scripts/                         # One-off maintenance tools — NOT part of the deployed bundle
│   ├── seed_quiz_questions.ts
│   └── data/
│       ├── quick_trivia_questions.ts
│       └── true_or_false_questions.ts
├── package.json
├── tsconfig.json                    # `include: ["src/**/*.ts"]` — scripts/ is deliberately excluded
└── scripts/tsconfig.json            # separate config so the seed script can still import from src/
```

## What changed, and why

This preserves every deployed function name, every Firestore contract, and
every behavior. The changes are purely organizational:

1. **`on_user_created.ts` moved into `players/`.** It was the one function
   living at the `src/` root with no domain folder. Giving it a `players/`
   home (matching the `players` collection it writes to) makes the
   feature-per-folder convention consistent, and gives future player-facing
   features (rewards, bots, profile updates, ...) an obvious place to land
   as siblings of `tournament/` instead of another root-level file.

2. **`seed_quiz_questions.ts` (+ its data files) moved to a top-level
   `scripts/` folder, outside `src/`.** It's a standalone maintenance
   script — it calls `initializeApp()` with its own service-account
   credential and talks to Firestore directly, unlike everything in `src/`,
   which runs *inside* a Cloud Function under the ambient Admin SDK
   identity. It was never wired into `index.ts` and never should be
   deployed; keeping it inside `src/` only worked because nothing forced
   the distinction. Now `tsconfig.json`'s `include` only covers `src/**`,
   so the deployed bundle can never accidentally pull in a script that
   expects a local `serviceAccountKey.json` (which is `.gitignore`d and
   isn't part of this changeset).

3. **New `shared/firestore.ts` and `shared/rtdb.ts`.** Six different files
   each called `getFirestore()` (or `getDatabase()`) independently to get a
   client that's already a singleton inside the Admin SDK — harmless at
   runtime, but it meant "how do I get `db`" had six near-identical
   answers instead of one. Every call site now imports `db`/`rtdb` from
   `shared/`, which also gives the project one place to adjust later (a
   named database, emulator wiring, a test double) without touching every
   feature file.

4. **Everything else kept its existing name, content, and relative
   structure.** The `tournament/elimination/` and `tournament/mini_games/`
   folders, the strategy/definition registries, and `tournament_types.ts`
   as the domain's shared contract were already well-factored — one file
   per `EliminationType`/mini-game family, a single registry per axis, and
   the round closer staying elimination-type-agnostic. No new
   abstractions were introduced there; files were relocated as-is.

## Extending this later

- A **rewards** feature would be a new `src/rewards/` folder, same shape as
  `players/`, wired into `index.ts` the same way.
- A **bots** feature likely spans two places: bot *decision logic* as its
  own `src/bots/` domain, plus a thin call into `submitRoundResult`'s
  existing validation path — it should not need its own copy of the
  elimination/mini-game registries.
- A 7th `EliminationType` or mini-game id means adding one file to
  `elimination/` or `mini_games/` plus one registry entry — nothing in
  `tournament_round_closer.ts` or `submit_round_result.ts` changes, which
  was already true before this refactor and remains true after it.

## Verification performed

- `npx tsc --noEmit -p tsconfig.json` — no errors.
- `npm run build` — emits `lib/**` mirroring `src/**` 1:1.
- `require('./lib/index.js')` under minimal Firebase env config exports
  exactly the same 7 function names, in the same order, as the original
  `index.ts`: `onUserCreated`, `startTournament`, `submitRoundResult`,
  `advanceStaleTournamentRounds`, `driveTugOfPowerRound`,
  `driveFreezeFrenzyRound`, `fetchQuizPool`.
- `npx tsc --noEmit -p scripts/tsconfig.json` — no errors (verified with a
  throwaway credential stub in place of the real, untracked
  `serviceAccountKey.json`).
