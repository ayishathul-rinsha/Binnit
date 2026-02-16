/**
 * Pickup Routes — /api/pickups
 *
 * POST /schedule       — Create a new pickup
 * GET  /list           — Get user's pickups
 * GET  /:id            — Get pickup details
 * PUT  /:id/cancel     — Cancel a pickup
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const crypto = require("crypto");

// Helper: verify auth from request
async function getAuthUser(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Unauthorized: No token provided");
    }
    const token = authHeader.split("Bearer ")[1];
    return admin.auth().verifyIdToken(token);
}

// Price calculation helper
function calculatePrice(wasteTypes = [], weightKg = 0) {
    const basePrice = 49;
    const weightCharge = weightKg * 5;

    // Type surcharges
    const typeSurcharges = {
        general: 0,
        recyclable: 0,
        organic: 10,
        hazardous: 50,
        e_waste: 40,
        paper: 0,
        plastic: 5,
        metal: 10,
        glass: 15,
    };

    let typeCharge = 0;
    wasteTypes.forEach((type) => {
        typeCharge += typeSurcharges[type] || 0;
    });

    const total = basePrice + weightCharge + typeCharge;

    return { basePrice, weightCharge, typeCharge, total };
}

/**
 * POST /api/pickups/schedule
 * Body: { userId, address, date, time, wasteTypes[], weightKg, notes, isFragile, needBags, needHelp }
 * Response: { pickupId, estimatedPrice }
 */
router.post("/schedule", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const {
            userId,
            address,
            date,
            time,
            wasteTypes,
            weightKg,
            notes,
            isFragile,
            needBags,
            needHelp,
        } = req.body;

        // Use authenticated user's ID if userId not provided
        const effectiveUserId = userId || decoded.uid;

        if (!address || !date || !time || !wasteTypes || !weightKg) {
            return res.status(400).json({
                success: false,
                error: "address, date, time, wasteTypes, and weightKg are required",
            });
        }

        const priceBreakdown = calculatePrice(wasteTypes, weightKg);

        const pickupData = {
            userId: effectiveUserId,
            address,
            date,
            time,
            wasteTypes,
            weightKg,
            notes: notes || "",
            isFragile: isFragile || false,
            needBags: needBags || false,
            needHelp: needHelp || false,
            status: "PENDING",
            price: priceBreakdown.total,
            priceBreakdown,
            driverId: null,
            driverInfo: null,
            timeline: [
                {
                    status: "PENDING",
                    timestamp: new Date().toISOString(),
                    message: "Pickup request created",
                },
            ],
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        };

        const docRef = await admin
            .firestore()
            .collection("pickupRequests")
            .add(pickupData);

        // Update admin stats
        const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
        await statsRef.set(
            {
                totalWasteCollected: FieldValue.increment(weightKg),
                activeCollections: FieldValue.increment(1),
            },
            { merge: true }
        );

        res.status(201).json({
            success: true,
            pickupId: docRef.id,
            estimatedPrice: priceBreakdown.total,
            priceBreakdown,
        });
    } catch (error) {
        console.error("Schedule pickup error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to schedule pickup",
        });
    }
});

/**
 * GET /api/pickups/list?userId=xxx
 * Response: { pickups: [...] }
 */
router.get("/list", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const userId = req.query.userId || decoded.uid;

        const snapshot = await admin
            .firestore()
            .collection("pickupRequests")
            .where("userId", "==", userId)
            .orderBy("createdAt", "desc")
            .get();

        const pickups = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            pickups.push({
                pickupId: doc.id,
                status: data.status,
                date: data.date,
                time: data.time,
                address: data.address,
                wasteTypes: data.wasteTypes,
                weightKg: data.weightKg,
                price: data.price,
                createdAt: data.createdAt,
            });
        });

        res.json({ success: true, pickups, count: pickups.length });
    } catch (error) {
        console.error("List pickups error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to list pickups",
        });
    }
});

/**
 * GET /api/pickups/:id
 * Response: { pickup details with driver info, timeline }
 */
router.get("/:id", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const pickupId = req.params.id;

        const doc = await admin
            .firestore()
            .collection("pickupRequests")
            .doc(pickupId)
            .get();

        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                error: "Pickup not found",
            });
        }

        const data = doc.data();

        // Fetch driver info if assigned
        let driverInfo = null;
        if (data.driverId) {
            const driverDoc = await admin
                .firestore()
                .collection("collectors")
                .doc(data.driverId)
                .get();

            if (driverDoc.exists) {
                const driverData = driverDoc.data();
                driverInfo = {
                    driverId: driverDoc.id,
                    name: driverData.name,
                    phone: driverData.phone,
                    rating: driverData.rating,
                    totalTrips: driverData.totalPickups || 0,
                    photoUrl: driverData.photoUrl || null,
                    vehicle: {
                        name: driverData.vehicleType || "",
                        color: driverData.vehicleColor || "",
                        licensePlate: driverData.licensePlate || "",
                        verified: driverData.verified || false,
                    },
                    currentLocation: driverData.currentLocation || null,
                };
            }
        }

        res.json({
            success: true,
            pickupId: doc.id,
            status: data.status,
            date: data.date,
            time: data.time,
            address: data.address,
            wasteTypes: data.wasteTypes,
            weightKg: data.weightKg,
            price: data.price,
            priceBreakdown: data.priceBreakdown,
            notes: data.notes,
            isFragile: data.isFragile,
            needBags: data.needBags,
            needHelp: data.needHelp,
            driverInfo,
            timeline: data.timeline || [],
            createdAt: data.createdAt,
        });
    } catch (error) {
        console.error("Get pickup error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get pickup details",
        });
    }
});

/**
 * PUT /api/pickups/:id/cancel
 * Response: { message }
 */
router.put("/:id/cancel", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const pickupId = req.params.id;

        const docRef = admin
            .firestore()
            .collection("pickupRequests")
            .doc(pickupId);
        const doc = await docRef.get();

        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                error: "Pickup not found",
            });
        }

        const data = doc.data();

        // Only allow cancellation of pending or confirmed pickups
        if (!["PENDING", "CONFIRMED"].includes(data.status)) {
            return res.status(400).json({
                success: false,
                error: `Cannot cancel pickup with status: ${data.status}`,
            });
        }

        // Verify ownership
        if (data.userId !== decoded.uid) {
            return res.status(403).json({
                success: false,
                error: "You can only cancel your own pickups",
            });
        }

        const cancelTimeline = {
            status: "CANCELLED",
            timestamp: new Date().toISOString(),
            message: "Pickup cancelled by user",
        };

        await docRef.update({
            status: "CANCELLED",
            timeline: FieldValue.arrayUnion(cancelTimeline),
            updatedAt: FieldValue.serverTimestamp(),
        });

        // Update admin stats
        const statsRef = admin.firestore().collection("adminStats").doc("dashboard");
        await statsRef.set(
            {
                activeCollections: FieldValue.increment(-1),
            },
            { merge: true }
        );

        res.json({
            success: true,
            message: "Pickup cancelled successfully",
        });
    } catch (error) {
        console.error("Cancel pickup error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to cancel pickup",
        });
    }
});

module.exports = router;
