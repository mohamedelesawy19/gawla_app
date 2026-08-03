import {Timestamp} from "firebase-admin/firestore";

// ── Firestore collection names ──────────────────────────────────────────────
// NOTE: adjust if these don't match `firestore_constants.dart`.
export const TOURNAMENTS_COLLECTION = "tournaments";
export const ROOMS_COLLECTION = "rooms";

// ── Enum-like string literals ────────────────────────────────────────────────
// NOTE: these MUST match `tournament_enums.dart` member-for-member, since
// the Flutter side parses them with `EnumType.values.byName(...)`, which
// throws on any mismatch. Update these (and the maps below) if your real
// enum members differ.
export type TournamentStatus = "starting" | "inProgress" | "completed" | "cancelled";
export type RoundStatus = "pending" | "active" | "completed";
export type TournamentPlayerStatus = "active" | "eliminated" | "winner";

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

// ── Room status strings ─────
export const ROOM_STATUS_IN_PROGRESS = "inProgress";
export const ROOM_STATUS_WAITING = "waiting";

// ── Tunable gameplay constants ─────
export const MIN_PLAYERS_TO_START = 2;
export const DEFAULT_ROUND_DURATION_MS = 60_000; // 60s/round; tune freely
export const ELIMINATION_FRACTION = 0.25; // cut the worst 25% of active players each round
export const MIN_SURVIVORS_PER_ROUND = 1; // never eliminate down to 0

// ── Firestore document shapes (mirror the Dart models 1:1) ──────────────────

export interface TournamentPlayerDoc {
  displayName: string;
  avatarUrl: string | null;
  status: TournamentPlayerStatus;
  eliminatedAtRoundIndex: number | null;
  finalPlacement: number | null;
}

export interface RoundResultDoc {
  uid: string;
  score: number | null;
  rank: number | null;
  eliminated: boolean;
  submittedAt: Timestamp | null;
}

export interface TournamentRoundDoc {
  roundIndex: number;
  miniGameId: string;
  status: RoundStatus;
  startedAt: Timestamp | null;
  endsAt: Timestamp | null;
  results: RoundResultDoc[];
}

export interface TournamentDoc {
  roomId: string;
  hostUid: string;
  status: TournamentStatus;
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

// ── Room doc shape ────────────────────────────────────────────────────────
// `players` on the real `RoomModel` is a Firestore map keyed by uid
// (`RoomPlayerModel.toFirestore()` omits `uid`) — mirrored here.
export interface RoomSnapshot {
  hostUid: string;
  status: string;
  miniGameRotation: string[];
  players: Array<{uid: string; displayName: string; avatarUrl?: string | null}>;
}

export function parseRoomSnapshot(data: FirebaseFirestore.DocumentData): RoomSnapshot {
  const playersMap = (data.players ?? {}) as Record<string, Record<string, unknown>>;
  return {
    hostUid: data.hostUid,
    status: data.status,
    miniGameRotation: data.miniGameRotation ?? [],
    players: Object.entries(playersMap).map(([uid, p]) => ({
      uid,
      displayName: (p.displayName as string) ?? "Player",
      avatarUrl: (p.avatarUrl as string | null | undefined) ?? null,
    })),
  };
}
