import {onCall, onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

admin.initializeApp();

const STRAVA_CLIENT_ID = "";
const STRAVA_CLIENT_SECRET = "";

// ===============================
// 🔥 HELPER: Refresh Token
// ===============================
async function refreshAccessToken(uid: string, refreshToken: string) {
    const res = await fetch("https://www.strava.com/oauth/token", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            client_id: STRAVA_CLIENT_ID,
            client_secret: STRAVA_CLIENT_SECRET,
            grant_type: "refresh_token",
            refresh_token: refreshToken,
        }),
    });

    if (!res.ok) {
        throw new Error("Failed to refresh Strava token");
    }

    const data: any = await res.json();

    await admin.firestore().collection("users").doc(uid).update({
        accessToken: data.access_token,
        refreshToken: data.refresh_token,
    });

    return data.access_token;
}

// ===============================
// 🔥 FETCH STRAVA ACTIVITIES
// ===============================
export const fetchStravaActivities = onCall(async (request) => {
    const uid = "58272432";

    const userDoc = await admin.firestore()
        .collection("users")
        .doc(uid)
        .get();

    let accessToken = userDoc.data()?.accessToken;
    const refreshToken = userDoc.data()?.refreshToken;

    if (!accessToken) {
        throw new Error("Strava not connected");
    }

    // 1. BASIC ACTIVITIES
    let res = await fetch(
        "https://www.strava.com/api/v3/athlete/activities?per_page=10",
        {
            headers: { Authorization: `Bearer ${accessToken}` },
        }
    );

    if (res.status === 401) {
        accessToken = await refreshAccessToken(uid, refreshToken);

        res = await fetch(
            "https://www.strava.com/api/v3/athlete/activities?per_page=10",
            {
                headers: { Authorization: `Bearer ${accessToken}` },
            }
        );
    }

    const activities: any[] = await res.json() as any;

    const batch = admin.firestore().batch();

    // ===============================
    // 2. FETCH DETAILS + SEGMENTS
    // ===============================
    for (const activity of activities) {

        const detailRes = await fetch(
            `https://www.strava.com/api/v3/activities/${activity.id}`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            }
        );

        if (!detailRes.ok) continue;

        const detail: any = await detailRes.json();

        const segmentEfforts = detail.segment_efforts || [];

        // ===============================
        // SAVE ACTIVITY
        // ===============================
        const ref = admin.firestore()
            .collection("activities")
            .doc(activity.id.toString());

        batch.set(ref, {
            userId: uid,
            name: activity.name,
            distance: activity.distance,
            movingTime: activity.moving_time,
            startDate: activity.start_date,
            segmentEfforts: segmentEfforts.map((s: any) => ({
                name: s.name,
                elapsedTime: s.elapsed_time,
                distance: s.distance,
                segmentId: s.segment.id,
            })),
        }, { merge: true });
    }

    await batch.commit();

    return {
        count: activities.length,
    };
});

// ===============================
// 🔥 OAUTH CALLBACK
// ===============================
export const stravaCallback = onRequest(async (req, res) => {
    try {
        const code = req.query.code as string;

        if (!code) {
            res.status(400).send("Missing code");
            return;
        }

        const tokenRes = await fetch("https://www.strava.com/oauth/token", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                client_id: STRAVA_CLIENT_ID,
                client_secret: STRAVA_CLIENT_SECRET,
                code,
                grant_type: "authorization_code",
            }),
        });

        if (!tokenRes.ok) {
            const errorText = await tokenRes.text();
            res.status(500).send(errorText);
            return;
        }

        const data: any = await tokenRes.json();

        const accessToken = data.access_token;
        const refreshToken = data.refresh_token;
        const athleteId = data.athlete.id;

        await admin.firestore()
            .collection("users")
            .doc(String(athleteId))
            .set({
                accessToken,
                refreshToken,
                athleteId,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

        // Deep link zurück in App
        res.redirect("leaguetastic://strava-success");

    } catch (error) {
        console.error(error);
        res.status(500).send("Strava auth failed");
    }
});

export const fetchSegmentEfforts = onCall(async (request) => {
    const uid = "58272432"; // DEV ONLY
    const segmentId = request.data.segmentId;

    if (!segmentId) {
        throw new Error("Missing segmentId");
    }

    const userDoc = await admin.firestore()
        .collection("users")
        .doc(uid)
        .get();

    if (!userDoc.exists) {
        throw new Error("User not found");
    }

    let accessToken = userDoc.data()?.accessToken;
    const refreshToken = userDoc.data()?.refreshToken;

    if (!accessToken) {
        throw new Error("Strava not connected");
    }

    // ===============================
    // 🔥 CALL STRAVA SEGMENT API
    // ===============================
    let res = await fetch(
        `https://www.strava.com/api/v3/segments/${segmentId}/all_efforts?per_page=10`,
        {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        }
    );

    // ===============================
    // 🔥 HANDLE TOKEN EXPIRY
    // ===============================
    if (res.status === 401) {
        console.log("Token expired → refreshing...");

        accessToken = await refreshAccessToken(uid, refreshToken);

        res = await fetch(
            `https://www.strava.com/api/v3/segments/${segmentId}/all_efforts?per_page=10`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                },
            }
        );
    }

    if (!res.ok) {
        const errorText = await res.text();
        throw new Error("Strava API error: " + errorText);
    }

    const efforts: any[] = await res.json() as any;

    // ===============================
    // 🔥 OPTIONAL: SAVE TO FIRESTORE
    // ===============================
    const batch = admin.firestore().batch();

    efforts.forEach((e) => {
        const ref = admin.firestore()
            .collection("segmentEfforts")
            .doc(e.id.toString());

        batch.set(ref, {
            userId: uid,
            segmentId: segmentId,
            name: e.name,
            elapsedTime: e.elapsed_time,
            movingTime: e.moving_time,
            startDate: e.start_date,
            distance: e.distance,
        }, { merge: true });
    });

    await batch.commit();

    return {
        count: efforts.length,
        efforts,
    };
});