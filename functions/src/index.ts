import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions/v2";

initializeApp();

setGlobalOptions({
  region: "europe-west6",
  maxInstances: 10,
});

export {onUserCreated} from "./on_user_created";
