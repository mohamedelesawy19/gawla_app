import {Timestamp} from "firebase-admin/firestore";

// ── Firestore collection names ──────────────────────────────────────────────
// NOTE: adjust if these don't match `firestore_constants.dart`.
export const TOURNAMENTS_COLLECTION = "tournaments";
export const ROOMS_COLLECTION = "rooms";

// Private, server-only subcollection (per-tournament) used to hold duel
// commit payloads between the two duelists' submissions. Nothing outside
// Cloud Functions (running under the Admin SDK, which bypasses security
// rules) may ever read this collection.
//
// IMPORTANT: this requires a matching Firestore security rule —
// `match /tournaments/{id}/_duelCommits/{doc} { allow read, write: if false; }`
// — which lives outside this file's scope (rules.rules file wasn't part of
// the provided set) but MUST be added alongside this change, or the
// commit-then-reveal guarantee `MINI_GAMES_LIBRARY.md §4.6` requires is
// void.
export const DUEL_COMMITS_SUBCOLLECTION = "_duelCommits";

// Top-level, server-only collection holding the full Quick Trivia /
// True-or-False question bank. Same rationale as `_duelCommits`: this must
// never be directly readable by a client, or `MINI_GAMES_LIBRARY.md §3.2`'s
// "never shipped in the client build" anti-cheat requirement is void —
// `fetchQuizPool` (see `tournament/mini_games/quiz/fetch_quiz_pool.ts`) is
// the ONLY sanctioned way a player's device ever sees a question from this
// collection, and only a small per-round slice of it at a time.
//
// IMPORTANT: needs a matching Firestore security rule —
// `match /quizQuestionPools/{doc} { allow read, write: if false; }` —
// added alongside this change, same as the `_duelCommits` rule above.
export const QUIZ_QUESTION_POOLS_COLLECTION = "quizQuestionPools";

// ── Enum-like string literals ────────────────────────────────────────────────
// NOTE: these MUST match `tournament_enums.dart` member-for-member, since
// the Flutter side parses them with `EnumType.values.byName(...)`, which
// throws on any mismatch. Update these (and the maps below) if your real
// enum members differ. Deliberately camelCase (not the snake_case ids used
// in MINI_GAMES_LIBRARY.md's taxonomy table) to stay consistent with the
// existing `TournamentStatus`/`RoundStatus` convention below — the
// snake_case ids in the library doc are a documentation convention for the
// spec, not a literal wire-format requirement.
export type TournamentStatus =
  | "starting"
  | "inProgress"
  | "completed"
  | "cancelled";
export type RoundStatus = "pending" | "active" | "completed";
export type TournamentPlayerStatus = "active" | "eliminated" | "winner";
export type RoomStatus = "waiting" | "starting" | "inProgress" | "closed";

/**
 * Mirrors `MINI_GAMES_LIBRARY.md §1`'s elimination taxonomy. This is the
 * single dimension the whole refactor pivots on: instead of the Tournament
 * engine hardcoding one elimination formula, every round declares which of
 * these six it uses, and `getEliminationStrategy()` (see
 * `elimination/elimination_strategy_registry.ts`) picks the matching
 * implementation. Adding a 7th type later means adding one enum member +
 * one strategy file, never touching `tournament_round_closer.ts`.
 */
export type EliminationType =
  | "rankCutoff"
  | "binaryFail"
  | "duelLoser"
  | "survivalFail"
  | "teamLoss"
  | "compositeFinal";

export type EliminationTargetKind = "count" | "percentage";

export const TOURNAMENT_STATUS: Record<string, TournamentStatus> = {
  starting: "starting",
  inProgress: "inProgress",
  completed: "completed",
  cancelled: "cancelled",
};

export const ROUND_STATUS: Record<string, RoundStatus> = {
  pending: "pending",
  active: "active",
  completed: "completed",
};

export const PLAYER_STATUS: Record<string, TournamentPlayerStatus> = {
  active: "active",
  eliminated: "eliminated",
  winner: "winner",
};

export const ROOM_STATUS: Record<string, RoomStatus> = {
  waiting: "waiting",
  starting: "starting",
  inProgress: "inProgress",
  closed: "closed",
};

export const ELIMINATION_TYPE: Record<string, EliminationType> = {
  rankCutoff: "rankCutoff",
  binaryFail: "binaryFail",
  duelLoser: "duelLoser",
  survivalFail: "survivalFail",
  teamLoss: "teamLoss",
  compositeFinal: "compositeFinal",
};

