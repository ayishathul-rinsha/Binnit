const { onRequest } = require("firebase-functions/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { FieldValue, GeoPoint } = require("firebase-admin/firestore");
const { verifyAuth, verifyAuthAndRole, handleCors, sendError, sendSuccess } = require("../middleware/auth");

/**
 * Firestore trigger: When a new collector profile is created.
 */
const onCollectorCreated = onDocumentCreated("collectors/{collectorId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const collectorId = event.params.collectorId;

    try {
        await admin.auth().setCustomUserClaims(collectorId, { role: "collector" });
        console.log(`Set collector claims for ${collectorId}`);
    } catch (error) {
        console.error(`Error setting collector claims:`, error);
    }

    // Increment admin stats
    const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
    await statsRef.set(
        { totalCollectors: FieldValue.increment(1) },
        { merge: true }
    );
});

/**
 * HTTP Function: Register as a waste collector.
 * POST /registerCollector
 * Body: { name, phone, vehicleType, assignedArea }
 */
const registerCollector = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "POST") {
            throw new Error("Bad request: Only POST method is allowed");
        }

        const { uid, email } = await verifyAuth(req);
        const { name, phone, vehicleType, assignedArea } = req.body;

        if (!name || !phone || !vehicleType) {
            throw new Error("Bad request: name, phone, and vehicleType are required");
        }

        // Check if already registered
        const existing = await admin.firestore().collection("collectors").doc(uid).get();
        if (existing.exists) {
            throw new Error("Bad request: Already registered as a collector");
        }

        const collectorData = {
            uid,
            name,
            email: email || "",
            phone,
            vehicleType,
            assignedArea: assignedArea || "",
            isAvailable: false,
            currentLocation: null,
            rating: 0,
            totalPickups: 0,
            totalRatings: 0,
            role: "collector",
            fcmTokens: [],
            createdAt: FieldValue.serverTimestamp(),
        };

        await admin.firestore().collection("collectors").doc(uid).set(collectorData);

        sendSuccess(res, { message: "Collector registered successfully", collector: collectorData }, 201);
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Toggle collector availability.
 * PUT /updateCollectorAvailability
 * Body: { isAvailable: true/false }
 */
const updateCollectorAvailability = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "PUT") {
            throw new Error("Bad request: Only PUT method is allowed");
        }

        const { uid } = await verifyAuthAndRole(req, ["collector"]);
        const { isAvailable } = req.body;

        if (typeof isAvailable !== "boolean") {
            throw new Error("Bad request: isAvailable must be a boolean");
        }

        await admin.firestore().collection("collectors").doc(uid).update({
            isAvailable,
            updatedAt: FieldValue.serverTimestamp(),
        });

        sendSuccess(res, { message: `Availability set to ${isAvailable}` });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Update collector's live location.
 * PUT /updateCollectorLocation
 * Body: { latitude, longitude }
 */
const updateCollectorLocation = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "PUT") {
            throw new Error("Bad request: Only PUT method is allowed");
        }

        const { uid } = await verifyAuthAndRole(req, ["collector"]);
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            throw new Error("Bad request: latitude and longitude are required");
        }

        await admin.firestore().collection("collectors").doc(uid).update({
            currentLocation: new GeoPoint(latitude, longitude),
            locationUpdatedAt: FieldValue.serverTimestamp(),
        });

        sendSuccess(res, { message: "Location updated" });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Get available collectors (optionally by area).
 * GET /getAvailableCollectors?area=xxx
 */
const getAvailableCollectors = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "GET") {
            throw new Error("Bad request: Only GET method is allowed");
        }

        await verifyAuth(req);

        let query = admin.firestore().collection("collectors").where("isAvailable", "==", true);

        const area = req.query.area;
        if (area) {
            query = query.where("assignedArea", "==", area);
        }

        const snapshot = await query.get();
        const collectors = [];
        snapshot.forEach((doc) => {
            collectors.push({ id: doc.id, ...doc.data() });
        });

        sendSuccess(res, { collectors, count: collectors.length });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Rate a collector after a completed pickup.
 * POST /rateCollector
 * Body: { collectorId, rating, pickupId }
 */
const rateCollector = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "POST") {
            throw new Error("Bad request: Only POST method is allowed");
        }

        const { uid } = await verifyAuthAndRole(req, ["user"]);
        const { collectorId, rating, pickupId } = req.body;

        if (!collectorId || !rating || !pickupId) {
            throw new Error("Bad request: collectorId, rating, and pickupId are required");
        }

        if (rating < 1 || rating > 5) {
            throw new Error("Bad request: Rating must be between 1 and 5");
        }

        // Verify the pickup belongs to this user and is completed
        const pickupDoc = await admin.firestore().collection("pickupRequests").doc(pickupId).get();
        if (!pickupDoc.exists) {
            throw new Error("Not found: Pickup request not found");
        }

        const pickupData = pickupDoc.data();
        if (pickupData.userId !== uid) {
            throw new Error("Forbidden: You can only rate your own pickups");
        }
        if (pickupData.status !== "completed") {
            throw new Error("Bad request: Can only rate completed pickups");
        }

        // Update pickup with rating
        await admin.firestore().collection("pickupRequests").doc(pickupId).update({ rating });

        // Recalculate collector's average rating
        const collectorDoc = await admin.firestore().collection("collectors").doc(collectorId).get();
        if (collectorDoc.exists) {
            const collectorData = collectorDoc.data();
            const totalRatings = (collectorData.totalRatings || 0) + 1;
            const currentTotal = (collectorData.rating || 0) * (collectorData.totalRatings || 0);
            const newAverage = (currentTotal + rating) / totalRatings;

            await admin.firestore().collection("collectors").doc(collectorId).update({
                rating: Math.round(newAverage * 10) / 10,
                totalRatings,
            });
        }

        sendSuccess(res, { message: "Rating submitted successfully" });
    } catch (error) {
        sendError(res, error);
    }
});

/**
 * HTTP Function: Get collector's own profile.
 * GET /getCollectorProfile
 */
const getCollectorProfile = onRequest(async (req, res) => {
    if (handleCors(req, res)) return;

    try {
        if (req.method !== "GET") {
            throw new Error("Bad request: Only GET method is allowed");
        }

        const { uid } = await verifyAuth(req);
        const doc = await admin.firestore().collection("collectors").doc(uid).get();

        if (!doc.exists) {
            throw new Error("Not found: Collector profile not found");
        }

        sendSuccess(res, { collector: { id: doc.id, ...doc.data() } });
    } catch (error) {
        sendError(res, error);
    }
});

module.exports = {
    onCollectorCreated,
    registerCollector,
    updateCollectorAvailability,
    updateCollectorLocation,
    getAvailableCollectors,
    rateCollector,
    getCollectorProfile,
};
