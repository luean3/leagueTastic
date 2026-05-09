import {onRequest} from "firebase-functions/https";
import * as admin from "firebase-admin";

export const getCurrentChallengeState = onRequest(async (req, res) => {
    const challengeId = req.query.challengeId as string;

    const db = admin.firestore();

    const challengeSnap = await db
        .collection("challenges")
        .doc(challengeId)
        .get();

    if (!challengeSnap.exists) {
        res.status(404).send("not found");
        return;
    }

    const challenge = challengeSnap.data();

    const segmentsSnap = await db
        .collection("challengeSegments")
        .where("challengeId", "==", challengeId)
        .get();

    const segments = segmentsSnap.docs.map(d => d.data());

    const now = new Date();

    const current = segments.find(s =>
        now >= s.startDate.toDate() &&
        now <= s.endDate.toDate()
    );

    if (!current) {
        res.json({challenge, currentSegment: null, leaderboard: []});
        return;
    }

    const leaderboardSnap = await db
        .collection("segmentLeaderboards")
        .doc(`${challengeId}_${current.segmentId}`)
        .collection("entries")
        .orderBy("bestTime", "asc")
        .limit(50)
        .get();

    res.json({
        challenge,
        currentSegment: current,
        leaderboard: leaderboardSnap.docs.map(d => d.data())
    });
});