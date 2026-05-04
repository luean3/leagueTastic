// config/strava.ts
import {defineSecret} from "firebase-functions/params";

export const STRAVA_CLIENT_ID = defineSecret("STRAVA_CLIENT_ID");
export const STRAVA_CLIENT_SECRET = defineSecret("STRAVA_CLIENT_SECRET");