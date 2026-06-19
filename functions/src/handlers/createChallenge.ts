import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { refreshAccessToken } from "../services/stravaService";
import { STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET } from "../config/strava";

const db = admin.firestore();

async function getStravaUserByUid(uid: string) {
    const userSnap = await db
        .collection("strava-user")
        .where("userId", "==", uid)
        .limit(1)
        .get();

    if (userSnap.empty) {
        throw new HttpsError("not-found", "Strava user not found");
    }

    return userSnap.docs[0];
}

async function fetchAndStoreSegment(
    segmentId: string,
    userDoc: FirebaseFirestore.QueryDocumentSnapshot
) {
    const cached = await db.collection("segments").doc(segmentId).get();

    if (cached.exists) {
        return {
            source: "cache",
            segment: cached.data(),
        };
    }

    let { accessToken, refreshToken } = userDoc.data();

    let response = await fetch(
        `https://www.strava.com/api/v3/segments/${segmentId}`,
        {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        }
    );

    if (response.status === 401) {
        accessToken = await refreshAccessToken(userDoc.id, refreshToken);

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
        throw new HttpsError(
            "internal",
            `Could not load segment ${segmentId}: ${await response.text()}`
        );
    }

    const segment = await response.json();

    await db.collection("segments").doc(segmentId).set(
        {
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
                resource_state: segment.map?.resource_state ?? null,
            },

            updatedAt: Date.now(),
        },
        { merge: true }
    );

    return {
        source: "api",
        segment,
    };
}

export const createChallenge = onCall(
    {
        secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
    },
    async (request) => {
        const { name, description, startDate, segmentIds } = request.data;

        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        if (
            !name ||
            !startDate ||
            !Array.isArray(segmentIds) ||
            segmentIds.length === 0
        ) {
            throw new HttpsError("invalid-argument", "Missing fields");
        }

        const normalizedSegmentIds = segmentIds.map((id: unknown) => String(id));

        const start = new Date(startDate);

        if (isNaN(start.getTime())) {
            throw new HttpsError("invalid-argument", "Invalid startDate");
        }

        const userDoc = await getStravaUserByUid(uid);

        // Segmentdetails vor dem Challenge-Commit laden und speichern.
        // Falls ein Segment nicht geladen werden kann, wird die Challenge nicht erstellt.
        for (const segmentId of normalizedSegmentIds) {
            await fetchAndStoreSegment(segmentId, userDoc);
        }

        const challengeRef = db.collection("challenges").doc();
        const batch = db.batch();

        const end = new Date(start);
        end.setDate(start.getDate() + normalizedSegmentIds.length * 7);

        batch.set(challengeRef, {
            id: challengeRef.id,
            name,
            description: description ?? "",
            createdBy: uid,
            startDate: admin.firestore.Timestamp.fromDate(start),
            endDate: admin.firestore.Timestamp.fromDate(end),
            segmentIds: normalizedSegmentIds,
            createdAt: Date.now(),
        });

        normalizedSegmentIds.forEach((segmentId: string, i: number) => {
            const ref = db
                .collection("challengeSegments")
                .doc(`${challengeRef.id}_${segmentId}`);

            const segmentStart = new Date(startDate);
            segmentStart.setDate(segmentStart.getDate() + i * 7);

            const segmentEnd = new Date(segmentStart);
            segmentEnd.setDate(segmentEnd.getDate() + 7);

            batch.set(ref, {
                challengeId: challengeRef.id,
                segmentId,
                weekIndex: i,
                startDate: admin.firestore.Timestamp.fromDate(segmentStart),
                endDate: admin.firestore.Timestamp.fromDate(segmentEnd),
            });
        });

        const userChallengeRef = db
            .collection("userChallenges")
            .doc(`${uid}_${challengeRef.id}`);

        batch.set(userChallengeRef, {
            userId: uid,
            challengeId: challengeRef.id,
            joinedAt: admin.firestore.FieldValue.serverTimestamp(),
            role: "creator",
        });

        await batch.commit();

        return {
            challengeId: challengeRef.id,
            segmentIds: normalizedSegmentIds,
        };
    }
);