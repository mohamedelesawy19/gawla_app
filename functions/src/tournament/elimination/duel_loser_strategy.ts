import {binaryFailStrategy} from "./binary_fail_strategy";
import {MiniGameConfig} from "../tournament_types";
import {
  EliminationDecision,
  EliminationStrategy,
  RoundParticipant,
} from "./elimination_strategy";

/**
 * Duel elimination (`MINI_GAMES_LIBRARY.md §1`): players paired 1v1, loser
 * of each pairing eliminated.
 *
 * `prepareGroups` randomly pairs up the active pool into 2-player groups.
 * An odd pool gets one bye: the leftover player is left out of
 * `groupAssignments` entirely (`groupId: null` for them), and `resolve`
 * treats an ungrouped participant in a duel round as an automatic pass —
 * nobody to lose to.
 *
 * `resolve` itself is intentionally identical to `binaryFailStrategy`:
 * by the time a round closes, each duelist's `passed` has already been
 * decided the moment the *second* member of their pair submitted — see
 * `submit_round_result.ts`'s eager pairwise resolution, which exists
 * specifically so a duel's raw choices are compared inside one atomic
 * transaction and never persisted anywhere client-readable pre-reveal
 * (the "commit-then-reveal... never let a client see the opponent's
 * choice before its own is submitted" requirement from
 * `MINI_GAMES_LIBRARY.md §4.6`). A tie is handled there too (both
 * duelists' entries are left off `round.results` so they can re-duel;
 * if the round times out before they do, the no-show rule below is what
 * ultimately eliminates them both — see that file for the full flow).
 */
export const duelLoserStrategy: EliminationStrategy = {
  prepareGroups(activeUids: string[]): Record<string, string> | null {
    const shuffled = [...activeUids].sort(() => Math.random() - 0.5);
    const assignments: Record<string, string> = {};
    let duelIndex = 0;
    for (let i = 0; i + 1 < shuffled.length; i += 2) {
      const groupId = `duel_${duelIndex++}`;
      assignments[shuffled[i]] = groupId;
      assignments[shuffled[i + 1]] = groupId;
    }
    // Odd player out: deliberately omitted from `assignments` (bye).
    return assignments;
  },

  resolve(
    participants: RoundParticipant[],
    config: MiniGameConfig,
  ): EliminationDecision {
    // A bye (groupId null) always survives; everyone else follows the
    // ordinary pass/fail rule already resolved at submission time.
    const withByesPassing = participants.map((p) =>
      p.groupId === null ? {...p, passed: true} : p,
    );
    return binaryFailStrategy.resolve(withByesPassing, config);
  },
};
