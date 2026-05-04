import { onRequest } from "firebase-functions/https";
import * as admin from "firebase-admin";
import crypto from "crypto";
import { refreshAccessToken } from "../services/stravaService";
import { STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET } from "../config/strava";

const db = admin.firestore();

function hash(bounds: string, activityType: string) {
    return crypto
        .createHash("sha1")
        .update(`${bounds}|${activityType}`)
        .digest("hex");
}

export const exploreSegments = onRequest({
    secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
}, async (req, res) => {
    try {
        const bounds = req.query.bounds as string;
        const activityType = (req.query.activity_type as string) || "riding";
        const athleteId = req.query.athleteId as string;

        if (!bounds || !athleteId) {
            res.status(400).send("bounds + athleteId required");
            return;
        }

        const queryId = hash(bounds, activityType);

        // 1. CACHE CHECK (explore cache)
        const cached = await db.collection("segment_explore_queries").doc(queryId).get();

        if (cached.exists) {
            res.json({
                source: "cache",
                segmentIds: cached.data()?.segmentIds ?? []
            });
            return;
        }

        // 2. USER
        const userSnap = await db
            .collection("users")
            .where("athleteId", "==", Number(athleteId))
            .limit(1)
            .get();

        if (userSnap.empty) {
            res.status(404).send("user not found");
            return;
        }

        const userDoc = userSnap.docs[0];
        let { accessToken, refreshToken } = userDoc.data();

        // 3. STRAVA CALL
        let response = await fetch(
            `https://www.strava.com/api/v3/segments/explore?bounds=${bounds}&activity_type=${activityType}`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            }
        );

        // 4. REFRESH
        if (response.status === 401) {
            accessToken = await refreshAccessToken(userDoc.id, refreshToken);

            response = await fetch(
                `https://www.strava.com/api/v3/segments/explore?bounds=${bounds}&activity_type=${activityType}`,
                {
                    headers: {
                        Authorization: `Bearer ${accessToken}`,
                    },
                }
            );
        }

        if (!response.ok) {
            res.status(500).send(await response.text());
            return;
        }

        const data: any = await response.json();
        const segments = data.segments ?? [];

        const batch = db.batch();
        const segmentIds: number[] = [];

        // 5. STORE EXPLORE DATA (LIGHTWEIGHT)
        for (const s of segments) {
            segmentIds.push(s.id);

            const ref = db.collection("segment_explore").doc(String(s.id));

            batch.set(ref, {
                id: s.id,
                name: s.name ?? null,

                distance: s.distance ?? null,
                avg_grade: s.avg_grade ?? null,
                max_grade: s.maximum_grade ?? s.max_grade ?? null,

                climb_category: s.climb_category ?? null,

                start_latlng: s.start_latlng ?? null,
                end_latlng: s.end_latlng ?? null,

                city: s.city ?? null,
                points: s.points ?? null,

                updatedAt: Date.now()
            }, { merge: true });
        }

        // 6. CACHE QUERY
        batch.set(db.collection("segment_explore_queries").doc(queryId), {
            bounds,
            activityType,
            segmentIds,
            createdAt: Date.now()
        });

        await batch.commit();

        res.json({
            source: "api",
            segmentIds
        });

    } catch (err: any) {
        console.error(err);
        res.status(500).send(err.message);
    }
});