/**
 * Collector Routes — /api/collectors
 *
 * Profile:
 *   POST /register        — Register as waste collector
 *   GET  /profile         — Get own collector profile
 *   PUT  /profile         — Update profile
 *   PUT  /availability    — Toggle online/offline
 *   PUT  /location        — Update live GPS
 *
 * Pickups (collector side):
 *   GET  /pickups/available  — Get pending pickups matching vehicle capacity
 *   PUT  /pickups/:id/accept — Request to accept (→ AWAITING_ADMIN_APPROVAL)
 *   PUT  /pickups/:id/status — Update pickup status through flow
 *   PUT  /pickups/:id/weight — Update actual weight after collection
 *   GET  /pickups/history    — Get completed pickups
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue, GeoPoint } = require("firebase-admin/firestore");

// --- Vehicle capacity config ---
const VEHICLE_CONFIG = {
    two_wheeler: {
        maxWeightKg: 10,
        bins: null, // single load, no separate bins
        allowedWasteTypes: ["plastic"], // scooters can only carry plastic
    },
    three_wheeler: {
        maxWeightKg: 200,
        bins: {
            recyclable: { capacityKg: 50 },
            organic: { capacityKg: 40 },
            hazardous: { capacityKg: 20 },
            e_waste: { capacityKg: 30 },
            general: { capacityKg: 60 },
        },
    },
    truck: {
        maxWeightKg: 1000,
        bins: {
            recyclable: { capacityKg: 250 },
            organic: { capacityKg: 200 },
            hazardous: { capacityKg: 100 },
            e_waste: { capacityKg: 150 },
            general: { capacityKg: 300 },
        },
    },
};

// --- Helpers ---

async function getAuthUser(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Unauthorized: No token provided");
    }
    const token = authHeader.split("Bearer ")[1];
    return admin.auth().verifyIdToken(token);
}

async function requireCollector(req) {
    const decoded = await getAuthUser(req);
    const collectorDoc = await admin.firestore().collection("collectors").doc(decoded.uid).get();
    if (!collectorDoc.exists) {
        throw new Error("Forbidden: Collector profile not found");
    }
    return { decoded, collectorData: collectorDoc.data() };
}

function errorResponse(res, error) {
    const statusCode = error.message.startsWith("Unauthorized")
        ? 401
        : error.message.startsWith("Forbidden")
            ? 403
            : 500;
    res.status(statusCode).json({ success: false, error: error.message });
}

// =============================================================
//  PROFILE ENDPOINTS
// =============================================================

/**
 * POST /api/collectors/register
 * Body: { name, phone, vehicleType, vehicleNumber, registrationDocUrl, idProofUrl, bankDetails? }
 */
router.post("/register", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const {
            name,
            phone,
            vehicleType,
            vehicleNumber,
            registrationDocUrl,
            idProofUrl,
            bankDetails,
        } = req.body;

        if (!name || !phone || !vehicleType || !vehicleNumber) {
            return res.status(400).json({
                success: false,
                error: "name, phone, vehicleType, and vehicleNumber are required",
            });
        }

        if (!VEHICLE_CONFIG[vehicleType]) {
            return res.status(400).json({
                success: false,
                error: `Invalid vehicleType. Must be one of: ${Object.keys(VEHICLE_CONFIG).join(", ")}`,
            });
        }

        // Check if already registered
        const existing = await admin.firestore().collection("collectors").doc(decoded.uid).get();
        if (existing.exists) {
            return res.status(409).json({
                success: false,
                error: "Collector profile already exists",
            });
        }

        // Build bin state for three_wheeler / truck
        const vehicleCfg = VEHICLE_CONFIG[vehicleType];
        let bins = null;
        if (vehicleCfg.bins) {
            bins = {};
            for (const [wasteType, cfg] of Object.entries(vehicleCfg.bins)) {
                bins[wasteType] = { capacityKg: cfg.capacityKg, currentKg: 0 };
            }
        }

        const collectorData = {
            name,
            email: decoded.email || "",
            phone,
            photoUrl: "",
            rating: 0,
            totalPickups: 0,
            totalRatings: 0,
            totalHoursToday: 0,
            isOnline: false,
            idProofUrl: idProofUrl || "",
            vehicle: {
                vehicleType,
                vehicleNumber,
                registrationDocUrl: registrationDocUrl || "",
            },
            bankDetails: bankDetails || null,
            bins,
            maxWeightKg: vehicleCfg.maxWeightKg,
            currentLoadKg: 0,
            currentLocation: null,
            role: "collector",
            fcmTokens: [],
            createdAt: FieldValue.serverTimestamp(),
        };

        await admin.firestore().collection("collectors").doc(decoded.uid).set(collectorData);

        // Update admin stats
        const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
        await statsRef.set(
            { totalCollectors: FieldValue.increment(1) },
            { merge: true }
        );

        res.status(201).json({
            success: true,
            message: "Collector registered successfully",
            collector: { id: decoded.uid, ...collectorData },
        });
    } catch (error) {
        console.error("Register collector error:", error);
        errorResponse(res, error);
    }
});

