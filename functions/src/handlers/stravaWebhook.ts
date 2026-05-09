import {onRequest} from "firebase-functions/https";
import * as admin from "firebase-admin";
import {logger} from "firebase-functions";
import {STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET} from "../config/strava";

export const stravaWebhook = onRequest(
    {
        secrets: [STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET],
    }, async (req, res) => {
        if (req.method === "GET") {
            res.json({"hub.challenge": req.query["hub.challenge"]});
            return;
        }

        const body = req.body;

        if (body.object_type !== "activity") {
            res.status(200).send("ignored");
            return;
        }

        // 👉 nur enqueue
        await admin.firestore().collection("jobs").add({
            type: "processActivity",
            activityId: body.object_id,
            athleteId: body.owner_id,
            createdAt: Date.now()
        });
        logger.log({
            message: "saved job",
            activityId: body.object_id,
            athleteId: body.owner_id,
        });
        res.status(200).send("ok");
    });