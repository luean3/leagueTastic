import {onCall} from "firebase-functions/https";
import * as admin from "firebase-admin";

export const getSegmentLeaderboard = onCall(async (request) => {

    const uid = request.auth?.uid;
    if (!uid) {
        throw new Error("Unauthorized");
    }

    const {segmentId, from, to, limit} = request.data;

    if (!segmentId) {
        throw new Error("Missing segmentId");
    }

    const fromDate = from ? new Date(from) : new Date(0);
    const toDate = to ? new Date(to) : new Date();

    const snap = await admin.firestore()
        .collection("segmentEfforts")
        .where("segmentId", "==", segmentId)
        .where("startDate", ">=", fromDate.toISOString())
        .where("startDate", "<=", toDate.toISOString())
        .get();

    const efforts = snap.docs.map(doc => doc.data());

    // 🧮 sort fastest first
    const sorted = efforts.sort((a, b) => {
        return a.elapsedTime - b.elapsedTime;
    });

    const top = sorted.slice(0, limit ?? 10);

    return {
        segmentId,
        from: fromDate,
        to: toDate,
        count: top.length,
        leaderboard: top.map((e) => ({
            userId: e.userId,
            time: e.elapsedTime,
            distance: e.distance,
            date: e.startDate,
        })),
    };
});