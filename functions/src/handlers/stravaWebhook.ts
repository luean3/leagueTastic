import {onRequest} from "firebase-functions/https";
import * as admin from "firebase-admin";
import {refreshAccessToken} from "../services/stravaService";
import {STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET} from "../config/strava";

export const stravaWebhook = onRequest(
    {
        secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
    },
    async (req, res) => {

        // Verification Challenge
        if (req.method === "GET") {
            res.status(200).json({
                "hub.challenge": req.query["hub.challenge"],
            });
            return;
        }

        // Webhook Event
        const body = req.body;

        if (
            body.object_type !== "activity" ||
            body.aspect_type !== "create"
        ) {
            res.status(200).send("ignored");
            return;
        }

        const activityId = body.object_id;
        const athleteId = body.owner_id;

        // User finden
        const userSnap = await admin.firestore()
            .collection("users")
            .where("athleteId", "==", athleteId)
            .limit(1)
            .get();

        if (userSnap.empty) {
            res.status(404).send("user not found");
            return;
        }

        const userDoc = userSnap.docs[0];

        let {
            accessToken,
            refreshToken,
        } = userDoc.data();

        // Aktivität laden
        let activityRes = await fetch(
            `https://www.strava.com/api/v3/activities/${activityId}`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            }
        );

        // Token refresh
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
            res.status(500).send(await activityRes.text());
            return;
        }

        const activity: any = await activityRes.json();


        const batch = admin.firestore().batch();

// Activity
        const activityRef = admin.firestore()
            .collection("activities")
            .doc(`${activity.id}`);

        batch.set(activityRef, {
            userId: userDoc.id,
            name: activity.name,
            distance: activity.distance,
            startDate: activity.start_date,
            elapsedTime: activity.elapsed_time
        });

// Segments
        const segmentEfforts = activity.segment_efforts ?? [];

        for (const s of segmentEfforts) {
            const segmentId = s.segment.id;

            // 1. RAW (dein bestehender Code bleibt)
            const rawRef = admin.firestore()
                .collection("segmentEfforts")
                .doc(`${activity.id}_${s.id}`);

            batch.set(rawRef, {
                userId: userDoc.id,
                segmentId,
                activityId: activity.id,
                elapsedTime: s.elapsed_time,
                movingTime: s.moving_time,
                startDate: activity.start_date,
                distance: s.distance,
            });

            // 2. CHECK: ist Segment Teil einer Challenge?
            const challengeSnap = await admin.firestore()
                .collection("challenges")
                .where("segmentIds", "array-contains", segmentId)
                .get();

            for (const challengeDoc of challengeSnap.docs) {
                const challengeId = challengeDoc.id;
                const challenge = challengeDoc.data();

                const currentSegmentId = challenge.currentSegmentId;

                // nur aktuelles Segment relevant (optional)
                if (currentSegmentId !== segmentId) continue;

                const effortRef = admin.firestore()
                    .collection("challenges")
                    .doc(challengeId)
                    .collection("leaderboard")
                    .doc(`${userDoc.id}_${segmentId}`);

                const existing = await effortRef.get();

                const newTime = s.elapsed_time;

                // 3. nur best time speichern
                if (!existing.exists || newTime < existing.data()!.elapsedTime) {
                    batch.set(effortRef, {
                        userId: userDoc.id,
                        segmentId,
                        activityId: activity.id,
                        elapsedTime: Number(newTime),
                        updatedAt: Date.now(),
                    }, {merge: true});
                }
            }
        }
    });