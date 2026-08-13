import {getFirestore} from "firebase-admin/firestore";

/**
 * Shared Firestore client for every feature module.
 *
 * `getFirestore()` already returns a cached singleton internally, so this
 * wrapper changes no runtime behavior. It exists purely so that every
 * feature imports its Firestore handle from one place instead of each file
 * calling `getFirestore()` independently — one fewer near-identical line to
 * repeat per file, and one place to point at a non-default app/db later
 * (e.g. named databases, emulator wiring, tests) without touching every
 * caller.
 */
export const db = getFirestore();
