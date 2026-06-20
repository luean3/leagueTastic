import { onDocumentCreated } from "firebase-functions/firestore";
import * as admin from "firebase-admin";

export const onSegmentEffortCreated = onDocumentCreated(
    "segmentEfforts/{id}",
    async (event) => {
        console.log("onSegmentEffortCreated triggered", event.params.id);
        const effortRef = event.data?.ref;
        const data = event.data?.data();

        if (!effortRef || !data) {
            return;
        }

        const { segmentId, userId, movingTime } = data;
        const db = admin.firestore();

        const stravaUser = await db
            .collection("strava-user")
            .where("athleteId", "==", Number(userId))
            .limit(1)
            .get();

        if (stravaUser.empty) {
            console.log("Kein Strava-User gefunden:", userId);
            return;
        }

        const firebaseId = stravaUser.docs[0].data().userId;

        console.log("Firebase User ID:", firebaseId);

        if (!segmentId || !userId || typeof movingTime !== "number") {
            console.log("Invalid segment effort payload:", data);
            return;
        }


        const activityTime = getActivityTime(data);

        if (!activityTime) {
            console.log("No valid activity time found:", data);
            return;
        }

        const userChallengesSnap = await db
            .collection("userChallenges")
            .where("userId", "==", firebaseId)
            .get();

        if (userChallengesSnap.empty) {
            console.log("No active challenge for user:", firebaseId);
            return;
        }

        const processedChallengeIds: string[] = [];
        const skippedChallengeIds: string[] = [];

        for (const userChallengeDoc of userChallengesSnap.docs) {
            const userChallenge = userChallengeDoc.data();
            const challengeId = userChallenge.challengeId;

            if (!challengeId) {
                console.log("userChallenge has no challengeId:", userChallenge);
                continue;
            }

            const challengeSnap = await db
                .collection("challenges")
                .doc(challengeId)
                .get();

            if (!challengeSnap.exists) {
                console.log("Challenge does not exist:", challengeId);
                continue;
            }

            const challenge = challengeSnap.data() ?? {};

            const challengeSegmentSnap = await db
                .doc(`challengeSegments/${challengeId}_${segmentId}`)
                .get();

            if (!challengeSegmentSnap.exists) {
                console.log(
                    `Segment ${segmentId} is not part of challenge ${challengeId}`
                );
                continue;
            }

            const challengeSegment = challengeSegmentSnap.data() ?? {};

            const isActiveAtActivityTime = isSegmentActiveAtTime({
                challenge,
                challengeSegment,
                activityTime,
            });

            if (!isActiveAtActivityTime) {
                console.log(
                    `Segment ${segmentId} was not active at activity time for challenge ${challengeId}`
                );
                skippedChallengeIds.push(challengeId);
                continue;
            }

            const updated = await updateLeaderboardForChallenge({
                db,
                challengeId,
                segmentId,
                userId,
                movingTime,
            });

            processedChallengeIds.push(challengeId);

            if (updated) {
                console.log(
                    `Leaderboard updated. Challenge: ${challengeId}, Segment: ${segmentId}, User: ${userId}`
                );
            } else {
                console.log(
                    `Effort stored, but no new best time. Challenge: ${challengeId}, Segment: ${segmentId}, User: ${userId}`
                );
            }
        }

        await effortRef.set(
            {
                processedChallengeIds,
                skippedChallengeIds,
                activityTime,
                processedAt: Date.now(),
            },
            { merge: true }
        );

        console.log(
            `Effort processed. User: ${userId}, Segment: ${segmentId}, Processed challenges: ${processedChallengeIds.length}`
        );
    }
);

function getActivityTime(data: admin.firestore.DocumentData): number | null {
    const raw =
        data.activityStartDate ??
        data.startDate ??
        data.activityDate ??
        data.createdAt;

    return toMillis(raw);
}

function toMillis(value: unknown): number | null {
    if (!value) {
        return null;
    }

    if (typeof value === "number") {
        return value;
    }

    if (typeof value === "string") {
        const parsed = Date.parse(value);
        return Number.isNaN(parsed) ? null : parsed;
    }

    if (value instanceof admin.firestore.Timestamp) {
        return value.toMillis();
    }

    if (value instanceof Date) {
        return value.getTime();
    }

    if (
        typeof value === "object" && "toMillis" in value &&
        typeof (value as { toMillis: () => number }).toMillis === "function"
    ) {
        return (value as { toMillis: () => number }).toMillis();
    }

    return null;
}

