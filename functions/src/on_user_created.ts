import * as functionsV1 from "firebase-functions/v1";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

const db = getFirestore();

export const onUserCreated = functionsV1
  .region("europe-west6")
  .auth.user()
  .onCreate(async (user) => {
    const playerRef = db.collection("players").doc(user.uid);

    await playerRef.set({
      displayName: user.displayName ?? `Player${user.uid.substring(0, 6)}`,
      avatarUrl: user.photoURL ?? "preset:rose",
      level: 1,
      xp: 0,
      coins: 100,
      gems: 10,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
