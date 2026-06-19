import { onDocumentCreated } from "firebase-functions/firestore";
import * as admin from "firebase-admin";
import { refreshAccessToken } from "../services/stravaService";
import { logger } from "firebase-functions";
import { STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET } from "../config/strava";

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

        if (!job) {
            return;
        }

        const { activityId, athleteId } = job;

        logger.log({
            message: "started processing job",
            activityId,
            athleteId,
        });

        const db = admin.firestore();

        // =========================
        // 1. USER LOAD
        // =========================
        const userSnap = await db
            .collection("strava-user")
            .where("athleteId", "==", athleteId)
            .limit(1)
            .get();

        if (userSnap.empty) {
            logger.log({
                message: "No user found for athleteId",
                athleteId,
            });
            return;
        }

        const userDoc = userSnap.docs[0];
        let { accessToken, refreshToken } = userDoc.data();

        // =========================
        // 2. STRAVA CALL
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

        if (!activityRes.ok) {
            logger.log({
                message: "Failed to load activity from Strava",
                activityId,
                status: activityRes.status,
            });
            return;
        }

        const activity: any = await activityRes.json();

        const activityStartDateMs = new Date(activity.start_date).getTime();

        if (Number.isNaN(activityStartDateMs)) {
            logger.log({
                message: "Invalid activity start date",
                activityId,
                startDate: activity.start_date,
            });
            return;
        }

        const batch = db.batch();

        // =========================
        // 3. STORE ACTIVITY
        // =========================
        const activityRef = db
            .collection("activities")
            .doc(String(activity.id));

        batch.set(
            activityRef,
            {
                userId: userDoc.id,
                athleteId,
                activityId: activity.id,
                name: activity.name,
                distance: activity.distance,
                startDate: activity.start_date,
                startDateMs: activityStartDateMs,
                elapsedTime: activity.elapsed_time,
                movingTime: activity.moving_time,
                type: activity.type,
                sportType: activity.sport_type,
                updatedAt: Date.now(),
            },
            { merge: true }
        );

        // =========================
        // 4. STORE RAW SEGMENT EFFORTS
        // =========================
        const segmentEfforts = activity.segment_efforts ?? [];

        logger.log({
            message: "found segment efforts",
            activityId,
            count: segmentEfforts.length,
        });

        for (const effort of segmentEfforts) {
            const segmentId = String(effort.segment?.id ?? "");
            const effortId = String(effort.id ?? "");
            const elapsedTime = Number(effort.elapsed_time);

            if (!segmentId || !effortId || Number.isNaN(elapsedTime)) {
                logger.log({
                    message: "invalid segment effort",
                    effort,
                });
                continue;
            }

            const rawRef = db
                .collection("segmentEfforts")
                .doc(`${activity.id}_${effortId}`);

            batch.set(
                rawRef,
                {
                    userId: userDoc.id,
                    athleteId,
                    activityId: String(activity.id),
                    effortId,
                    segmentId,
                    elapsedTime,
                    movingTime: effort.moving_time,
                    distance: effort.distance,

                    // Important for checking whether the segment was active at that time
                    activityStartDate: activity.start_date,
                    activityStartDateMs,

                    createdAt: Date.now(),
                },
                { merge: true }
            );

            logger.log({
                message: "stored raw segment effort",
                activityId,
                effortId,
                segmentId,
                elapsedTime,
            });
        }

        await batch.commit();

        logger.log({
            message: "finished processing job",
            activityId,
            athleteId,
        });
    }
);