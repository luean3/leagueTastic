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
        // 1. Get user's active challenge
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

        const userChallenge = userChallengesSnap.docs[0].data();
        const challengeId = userChallenge.challengeId;

        // =========================
        // 2. Check if segment belongs to challenge
        // =========================
        const segmentSnap = await db
            .doc(`challengeSegments/${challengeId}_${segmentId}`)
            .get();

        if (!segmentSnap.exists) {
            console.log("Segment not part of challenge");
            return;
        }

        // =========================
        // 3. Update Segment Best Time
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

        // If the new time isn't faster than their current best, ranks won't change
        if (elapsedTime >= currentBest) {
            return;
        }

        await segRef.set(
            {
                userId,
                segmentId,
                bestTime: elapsedTime,
                updatedAt: Date.now()
            },
            { merge: true }
        );

        // =========================
        // 4. Recalculate Points & Ranks for ALL users in this segment
        // =========================

        // Fetch all entries for this segment, sorted by fastest time
        const allEntriesSnap = await db
            .collection("segmentLeaderboards")
            .doc(`${challengeId}_${segmentId}`)
            .collection("entries")
            .orderBy("bestTime", "asc")
            .get();

        const totalUsers = allEntriesSnap.size;

        const batches: admin.firestore.WriteBatch[] = [db.batch()];
        let batchIndex = 0;
        let opCount = 0;

        let currentRank = 1;
        let actualIndex = 1;
        let previousTime = -1;

        allEntriesSnap.docs.forEach((docSnap) => {
            const entryData = docSnap.data();
            const time = entryData.bestTime;
            const oldPoints = entryData.points || 0;

            // Handle Ties
            if (time === previousTime) {
                // Keep currentRank the same as the previous user
            } else {
                currentRank = actualIndex;
            }
            previousTime = time;
            actualIndex++;

            // Calculate new points (Last place gets 1 point)
            const newPoints = totalUsers - currentRank + 1;
            const pointDifference = newPoints - oldPoints;

            const currentBatch = batches[batchIndex];

            // A. Update the user's points for this specific segment
            currentBatch.update(docSnap.ref, {
                points: newPoints,
                rank: currentRank
            });

            // B. Update the user's total score in the global challenge leaderboard
            const challengeEntryRef = db
                .collection("challengeLeaderboards")
                .doc(challengeId)
                .collection("entries")
                .doc(entryData.userId);

            currentBatch.set(
                challengeEntryRef,
                {
                    userId: entryData.userId,
                    totalPoints: admin.firestore.FieldValue.increment(pointDifference),
                    updatedAt: Date.now()
                },
                { merge: true }
            );

            opCount += 2;

            if (opCount >= 400) {
                batches.push(db.batch());
                batchIndex++;
                opCount = 0;
            }
        });

        for (const batch of batches) {
            await batch.commit();
        }

        console.log(`Successfully updated leaderboards for ${totalUsers} users in segment ${segmentId}`);
    }
);