// ── Room status strings ─────
export const ROOM_STATUS_IN_PROGRESS = "inProgress";
export const ROOM_STATUS_WAITING = "waiting";

// ── Tunable gameplay constants ─────
// Total room capacity — humans + bots combined. Must match
// `RoomConstants.maxPlayersPerRoom` on the Flutter side (see
// `room_constants.dart`), same as every enum in this file must match its
// Dart mirror. Every *other* room-capacity check has historically lived
// entirely in the Flutter client's own Firestore transaction
// (`_joinRoomTransaction` in `room_remote_data_source.dart`), since only a
// human ever added a player before bots existed; `fillRoomWithBot` (see
// `../bots/fill_room_with_bot.ts`) is the first Cloud-Functions-side code
// that needs this number, so it's defined once here rather than
// hardcoded in the bots domain.
export const MAX_PLAYERS_PER_ROOM = 64;
export const MIN_PLAYERS_TO_START = 2;

// Fallback only — used by `mini_game_catalog.ts` when Remote Config has no
// entry for a game yet. Real round timing now comes from each round's own
// `MiniGameConfig.roundDurationSec` (see §Gap 5 in ARCHITECTURE_ANALYSIS.md);
// nothing in the round-closing path reads this constant directly anymore.
export const FALLBACK_ROUND_DURATION_MS = 45_000;
// Fallback elimination fraction for `rankCutoff` games with no catalog
// entry. Same rationale as above — no longer a single global applied to
// every round.
export const FALLBACK_ELIMINATION_FRACTION = 0.35;
export const MIN_SURVIVORS_PER_ROUND = 1; // never eliminate down to 0

// ── Firestore document shapes (mirror the Dart models 1:1) ──────────────────

export interface EliminationTargetDoc {
  kind: EliminationTargetKind;
  value: number; // count -> integer; percentage -> 0..1 fraction
}

/**
 * Server-resolved, round-scoping configuration for one mini-game instance.
 * Resolved once per round (see `mini_game_catalog.ts`) from Remote Config
 * so game balance (duration, cut %) can be tuned without an app release —
 * `PROJECT_OVERVIEW.md`'s "configuration-driven gameplay" requirement.
 */
export interface MiniGameConfig {
  gameId: string;
  roundDurationSec: number;
  eliminationType: EliminationType;
  // Not every elimination type needs this (binaryFail/survivalFail/
  // duelLoser/compositeFinal are intrinsic — see each strategy's doc
  // comment). rankCutoff always uses it; teamLoss uses it optionally to
  // switch from "eliminate the whole losing team" to "eliminate its N
  // weakest contributors".
  eliminationTarget: EliminationTargetDoc | null;
  difficultyModifier: number | null;
}

export interface RoundResultDoc {
  uid: string;
  // Meaningful for rankCutoff / teamLoss (higher = better, already
  // normalized — see `mini_games/mini_game_definition.ts`). `null` for
  // elimination types that resolve via `passed` instead.
  score: number | null;
  // Meaningful for binaryFail / survivalFail / duelLoser. `null` while a
  // duel is still awaiting the opponent's commit, or simply unused by
  // score-driven types.
  passed: boolean | null;
  // 1-based placement within the round. Populated once the round closes;
  // its *scope* (global rank vs. within-duel vs. within-team) depends on
  // the elimination type, purely for UI/analytics — never authoritative
  // for elimination itself (`passed`/membership in `eliminatedUids` is).
  rank: number | null;
  eliminated: boolean;
  submittedAt: Timestamp | null;
  // Set by `start_tournament.ts` / `tournament_round_closer.ts` from
  // `TournamentRoundDoc.groupAssignments` at submission time — which duel
  // pair or team this result belongs to. `null` for ungrouped elimination
  // types.
  groupId: string | null;
  // Game-specific, safe-to-reveal display data set only AFTER elimination
  // is resolved (e.g. both duelists' choices, for the reveal animation).
  // Deliberately untyped/opaque so adding a new mini-game never requires
  // widening this doc's schema.
  metadata: Record<string, unknown> | null;
}

