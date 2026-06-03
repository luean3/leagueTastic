import { onCall } from "firebase-functions/https";
import * as admin from "firebase-admin";

export const getCurrentChallengeState = onCall(async (request) => {
    const { challengeId } = request.data;

    if (!challengeId) {
        throw new Error("missing challengeId");
    }

    const db = admin.firestore();

    // 1. Challenge laden
    const challengeSnap = await db
        .collection("challenges")
        .doc(challengeId)
        .get();

    if (!challengeSnap.exists) {
        throw new Error("challenge not found");
    }

    const challenge = challengeSnap.data();

    // 2. Mapping laden (challengeSegments)
    const mappingSnap = await db
        .collection("challengeSegments")
        .where("challengeId", "==", challengeId)
        .orderBy("weekIndex")
        .get();

    const now = new Date();

    // 3. Segment-Details nachladen (WICHTIG!)
    const segments = await Promise.all(
        mappingSnap.docs.map(async (d) => {
            const mapping = d.data();

            const segmentSnap = await db
                .collection("segments")
                .doc(String(mapping.segmentId))
                .get();

            const segmentData = segmentSnap.data() || {};

            const startDate = mapping.startDate?.toDate?.();
            const endDate = mapping.endDate?.toDate?.();

            const isActive =
                startDate &&
                endDate &&
                now >= startDate &&
                now <= endDate;

            const isPast = endDate && now > endDate;
            const isUpcoming = startDate && now < startDate;

            return {
                ...segmentData,      // 👈 echte Segmentdaten
                ...mapping,          // weekIndex etc.
                isActive: !!isActive,
                isPast: !!isPast,
                isUpcoming: !!isUpcoming,
            };
        })
    );

    // 4. aktuelles Segment finden
    const currentSegment = segments.find((s) => s.isActive) as any|| null;

    let leaderboard: any[] = [];


    const challengeLeaderboardSnap = await db
        .collection("challengeLeaderboards")
        .doc(challengeId)
        .collection("entries")
        .orderBy("totalPoints", "desc")
        .limit(50)
        .get();

    leaderboard = challengeLeaderboardSnap.docs.map((d) => d.data());

    return {
        challenge,
        segments,
        currentSegment,
        leaderboard,
    };
});