function isSegmentActiveAtTime(params: {
    challenge: admin.firestore.DocumentData;
    challengeSegment: admin.firestore.DocumentData;
    activityTime: number;
}): boolean {
    const { challenge, challengeSegment, activityTime } = params;

    // Variante 1:
    // Falls challengeSegments eigene startDate/endDate Felder haben.
    const segmentStart = toMillis(challengeSegment.startDate);
    const segmentEnd = toMillis(challengeSegment.endDate);

    if (segmentStart !== null && segmentEnd !== null) {
        return activityTime >= segmentStart && activityTime < segmentEnd;
    }

    // Variante 2:
    // Falls challengeSegments nur weekIndex haben und Challenge eine startDate hat.
    const challengeStart = toMillis(challenge.startDate);

    const weekIndexRaw = challengeSegment.weekIndex;
    const weekIndex =
        typeof weekIndexRaw === "number"
            ? weekIndexRaw
            : Number.parseInt(String(weekIndexRaw), 10);

    if (challengeStart === null || Number.isNaN(weekIndex)) {
        console.log("Cannot calculate active segment period:", {
            challengeStart,
            weekIndexRaw,
        });
        return false;
    }

    const oneWeekMs = 7 * 24 * 60 * 60 * 1000;

    const calculatedSegmentStart = challengeStart + weekIndex * oneWeekMs;
    const calculatedSegmentEnd = calculatedSegmentStart + oneWeekMs;

    return (
        activityTime >= calculatedSegmentStart &&
        activityTime < calculatedSegmentEnd
    );
}

async function updateLeaderboardForChallenge(params: {
    db: admin.firestore.Firestore;
    challengeId: string;
    segmentId: string;
    userId: string;
    movingTime: number;
}): Promise<boolean> {
    const { db, challengeId, segmentId, userId, movingTime } = params;

    const segmentEntryRef = db
        .collection("segmentLeaderboards")
        .doc(`${challengeId}_${segmentId}`)
        .collection("entries")
        .doc(userId);

    const segmentEntrySnap = await segmentEntryRef.get();

    const currentBest = segmentEntrySnap.exists
        ? Number(segmentEntrySnap.data()?.bestTime ?? Number.MAX_SAFE_INTEGER)
        : Number.MAX_SAFE_INTEGER;

    if (movingTime >= currentBest) {
        return false;
    }

    const now = Date.now();
    const userSnap = await db
        .collection("users")
        .where("stravaId", "==", userId)
        .limit(1)
        .get();

    let userName = "Unbekannt";

    if (!userSnap.empty) {
        userName = userSnap.docs[0].data().displayName ?? "Unbekannt";
    }

    await segmentEntryRef.set(
        {
            userId,
            segmentId,
            challengeId,
            bestTime: movingTime,
            updatedAt: now,
            userName
        },
        { merge: true }
    );

    const allEntriesSnap = await db
        .collection("segmentLeaderboards")
        .doc(`${challengeId}_${segmentId}`)
        .collection("entries")
        .orderBy("bestTime", "asc")
        .get();

    const totalUsers = allEntriesSnap.size;

    if (totalUsers === 0) {
        console.log("No leaderboard entries found after best time update.");
        return true;
    }

    const batches: admin.firestore.WriteBatch[] = [db.batch()];
    let batchIndex = 0;
    let opCount = 0;

    let currentRank = 1;
    let actualIndex = 1;
    let previousTime: number | null = null;

    for (const docSnap of allEntriesSnap.docs) {
        const entryData = docSnap.data();

        const entryUserId = entryData.userId;
        const bestTime = Number(entryData.bestTime);
        const oldPoints = Number(entryData.points ?? 0);

        if (!entryUserId || Number.isNaN(bestTime)) {
            console.log("Invalid leaderboard entry:", entryData);
            continue;
        }

        const entryUserSnap = await db
            .collection("users")
            .where("stravaId", "==", String(entryUserId))
            .limit(1)
            .get();

        let entryUserName = "Unbekannt";

        if (!entryUserSnap.empty) {
            entryUserName =
                entryUserSnap.docs[0].data().displayName ?? "Unbekannt";
        }

        if (previousTime !== null && bestTime === previousTime) {
            // same rank
        } else {
            currentRank = actualIndex;
        }

        previousTime = bestTime;

        const newPoints = totalUsers - currentRank + 1;
        const pointDifference = newPoints - oldPoints;

        const currentBatch = batches[batchIndex];

        currentBatch.update(docSnap.ref, {
            rank: currentRank,
            points: newPoints,
            updatedAt: now,
            userName: entryUserName
        });

        const challengeEntryRef = db
            .collection("challengeLeaderboards")
            .doc(challengeId)
            .collection("entries")
            .doc(entryUserId);

        currentBatch.set(
            challengeEntryRef,
            {
                userId: entryUserId,
                challengeId,
                totalPoints: admin.firestore.FieldValue.increment(pointDifference),
                updatedAt: now,
                userName: entryUserName
            },
            { merge: true }
        );

        opCount += 2;

        if (opCount >= 400) {
            batches.push(db.batch());
            batchIndex++;
            opCount = 0;
        }

        actualIndex++;
    }

    for (const batch of batches) {
        await batch.commit();
    }

    return true;
}