import {onDocumentCreated} from "firebase-functions/firestore";
import * as admin from "firebase-admin";
import {refreshAccessToken} from "../services/stravaService";
import {logger} from "firebase-functions";
import {STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET} from "../config/strava";

export const processActivity = onDocumentCreated(
    {
        document: "jobs/{id}",
        secrets: [
            STRAVA_CLIENT_ID,
            STRAVA_CLIENT_SECRET,
        ],
    },

    async (event) => {
        const job = event.data?.data();
        if (!job) return;
        const {activityId, athleteId} = job;
        logger.log({
            message: "started processing job",
            activityId,
            athleteId,
        });

        // =========================
        // USER LOAD
        // =========================
        const userSnap = await admin.firestore()
            .collection("strava-user")
            .where("athleteId", "==", athleteId)
            .limit(1)
            .get();

        if (userSnap.empty) return;

        const userDoc = userSnap.docs[0];

        let {accessToken, refreshToken} = userDoc.data();

        // =========================
        // STRAVA CALL
        // =========================
        let activityRes = await fetch(
            `https://www.strava.com/api/v3/activities/${activityId}`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            }
        );

        if (activityRes.status === 401) {
            accessToken = await refreshAccessToken(
                userDoc.id,
                refreshToken
            );

            activityRes = await fetch(
                `https://www.strava.com/api/v3/activities/${activityId}`,
                {
                    headers: {
                        Authorization: `Bearer ${accessToken}`,
                    },
                }
            );
        }

        if (!activityRes.ok) return;

        const activity: any = await activityRes.json();

        const db = admin.firestore();
        const batch = db.batch();

        // =========================
        // ACTIVITY
        // =========================
        const activityRef = db.collection("activities").doc(String(activity.id));

        batch.set(activityRef, {
            userId: userDoc.id,
            name: activity.name,
            distance: activity.distance,
            startDate: activity.start_date,
            elapsedTime: activity.elapsed_time
        });

        // =========================
        // SEGMENT EFFORTS
        // =========================
        const segmentEfforts = activity.segment_efforts ?? [];

        for (const s of segmentEfforts) {

            const segmentId = s.segment.id;
            const newTime = Number(s.elapsed_time);

            // RAW STORE
            const rawRef = db
                .collection("segmentEfforts")
                .doc(`${activity.id}_${s.id}`);

            batch.set(rawRef, {
                userId: userDoc.id,
                segmentId,
                activityId: activity.id,
                elapsedTime: newTime,
                movingTime: s.moving_time,
                startDate: activity.start_date,
                distance: s.distance,
            });

            // =========================
            // CHALLENGES (NO NESTED QUERIES PER SEGMENT!)
            // =========================
            const challengeSnap = await db
                .collection("challenges")
                .where("segmentIds", "array-contains", segmentId)
                .get();

            logger.log({
                message: "found effort for following segment",
               segmentId
            });


            for (const challengeDoc of challengeSnap.docs) {

                const challengeId = challengeDoc.id;
                const challenge = challengeDoc.data();

                if (challenge.currentSegmentId !== segmentId) continue;

                const effortRef = db
                    .collection("challenges")
                    .doc(challengeId)
                    .collection("leaderboard")
                    .doc(`${userDoc.id}_${segmentId}`);

                const existing = await effortRef.get();

                const currentBest = existing.exists
                    ? Number(existing.data()?.elapsedTime ?? Number.MAX_SAFE_INTEGER)
                    : Number.MAX_SAFE_INTEGER;

                if (newTime < currentBest) {
                    batch.set(effortRef, {
                        userId: userDoc.id,
                        segmentId,
                        activityId: activity.id,
                        elapsedTime: newTime,
                        updatedAt: Date.now(),
                    }, {merge: true});
                }
            }
        }

        await batch.commit();

        logger.log({
            message: "finished processing job",
            activityId,
            athleteId,
        });
    }
);