import {MiniGameConfig} from "../tournament_types";

/** A single active player's resolved outcome for the round being closed. */
export interface RoundParticipant {
  uid: string;
  // Higher = better. `null` if this game's elimination type doesn't use a
  // score, or the player didn't submit / submitted an implausible payload.
  score: number | null;
  // `true`/`false` for pass-fail games. `null` if this game's elimination
  // type doesn't use pass/fail, or the player didn't submit.
  passed: boolean | null;
  // uid -> groupId assignment from `TournamentRoundDoc.groupAssignments`,
  // or `null` for ungrouped elimination types.
  groupId: string | null;
}

export interface EliminationDecision {
  eliminatedUids: string[];
  // Best -> worst, for `rank` display purposes only. Its *scope* (global,
  // within-duel, within-team) is strategy-defined; never authoritative for
  // elimination — `eliminatedUids` is.
  rankedUids: string[];
}

/**
 * One implementation per `EliminationType` in `MINI_GAMES_LIBRARY.md §1`.
 * `tournament_round_closer.ts` is elimination-type-agnostic: it always
 * calls `prepareGroups` when a round activates and `resolve` when a round
 * closes, and never contains type-specific branching itself. This is the
 * seam that lets "which rule cuts the pool" vary per mini-game without the
 * Tournament engine needing to know about any of them individually — the
 * central requirement `MINI_GAMES_LIBRARY.md §1` describes.
 */
export interface EliminationStrategy {
  /**
   * Called once, when a round becomes the active round, before any
   * submissions exist. Lets duel/team-style strategies assign pairings or
   * teams up front so the round's UI can render "you vs. X" / "Team Blue"
   * before anyone acts. Strategies with no grouping concept return `null`.
   */
  prepareGroups(
    activeUids: string[],
    config: MiniGameConfig,
  ): Record<string, string> | null;

  /**
   * Called once a round is ready to close (either every active player
   * submitted, or the round timed out — see `advance_stale_tournament_
   * rounds.ts`). Must be a pure function of its inputs so both closing
   * paths behave identically. Participants with `score === null &&
   * passed === null` represent a no-show (never submitted, or a duel that
   * never resolved before timeout) and every built-in strategy treats that
   * as an automatic loss — a round timing out can never leave someone
   * ambiguously un-eliminated.
   */
  resolve(
    participants: RoundParticipant[],
    config: MiniGameConfig,
  ): EliminationDecision;
}