/**
 * GET /api/collectors/profile
 */
router.get("/profile", async (req, res) => {
    try {
        const { decoded, collectorData } = await requireCollector(req);

        res.json({
            success: true,
            collector: {
                id: decoded.uid,
                ...collectorData,
            },
        });
    } catch (error) {
        console.error("Get collector profile error:", error);
        errorResponse(res, error);
    }
});

/**
 * PUT /api/collectors/profile
 * Body: { name?, phone?, photoUrl?, vehicle?, bankDetails? }
 */
router.put("/profile", async (req, res) => {
    try {
        const { decoded } = await requireCollector(req);
        const { name, phone, photoUrl, vehicle, bankDetails } = req.body;

        const updateData = { updatedAt: FieldValue.serverTimestamp() };

        if (name !== undefined) updateData.name = name;
        if (phone !== undefined) updateData.phone = phone;
        if (photoUrl !== undefined) updateData.photoUrl = photoUrl;
        if (bankDetails !== undefined) updateData.bankDetails = bankDetails;

        // If vehicle type changes, rebuild bins
        if (vehicle && vehicle.vehicleType) {
            if (!VEHICLE_CONFIG[vehicle.vehicleType]) {
                return res.status(400).json({
                    success: false,
                    error: `Invalid vehicleType. Must be one of: ${Object.keys(VEHICLE_CONFIG).join(", ")}`,
                });
            }
            updateData.vehicle = vehicle;
            const vehicleCfg = VEHICLE_CONFIG[vehicle.vehicleType];
            updateData.maxWeightKg = vehicleCfg.maxWeightKg;

            if (vehicleCfg.bins) {
                const bins = {};
                for (const [wasteType, cfg] of Object.entries(vehicleCfg.bins)) {
                    bins[wasteType] = { capacityKg: cfg.capacityKg, currentKg: 0 };
                }
                updateData.bins = bins;
            } else {
                updateData.bins = null;
            }
            updateData.currentLoadKg = 0;
        } else if (vehicle) {
            // Partial vehicle update (number, doc)
            updateData["vehicle.vehicleNumber"] = vehicle.vehicleNumber || "";
            updateData["vehicle.registrationDocUrl"] = vehicle.registrationDocUrl || "";
        }

        await admin.firestore().collection("collectors").doc(decoded.uid).update(updateData);

        res.json({ success: true, message: "Profile updated" });
    } catch (error) {
        console.error("Update collector profile error:", error);
        errorResponse(res, error);
    }
});

/**
 * PUT /api/collectors/availability
 * Body: { isOnline: true/false }
 */
router.put("/availability", async (req, res) => {
    try {
        const { decoded } = await requireCollector(req);
        const { isOnline } = req.body;

        if (typeof isOnline !== "boolean") {
            return res.status(400).json({
                success: false,
                error: "isOnline (boolean) is required",
            });
        }

        await admin.firestore().collection("collectors").doc(decoded.uid).update({
            isOnline,
            updatedAt: FieldValue.serverTimestamp(),
        });

        res.json({ success: true, message: `Availability set to ${isOnline}` });
    } catch (error) {
        console.error("Update availability error:", error);
        errorResponse(res, error);
    }
});

/**
 * PUT /api/collectors/location
 * Body: { latitude, longitude }
 */
