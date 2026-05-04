import { onDocumentCreated } from "firebase-functions/firestore";
import * as admin from "firebase-admin";

export const onSegmentEffortCreated = onDocumentCreated(
    "segmentEfforts/{id}",
    async (event) => {
        const data = event.data?.data();
        if (!data) return;

        const {
            segmentId,
            userId,
            elapsedTime
        } = data;

        if (!segmentId || !userId || typeof elapsedTime !== "number") {
            console.log("Invalid payload:", data);
            return;
        }

        const db = admin.firestore();

        // =========================
        // 1. aktive Challenge des Users holen
        // =========================
        const userChallengesSnap = await db
            .collection("userChallenges")
            .where("userId", "==", userId)
            .where("active", "==", true)
            .get();

        if (userChallengesSnap.empty) {
            console.log("No active challenge for user:", userId);
            return;
        }

        // (falls mehrere aktiv → später sortieren nach startDate)
        const userChallenge = userChallengesSnap.docs[0].data();
        const challengeId = userChallenge.challengeId;

        // =========================
        // 2. prüfen ob Segment zur Challenge gehört
        // =========================
        const segmentSnap = await db
            .doc(`challengeSegments/${challengeId}_${segmentId}`)
            .get();

        if (!segmentSnap.exists) {
            console.log("Segment not part of challenge");
            return;
        }

        // =========================
        // 🟢 SEGMENT LEADERBOARD
        // =========================
        const segRef = db
            .collection("segmentLeaderboards")
            .doc(`${challengeId}_${segmentId}`)
            .collection("entries")
            .doc(userId);

        const segSnap = await segRef.get();

        const currentBest = segSnap.exists
            ? Number(segSnap.data()?.bestTime ?? Number.MAX_SAFE_INTEGER)
            : Number.MAX_SAFE_INTEGER;

        const bestTime = Math.min(currentBest, elapsedTime);

        await segRef.set(
            {
                userId,
                segmentId,
                bestTime,
                updatedAt: Date.now()
            },
            { merge: true }
        );

        // =========================
        // 🏆 CHALLENGE LEADERBOARD
        // =========================
        const chRef = db
            .collection("challengeLeaderboards")
            .doc(challengeId)
            .collection("entries")
            .doc(userId);

        const chSnap = await chRef.get();

        const currentTotal = chSnap.exists
            ? Number(chSnap.data()?.totalTime ?? 0)
            : 0;

        await chRef.set(
            {
                userId,
                totalTime: currentTotal + elapsedTime,
                updatedAt: Date.now()
            },
            { merge: true }
        );
    }
);