export interface TournamentRoundDoc {
  roundIndex: number;
  // Full resolved config, not a bare id — see `MiniGameConfig` above. The
  // gameId itself still lives at `miniGameConfig.gameId`.
  miniGameConfig: MiniGameConfig;
  status: RoundStatus;
  startedAt: Timestamp | null;
  endsAt: Timestamp | null;
  results: RoundResultDoc[];
  // uid -> groupId. Assigned by the elimination strategy's `prepareGroups`
  // when the round is activated, so clients know their duel opponent / team
  // before they have to act. `null` for ungrouped elimination types
  // (rankCutoff, binaryFail, survivalFail, compositeFinal in its MVP form).
  groupAssignments: Record<string, string> | null;
}

export interface TournamentPlayerDoc {
  displayName: string;
  avatarUrl: string | null;
  status: TournamentPlayerStatus;
  eliminatedAtRoundIndex: number | null;
  finalPlacement: number | null;
  // Denormalized from `isBotUid(uid)` at snapshot time (see
  // `start_tournament.ts`), purely so reward/economy code and analytics
  // can filter bots out with a plain field read instead of every caller
  // needing to import `bots/bot_identity.ts` and re-derive it from the
  // key. NOT authoritative — `isBotUid(uid)` is always the source of
  // truth; this field exists only to make "was this participant a bot"
  // cheap to query/aggregate without re-deriving it everywhere.
  isBot: boolean;
}

export interface TournamentDoc {
  roomId: string;
  hostUid: string;
  status: TournamentStatus;
  // Still just ids — "which games, in what order" is a lighter-weight,
  // index-level fact than a round's full config, and lobby-facing UI (e.g.
  // showing upcoming game icons) shouldn't need a resolved config to do
  // that. The authoritative per-round config lives on
  // `TournamentRoundDoc.miniGameConfig`.
  miniGameRotation: string[];
  currentRoundIndex: number;
  rounds: TournamentRoundDoc[];
  // Map keyed by uid, mirroring `RoomModel.players` — not an array. See
  // `TournamentPlayerModel.toFirestore()` on the Flutter side.
  players: Record<string, TournamentPlayerDoc>;
  winnerUid: string | null;
  createdAt: Timestamp;
  completedAt: Timestamp | null;
  // Denormalized copy of `rounds[currentRoundIndex].endsAt`, kept in sync by
  // `startTournament` and `closeRound`. NOT read by `TournamentModel` on the
  // Flutter side (harmless extra field) — it exists purely so
  // `advanceStaleTournamentRounds` can query directly instead of scanning
  // every in-progress tournament's rounds array in memory.
  currentRoundEndsAt: Timestamp | null;
}

/**
 * One question in a Quick Trivia / True-or-False pool, as stored in
 * `QUIZ_QUESTION_POOLS_COLLECTION`. Only `fetchQuizPool` ever reads this
 * collection — see that constant's doc comment for why it must stay
 * server-only.
 */
export interface QuizQuestionDoc {
  prompt: string;
  options: string[];
  correctIndex: number;
  seasonId: string;
}

export const CONFIG_COLLECTION = "config";
export const QUIZ_POOL_SEASONS_CONFIG_DOC = "quizPoolSeasons";
export type QuizPoolSeasonsConfigDoc = Record<string, string>;

// ── Room doc shape ────────────────────────────────────────────────────────
// `players` on the real `RoomModel` is a Firestore map keyed by uid
// (`RoomPlayerModel.toFirestore()` omits `uid`) — mirrored here.
export interface RoomSnapshot {
  hostUid: string;
  status: string;
  miniGameRotation: string[];
  players: Array<{uid: string; displayName: string; avatarUrl?: string | null}>;
}

/**
 * Converts a Firestore room document into the shape used by the function.
 *
 * @param {FirebaseFirestore.DocumentData} data The raw room document data.
 * @return {RoomSnapshot} The normalized snapshot.
 */
export function parseRoomSnapshot(
  data: FirebaseFirestore.DocumentData,
): RoomSnapshot {
  const playersMap =
    (data.players ?? {}) as Record<string, Record<string, unknown>>;
  const settings = (data.settings ?? {}) as Record<string, unknown>;

  return {
    hostUid: data.hostUid,
    status: data.status,
    miniGameRotation:
    (settings.miniGameRotation as string[] | undefined) ?? [],
    players: Object.entries(playersMap).map(([uid, p]) => ({
      uid,
      displayName: (p.displayName as string) ?? "Player",
      avatarUrl: (p.avatarUrl as string | null | undefined) ?? null,
    })),
  };
}
