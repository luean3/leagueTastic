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

            const startDate = segmentData.startDate?.toDate?.();
            const endDate = segmentData.endDate?.toDate?.();

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

    if (currentSegment) {
        const leaderboardSnap = await db
            .collection("segmentLeaderboards")
            .doc(`${challengeId}_${currentSegment.segmentId}`)
            .collection("entries")
            .orderBy("bestTime", "asc")
            .limit(50)
            .get();

        leaderboard = leaderboardSnap.docs.map((d) => d.data());
    }

    return {
        challenge,
        segments,
        currentSegment,
        leaderboard,
    };
});