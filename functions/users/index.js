const { onRequest } = require("firebase-functions/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const { verifyAuth, verifyAuthAndRole, handleCors, sendError, sendSuccess } = require("../middleware/auth");

/**
 * Firestore trigger: Auto-create user profile when a new Firebase Auth user is created.
 * This triggers on the Firestore document creation (the client app writes initial data).
 */
const onUserCreated = onDocumentCreated("users/{userId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const userId = event.params.userId;
    const data = snapshot.data();

    // Set custom claims for role-based access
    try {
        await admin.auth().setCustomUserClaims(userId, { role: "user" });
        console.log(`Set custom claims for user ${userId}`);
    } catch (error) {
        console.error(`Error setting claims for user ${userId}:`, error);
    }

    // Increment admin stats
    const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
    await statsRef.set(
        { totalUsers: FieldValue.increment(1) },
        { merge: true }
    );
});

/**
 * HTTP Function: Get the authenticated user's profile.
 * GET /getUserProfile
 */
const getUserProfile = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "GET") {
            throw new Error("Bad request: Only GET method is allowed");
        }

        const { uid } = await verifyAuth(req);
        const userDoc = await admin.firestore().collection("users").doc(uid).get();

        if (!userDoc.exists) {
            throw new Error("Not found: User profile not found");
        }

        sendSuccess(res, { user: { id: userDoc.id, ...userDoc.data() } });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Update the authenticated user's profile.
 * PUT /updateUserProfile
 * Body: { name, phone, address }
 */
const updateUserProfile = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "PUT") {
            throw new Error("Bad request: Only PUT method is allowed");
        }

        const { uid } = await verifyAuth(req);
        const { name, phone, address } = req.body;

        const updateData = { updatedAt: FieldValue.serverTimestamp() };
        if (name) updateData.name = name;
        if (phone) updateData.phone = phone;
        if (address) updateData.address = address;

        await admin.firestore().collection("users").doc(uid).update(updateData);

        sendSuccess(res, { message: "Profile updated successfully" });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Delete the authenticated user's account.
 * DELETE /deleteUserAccount
 */
const deleteUserAccount = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "DELETE") {
            throw new Error("Bad request: Only DELETE method is allowed");
        }

        const { uid } = await verifyAuth(req);

        // Delete Firestore profile
        await admin.firestore().collection("users").doc(uid).delete();

        // Delete Firebase Auth account
        await admin.auth().deleteUser(uid);

        // Decrement admin stats
        const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
        await statsRef.set(
            { totalUsers: FieldValue.increment(-1) },
            { merge: true }
        );

        sendSuccess(res, { message: "Account deleted successfully" });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Save/update FCM token for push notifications.
 * POST /updateFcmToken
 * Body: { token }
 */
const updateFcmToken = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "POST") {
            throw new Error("Bad request: Only POST method is allowed");
        }

        const { uid } = await verifyAuth(req);
        const { token } = req.body;

        if (!token) {
            throw new Error("Bad request: FCM token is required");
        }

        // Check if user is in users or collectors collection
        const userDoc = await admin.firestore().collection("users").doc(uid).get();
        const collectorDoc = await admin.firestore().collection("collectors").doc(uid).get();

        const collection = userDoc.exists ? "users" : collectorDoc.exists ? "collectors" : null;
        if (!collection) {
            throw new Error("Not found: User profile not found");
        }

        await admin.firestore().collection(collection).doc(uid).update({
            fcmTokens: FieldValue.arrayUnion(token),
        });

        sendSuccess(res, { message: "FCM token saved" });
    } catch (error) {
        sendError(res, error);
    }
});

module.exports = {
    onUserCreated,
    getUserProfile,
    updateUserProfile,
    deleteUserAccount,
    updateFcmToken,
};
