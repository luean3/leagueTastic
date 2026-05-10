import {onRequest} from "firebase-functions/https";
import * as admin from "firebase-admin";
import {refreshAccessToken} from "../services/stravaService";
import {STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET} from "../config/strava";

const db = admin.firestore();

export const getSegment = onRequest(
    {
        secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
    },
    async (req, res) => {
        try {
            const segmentId = req.query.segmentId as string;
            const athleteId = '58272432';

            if (!segmentId || !athleteId) {
                res.status(400).send("segmentId + athleteId required");
                return;
            }

            // 1. CACHE CHECK
            const cached = await db
                .collection("segments")
                .doc(segmentId)
                .get();

            if (cached.exists) {
                res.json({
                    source: "cache",
                    segment: cached.data()
                });
                return;
            }

            // 2. USER FETCH (wie Webhook)
            const userSnap = await db
                .collection("strava-user")
                .where("athleteId", "==", Number(athleteId))
                .limit(1)
                .get();

            if (userSnap.empty) {
                res.status(404).send("user not found");
                return;
            }

            const userDoc = userSnap.docs[0];

            let {accessToken, refreshToken} = userDoc.data();

            // 3. STRAVA CALL (fetch)
            let response = await fetch(
                `https://www.strava.com/api/v3/segments/${segmentId}`,
                {
                    headers: {
                        Authorization: `Bearer ${accessToken}`,
                    },
                }
            );

            // 4. TOKEN REFRESH (wie webhook)
            if (response.status === 401) {
                accessToken = await refreshAccessToken(
                    userDoc.id,
                    refreshToken
                );

                response = await fetch(
                    `https://www.strava.com/api/v3/segments/${segmentId}`,
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

            const segment = await response.json();

            // 5. STORE IN FIRESTORE
            await db.collection("segments").doc(segmentId).set({
                id: segment.id,
                resource_state: segment.resource_state,

                name: segment.name,
                activity_type: segment.activity_type ?? null,

                distance: segment.distance,
                average_grade: segment.average_grade,
                maximum_grade: segment.maximum_grade,

                elevation_high: segment.elevation_high,
                elevation_low: segment.elevation_low,
                total_elevation_gain: segment.total_elevation_gain,

                start_latlng: segment.start_latlng,
                end_latlng: segment.end_latlng,

                climb_category: segment.climb_category,

                city: segment.city ?? null,
                state: segment.state ?? null,
                country: segment.country ?? null,

                private: segment.private ?? null,
                hazardous: segment.hazardous ?? null,
                starred: segment.starred ?? null,

                created_at: segment.created_at ?? null,
                updated_at: segment.updated_at ?? null,

                effort_count: segment.effort_count ?? null,
                athlete_count: segment.athlete_count ?? null,
                star_count: segment.star_count ?? null,

                athlete_segment_stats: segment.athlete_segment_stats ?? null,

                map: {
                    id: segment.map?.id ?? null,
                    polyline: segment.map?.polyline ?? null,
                    resource_state: segment.map?.resource_state ?? null
                },

                updatedAt: Date.now()
            }, { merge: true });

            res.json({
                source: "api",
                segment
            });

        } catch (err: any) {
            console.error(err);
            res.status(500).send(err.message);
        }
    });