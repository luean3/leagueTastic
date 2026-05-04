import * as admin from "firebase-admin";
import {STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET} from "../config/strava";

export async function refreshAccessToken(uid: string, refreshToken: string) {
    const res = await fetch("https://www.strava.com/oauth/token", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            client_id: STRAVA_CLIENT_ID.value(),
            client_secret: STRAVA_CLIENT_SECRET.value(),
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