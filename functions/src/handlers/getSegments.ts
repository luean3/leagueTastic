import {onCall} from "firebase-functions/https";
import * as admin from "firebase-admin";

export const getSegments = onCall(async (request) => {

    const segmentIds = request.data.segmentIds;

    if (!segmentIds || !Array.isArray(segmentIds)) {
        throw new Error("segmentIds missing");
    }

    const db = admin.firestore();

    const segments = await Promise.all(
        segmentIds.map(async (id: string) => {
            const snap = await db
                .collection("segments")
                .doc(id)
                .get();

            return {
                id,
                ...snap.data(),
            };
        })
    );

    return {
        segments,
    };
});