router.put("/location", async (req, res) => {
    try {
        const { decoded } = await requireCollector(req);
        const { latitude, longitude } = req.body;

        if (latitude === undefined || longitude === undefined) {
            return res.status(400).json({
                success: false,
                error: "latitude and longitude are required",
            });
        }

        await admin.firestore().collection("collectors").doc(decoded.uid).update({
            currentLocation: new GeoPoint(latitude, longitude),
            locationUpdatedAt: FieldValue.serverTimestamp(),
        });

        res.json({ success: true, message: "Location updated" });
    } catch (error) {
        console.error("Update location error:", error);
        errorResponse(res, error);
    }
});

// =============================================================
//  PICKUP ENDPOINTS (COLLECTOR SIDE)
// =============================================================

/**
 * GET /api/collectors/pickups/available
 *
 * Returns pending pickups that match the collector's vehicle capacity
 * and available bin space. Scooters see small loads; trucks see large loads.
 */
router.get("/pickups/available", async (req, res) => {
    try {
        const { decoded, collectorData } = await requireCollector(req);

        if (!collectorData.isOnline) {
            return res.status(400).json({
                success: false,
                error: "You must be online to view available pickups",
            });
        }

        // Calculate remaining capacity
        const remainingCapacity = collectorData.maxWeightKg - (collectorData.currentLoadKg || 0);

        // Get all PENDING pickups
        const snapshot = await admin
            .firestore()
            .collection("pickupRequests")
            .where("status", "==", "PENDING")
            .orderBy("createdAt", "desc")
            .get();

        const pickups = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            const weightKg = data.weightKg || 0;

            // Skip if pickup exceeds remaining vehicle capacity
            if (weightKg > remainingCapacity) return;

            // Vehicle suitability check
            const vehicleType = collectorData.vehicle?.vehicleType;
            if (vehicleType === "two_wheeler" && weightKg > 10) return;
            if (vehicleType === "three_wheeler" && weightKg > 200) return;

            // Check waste type restrictions (scooters = plastic only)
            const vehicleCfg = VEHICLE_CONFIG[vehicleType];
            if (vehicleCfg?.allowedWasteTypes && data.wasteTypes) {
                const allAllowed = data.wasteTypes.every((wt) =>
                    vehicleCfg.allowedWasteTypes.includes(wt)
                );
                if (!allAllowed) return;
            }

            // If collector has bins, check waste type bin capacity
            if (collectorData.bins && data.wasteTypes) {
                const canFit = data.wasteTypes.every((wt) => {
                    const bin = collectorData.bins[wt];
                    if (!bin) return true; // waste type goes to general
                    return bin.currentKg + weightKg <= bin.capacityKg;
                });
                if (!canFit) return;
            }

            pickups.push({
                pickupId: doc.id,
                userId: data.userId,
                address: data.address,
                date: data.date,
                time: data.time,
                wasteTypes: data.wasteTypes,
                estimatedWeightKg: data.weightKg,
                estimatedPrice: data.price,
                notes: data.notes || "",
                isFragile: data.isFragile || false,
                createdAt: data.createdAt,
            });
        });

        res.json({ success: true, pickups, count: pickups.length });
    } catch (error) {
        console.error("Get available pickups error:", error);
        errorResponse(res, error);
    }
});

/**
 * PUT /api/collectors/pickups/:id/accept
 *
 * Collector requests to accept a pickup.
 * Status changes to AWAITING_ADMIN_APPROVAL (admin must approve).
 */
