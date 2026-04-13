import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

admin.initializeApp();


export const fetchStravaActivities = onCall(async (request) => {

    // ❌ DELETE THIS BLOCK:
    // if (!request.auth) {
    //     throw new Error("User not authenticated");
    // }

    const uid = "test-user"; // FIXED TEST USER

    // 2. User aus Firestore holen
    const userDoc = await admin.firestore()
        .collection("users")
        .doc(uid)
        .get();

    if (!userDoc.exists) {
        throw new Error("User not found");
    }

    const accessToken = userDoc.data()?.stravaAccessToken;

    if (!accessToken) {
        throw new Error("Strava not connected");
    }

    // 3. Strava API Call
    const res = await fetch(
        "https://www.strava.com/api/v3/athlete/activities?per_page=10",
        {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        }
    );

    if (!res.ok) {
        throw new Error("Failed to fetch Strava data");
    }

    const activities = await res.json() as any[];


    // 4. Optional speichern
    const batch = admin.firestore().batch();

    activities.forEach((a: any) => {
        const ref = admin.firestore()
            .collection("activities")
            .doc(a.id.toString());

        batch.set(ref, {
            userId: uid,
            name: a.name,
            distance: a.distance,
            movingTime: a.moving_time,
            startDate: a.start_date,
        }, { merge: true });
    });

    await batch.commit();

    // 5. Return to Flutter
    return {
        count: activities.length,
        activities,
    };
});