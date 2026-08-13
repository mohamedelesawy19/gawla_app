import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions/v2";

initializeApp();

setGlobalOptions({
  region: "europe-west6",
  maxInstances: 10,
});

export {onUserCreated} from "./players/on_user_created";
export {startTournament} from "./tournament/start_tournament";
export {submitRoundResult} from "./tournament/submit_round_result";
export {
  advanceStaleTournamentRounds,
} from "./tournament/advance_stale_tournament_rounds";
export {
  driveTugOfPowerRound,
} from "./tournament/mini_games/tug_of_power/drive_tug_of_power_round";
export {
  driveFreezeFrenzyRound,
} from "./tournament/mini_games/freeze_frenzy/drive_freeze_frenzy_round";
export {
  fetchQuizPool,
} from "./tournament/mini_games/quiz/fetch_quiz_pool";
export {
  scheduleBotFillOnRoomCreated,
} from "./bots/schedule_bot_fill_on_room_created";
export {fillRoomWithBot} from "./bots/fill_room_with_bot";