router.put("/pickups/:id/accept", async (req, res) => {
    try {
        const { decoded, collectorData } = await requireCollector(req);
        const pickupId = req.params.id;

        const pickupRef = admin.firestore().collection("pickupRequests").doc(pickupId);
        const pickupDoc = await pickupRef.get();

        if (!pickupDoc.exists) {
            return res.status(404).json({ success: false, error: "Pickup not found" });
        }

        const pickupData = pickupDoc.data();

        if (pickupData.status !== "PENDING") {
            return res.status(400).json({
                success: false,
                error: `Cannot accept pickup with status: ${pickupData.status}`,
            });
        }

        // Check vehicle capacity
        const vehicleCfg = VEHICLE_CONFIG[collectorData.vehicle?.vehicleType];
        const remainingCapacity = (vehicleCfg?.maxWeightKg || 0) - (collectorData.currentLoadKg || 0);
        if (pickupData.weightKg > remainingCapacity) {
            return res.status(400).json({
                success: false,
                error: "Pickup weight exceeds your remaining vehicle capacity",
            });
        }

        const acceptTimeline = {
            status: "AWAITING_ADMIN_APPROVAL",
            timestamp: new Date().toISOString(),
            message: `Collector ${collectorData.name} requested to accept`,
        };

        await pickupRef.update({
            status: "AWAITING_ADMIN_APPROVAL",
            collectorId: decoded.uid,
            collectorInfo: {
                name: collectorData.name,
                phone: collectorData.phone,
                vehicleType: collectorData.vehicle?.vehicleType || "",
                vehicleNumber: collectorData.vehicle?.vehicleNumber || "",
                rating: collectorData.rating || 0,
            },
            timeline: FieldValue.arrayUnion(acceptTimeline),
            updatedAt: FieldValue.serverTimestamp(),
        });

        res.json({
            success: true,
            message: "Pickup accept request submitted. Awaiting admin approval.",
        });
    } catch (error) {
        console.error("Accept pickup error:", error);
        errorResponse(res, error);
    }
});

/**
 * PUT /api/collectors/pickups/:id/status
 * Body: { status } — one of: ON_THE_WAY, REACHED, PICKED_UP, COMPLETED
 *
 * Moves pickup through the status flow after admin approval.
 * On COMPLETED, creates an earnings transaction.
 */
router.put("/pickups/:id/status", async (req, res) => {
    try {
        const { decoded, collectorData } = await requireCollector(req);
        const pickupId = req.params.id;
        const { status } = req.body;

        const validTransitions = {
            ACCEPTED: ["ON_THE_WAY"],
            ON_THE_WAY: ["REACHED"],
            REACHED: ["PICKED_UP"],
            PICKED_UP: ["COMPLETED"],
        };

        const pickupRef = admin.firestore().collection("pickupRequests").doc(pickupId);
        const pickupDoc = await pickupRef.get();

        if (!pickupDoc.exists) {
            return res.status(404).json({ success: false, error: "Pickup not found" });
        }

        const pickupData = pickupDoc.data();

        // Verify this collector is assigned
        if (pickupData.collectorId !== decoded.uid) {
            return res.status(403).json({
                success: false,
                error: "You are not assigned to this pickup",
            });
        }

        // Check valid status transition
        const allowed = validTransitions[pickupData.status];
        if (!allowed || !allowed.includes(status)) {
            return res.status(400).json({
                success: false,
                error: `Cannot transition from ${pickupData.status} to ${status}. Allowed: ${(allowed || []).join(", ")}`,
            });
        }

        const timelineEntry = {
            status,
            timestamp: new Date().toISOString(),
            message: `Status updated to ${status}`,
        };

        const updatePayload = {
            status,
            timeline: FieldValue.arrayUnion(timelineEntry),
            updatedAt: FieldValue.serverTimestamp(),
        };

        await pickupRef.update(updatePayload);

        // On COMPLETED: create earnings, update stats, reset bin load
        if (status === "COMPLETED") {
            const actualWeight = pickupData.actualWeightKg || pickupData.weightKg;
            const earningAmount = pickupData.price || 0;

            // Create earnings transaction
            const earningsRef = admin.firestore().collection("earnings").doc(decoded.uid);
            await earningsRef.set(
                {
                    collectorId: decoded.uid,
                    todayEarnings: FieldValue.increment(earningAmount),
                    weeklyEarnings: FieldValue.increment(earningAmount),
                    monthlyEarnings: FieldValue.increment(earningAmount),
                    pendingPayment: FieldValue.increment(earningAmount),
                },
                { merge: true }
            );

            // Create transaction record
            await earningsRef.collection("transactions").add({
                pickupId,
                amount: earningAmount,
                date: FieldValue.serverTimestamp(),
                isPaid: false,
                description: `Pickup ${pickupId} - ${actualWeight}kg`,
            });

            // Update collector stats
            await admin.firestore().collection("collectors").doc(decoded.uid).update({
                totalPickups: FieldValue.increment(1),
                currentLoadKg: FieldValue.increment(-actualWeight),
            });

            // Update admin stats
            const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
            await statsRef.set(
                { activeCollections: FieldValue.increment(-1) },
                { merge: true }
            );
        }

        res.json({ success: true, message: `Pickup status updated to ${status}` });
    } catch (error) {
        console.error("Update pickup status error:", error);
        errorResponse(res, error);
    }
});

