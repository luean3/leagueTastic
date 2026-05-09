import {onRequest} from "firebase-functions/https";
import * as admin from "firebase-admin";
import {STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET} from "../config/strava";

export const stravaCallback = onRequest(
    {
        secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
    },async (req, res) => {
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
                client_id: STRAVA_CLIENT_ID.value(),
                client_secret: STRAVA_CLIENT_SECRET.value(),
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
            .collection("strava-user")
            .doc(String(athleteId))
            .set({
                accessToken,
                refreshToken,
                athleteId,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

        // Deep link zurück in App
        res.redirect(`leaguetastic://strava-success?id=${athleteId}`);

    } catch (error) {
        console.error(error);
        res.status(500).send("Strava auth failed");
    }
});