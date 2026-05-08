// index.ts
import * as admin from "firebase-admin";
admin.initializeApp();

export {stravaWebhook} from "./handlers/stravaWebhook";
export {stravaCallback} from "./handlers/stravaCallback";
export {getSegmentLeaderboard} from "./handlers/leaderboard";
export {exploreSegments} from "./handlers/exploreSegments";
export {getSegment} from "./handlers/segmentById";
export {onSegmentEffortCreated} from "./services/calculateLeaderboard";
export {createChallenge} from "./handlers/createChallenge";
export {getCurrentChallengeState} from "./handlers/getCurrentChallenge";
export {processActivity} from "./handlers/fetchActivtyOnJob"