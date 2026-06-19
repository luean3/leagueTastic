// index.ts
import * as admin from "firebase-admin";
import {onCall} from "firebase-functions/https";


admin.initializeApp();

export { stravaWebhook } from "./handlers/stravaWebhook";
export { stravaCallback } from "./handlers/stravaCallback";
export { getSegmentLeaderboard } from "./handlers/leaderboard";
export { exploreSegments } from "./handlers/exploreSegments";
export { getSegment } from "./handlers/segmentById";
export { onSegmentEffortCreated } from "./services/calculateLeaderboard";
export { createChallenge } from "./handlers/createChallenge";
export { getCurrentChallengeState } from "./handlers/getCurrentChallenge";
export { processActivity } from "./handlers/fetchActivtyOnJob";
export { getSegments } from "./handlers/getSegments";



export const cloneAndAlterDoc = onCall(async () => {
    await admin.firestore().collection("jobs").add({
        type: "processActivity",
        activityId: 18772902867,
        athleteId: 58272432,
        createdAt: Date.now()
    });
});