import {onRequest} from "firebase-functions/https";
import * as admin from "firebase-admin";

export const createChallenge = onRequest(async (req, res) => {
    const {name, description, startDate, segmentIds, createdBy} = req.body;

    if (!name || !startDate || !segmentIds?.length) {
        res.status(400).send("missing fields");
        return;
    }

    const db = admin.firestore();
    const challengeRef = db.collection("challenges").doc();
    const batch = db.batch();
    const start = new Date(startDate);

// letzte Woche berechnen
    const end = new Date(start);
    end.setDate(start.getDate() + segmentIds.length * 7);
    batch.set(challengeRef, {
        id: challengeRef.id,
        name,
        description,
        createdBy,
        startDate: admin.firestore.Timestamp.fromDate(new Date(startDate)),
        endDate: admin.firestore.Timestamp.fromDate(new Date(end)),
        segmentIds,
        createdAt: Date.now()
    });

    segmentIds.forEach((segmentId: string, i: number) => {
        const ref = db.collection("challengeSegments")
            .doc(`${challengeRef.id}_${segmentId}`);

        const start = new Date(startDate);
        start.setDate(start.getDate() + i * 7);

        const end = new Date(start);
        end.setDate(end.getDate() + 7);

        batch.set(ref, {
            challengeId: challengeRef.id,
            segmentId,
            weekIndex: i,
            startDate: admin.firestore.Timestamp.fromDate(start),
            endDate: admin.firestore.Timestamp.fromDate(end)
        });
    });

    await batch.commit();

    res.json({challengeId: challengeRef.id});
});