/**
 * PUT /api/collectors/pickups/:id/weight
 * Body: { actualWeightKg }
 *
 * Collector updates the actual weight of waste collected.
 * Updates bin fill levels for three-wheelers/trucks.
 */
router.put("/pickups/:id/weight", async (req, res) => {
    try {
        const { decoded, collectorData } = await requireCollector(req);
        const pickupId = req.params.id;
        const { actualWeightKg } = req.body;

        if (actualWeightKg === undefined || actualWeightKg <= 0) {
            return res.status(400).json({
                success: false,
                error: "actualWeightKg must be a positive number",
            });
        }

        const pickupRef = admin.firestore().collection("pickupRequests").doc(pickupId);
        const pickupDoc = await pickupRef.get();

        if (!pickupDoc.exists) {
            return res.status(404).json({ success: false, error: "Pickup not found" });
        }

        const pickupData = pickupDoc.data();

        if (pickupData.collectorId !== decoded.uid) {
            return res.status(403).json({
                success: false,
                error: "You are not assigned to this pickup",
            });
        }

        if (!["PICKED_UP", "REACHED"].includes(pickupData.status)) {
            return res.status(400).json({
                success: false,
                error: "Weight can only be updated when status is REACHED or PICKED_UP",
            });
        }

        // Update pickup with actual weight
        await pickupRef.update({
            actualWeightKg,
            updatedAt: FieldValue.serverTimestamp(),
        });

        // Update collector's current load
        const previousActual = pickupData.actualWeightKg || 0;
        const loadDelta = actualWeightKg - previousActual;

        const collectorUpdate = {
            currentLoadKg: FieldValue.increment(loadDelta),
            updatedAt: FieldValue.serverTimestamp(),
        };

        // Update bin fill levels for three-wheelers/trucks
        if (collectorData.bins && pickupData.wasteTypes) {
            const primaryType = pickupData.wasteTypes[0] || "general";
            const binKey = collectorData.bins[primaryType] ? primaryType : "general";
            collectorUpdate[`bins.${binKey}.currentKg`] = FieldValue.increment(loadDelta);
        }

        await admin.firestore().collection("collectors").doc(decoded.uid).update(collectorUpdate);

        // Update admin stats with weight difference
        const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
        await statsRef.set(
            { totalWasteCollected: FieldValue.increment(loadDelta) },
            { merge: true }
        );

        res.json({
            success: true,
            message: `Actual weight updated to ${actualWeightKg}kg`,
            previousEstimate: pickupData.weightKg,
            actualWeightKg,
        });
    } catch (error) {
        console.error("Update weight error:", error);
        errorResponse(res, error);
    }
});

/**
 * GET /api/collectors/pickups/history
 *
 * Returns completed pickups for this collector.
 */
router.get("/pickups/history", async (req, res) => {
    try {
        const { decoded } = await requireCollector(req);

        const snapshot = await admin
            .firestore()
            .collection("pickupRequests")
            .where("collectorId", "==", decoded.uid)
            .where("status", "==", "COMPLETED")
            .orderBy("createdAt", "desc")
            .limit(50)
            .get();

        const pickups = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            pickups.push({
                pickupId: doc.id,
                userId: data.userId,
                address: data.address,
                date: data.date,
                wasteTypes: data.wasteTypes,
                estimatedWeightKg: data.weightKg,
                actualWeightKg: data.actualWeightKg || data.weightKg,
                price: data.price,
                userRating: data.userRating || null,
                userReview: data.userReview || null,
                proofPhotoUrl: data.proofPhotoUrl || null,
                completedAt: data.updatedAt,
            });
        });

        res.json({ success: true, pickups, count: pickups.length });
    } catch (error) {
        console.error("Get pickup history error:", error);
        errorResponse(res, error);
    }
});

module.exports = router;
