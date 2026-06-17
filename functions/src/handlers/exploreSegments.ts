import { onCall, HttpsError } from "firebase-functions/v2/https";
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

export const exploreSegments = onCall(
    {
        secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
    },
    async (request) => {
        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        const bounds = request.data.bounds as string;
        const activityType = (request.data.activityType as string) || "riding";

        if (!bounds) {
            throw new HttpsError("invalid-argument", "bounds required");
        }

        const queryId = hash(bounds, activityType);

        const cached = await db
            .collection("segment_explore_queries")
            .doc(queryId)
            .get();

        if (cached.exists) {
            return {
                source: "cache",
                segmentIds: cached.data()?.segmentIds ?? [],
            };
        }

        const userSnap = await db
            .collection("strava-user")
            .where("userId", "==", uid)
            .limit(1)
            .get();

        if (userSnap.empty) {
            throw new HttpsError("not-found", "Strava user not found");
        }

        const userDoc = userSnap.docs[0];
        let { accessToken, refreshToken } = userDoc.data();

        let response = await fetch(
            `https://www.strava.com/api/v3/segments/explore?bounds=${bounds}&activity_type=${activityType}`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            }
        );

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
            throw new HttpsError(
                "internal",
                await response.text()
            );
        }

        const data: any = await response.json();
        const segments = data.segments ?? [];

        const batch = db.batch();
        const segmentIds: string[] = [];

        for (const s of segments) {
            const segmentId = String(s.id);
            segmentIds.push(segmentId);

            const ref = db.collection("segment_explore").doc(segmentId);

            batch.set(
                ref,
                {
                    id: segmentId,
                    name: s.name ?? null,
                    distance: s.distance ?? null,
                    avg_grade: s.avg_grade ?? null,
                    max_grade: s.maximum_grade ?? s.max_grade ?? null,
                    climb_category: s.climb_category ?? null,
                    start_latlng: s.start_latlng ?? null,
                    end_latlng: s.end_latlng ?? null,
                    city: s.city ?? null,
                    points: s.points ?? null,
                    updatedAt: Date.now(),
                },
                { merge: true }
            );
        }

        batch.set(db.collection("segment_explore_queries").doc(queryId), {
            bounds,
            activityType,
            segmentIds,
            createdAt: Date.now(),
        });

        await batch.commit();

        return {
            source: "api",
            segmentIds,
        };
    }
);