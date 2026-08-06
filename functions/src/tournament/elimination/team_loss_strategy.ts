import {MiniGameConfig} from "../tournament_types";
import {
  EliminationDecision,
  EliminationStrategy,
  RoundParticipant,
} from "./elimination_strategy";
import {resolveEliminationCount} from "./elimination_utils";

/**
 * Team Result elimination (`MINI_GAMES_LIBRARY.md §1`, e.g. Tug of Power):
 * two teams compete; the losing team (lower aggregate score, e.g. total
 * tap count) is eliminated — either entirely, or just its weakest
 * contributors, per the round's config.
 *
 * Reuses `config.eliminationTarget` for this switch instead of adding a
 * bespoke field to `MiniGameConfig`: `null` target = eliminate the whole
 * losing team (the library doc's default reading); a target present =
 * "eliminate this many of the losing team's weakest contributors instead"
 * (`MINI_GAMES_LIBRARY.md §4.7`'s "keeps strong teammates alive" mode).
 */
export const teamLossStrategy: EliminationStrategy = {
  prepareGroups(activeUids: string[]): Record<string, string> | null {
    const shuffled = [...activeUids].sort(() => Math.random() - 0.5);
    const assignments: Record<string, string> = {};
    const midpoint = Math.ceil(shuffled.length / 2);
    shuffled.forEach((uid, i) => {
      assignments[uid] = i < midpoint ? "teamA" : "teamB";
    });
    return assignments;
  },

  resolve(
    participants: RoundParticipant[],
    config: MiniGameConfig,
  ): EliminationDecision {
    const teamA = participants.filter((p) => p.groupId === "teamA");
    const teamB = participants.filter((p) => p.groupId === "teamB");
    const sumScore = (team: RoundParticipant[]): number =>
      team.reduce((total, p) => total + (p.score ?? 0), 0);

    const [losingTeam, winningTeam] =
      sumScore(teamA) <= sumScore(teamB) ? [teamA, teamB] : [teamB, teamA];

    if (config.eliminationTarget === null) {
      // Whole-team elimination.
      return {
        eliminatedUids: losingTeam.map((p) => p.uid),
        rankedUids: [
          ...winningTeam.map((p) => p.uid),
          ...losingTeam.map((p) => p.uid),
        ],
      };
    }

    // Weakest-contributors mode: rank the losing team worst-first by
    // individual score and cut the configured count from it.
    const byScoreAsc = [...losingTeam].sort(
      (a, b) => (a.score ?? 0) - (b.score ?? 0),
    );
    const cutCount = resolveEliminationCount(
      config.eliminationTarget,
      losingTeam.length,
    );
    const eliminated = byScoreAsc.slice(0, cutCount);
    const spared = byScoreAsc.slice(cutCount);

    return {
      eliminatedUids: eliminated.map((p) => p.uid),
      rankedUids: [
        ...winningTeam.map((p) => p.uid),
        ...spared.map((p) => p.uid),
        ...eliminated.map((p) => p.uid),
      ],
    };
  },
};
