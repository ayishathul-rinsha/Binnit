/**
 * Admin Routes — /api/admin
 *
 * GET  /dashboard               — Dashboard stats
 * GET  /bins                    — Bin activity list
 * GET  /users                   — User management
 * GET  /pickups/pending-approval — Pickups awaiting admin approval
 * PUT  /pickups/:id/approve      — Approve or reject collector's pickup accept
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");

// Helper: verify auth and require admin role
async function requireAdmin(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Unauthorized: No token provided");
    }
    const token = authHeader.split("Bearer ")[1];
    const decoded = await admin.auth().verifyIdToken(token);

    // Check if user is admin
    const adminDoc = await admin.firestore().collection("admins").doc(decoded.uid).get();
    if (!adminDoc.exists) {
        throw new Error("Forbidden: Admin access required");
    }

    return decoded;
}

/**
 * GET /api/admin/dashboard
 * Response: { totalSmartBins, totalUsers, totalWasteCollected, activeCollections }
 */
router.get("/dashboard", async (req, res) => {
    try {
        await requireAdmin(req);

        // Get aggregated stats
        const statsDoc = await admin
            .firestore()
            .collection("adminStats")
            .doc("dashboard")
            .get();

        const stats = statsDoc.exists ? statsDoc.data() : {};

        // Count users from collection for accuracy
        const usersSnapshot = await admin.firestore().collection("users").count().get();
        const totalUsers = usersSnapshot.data().count;

        // Count active pickups
        const activeSnapshot = await admin
            .firestore()
            .collection("pickupRequests")
            .where("status", "in", ["PENDING", "AWAITING_ADMIN_APPROVAL", "ACCEPTED", "ON_THE_WAY", "REACHED", "PICKED_UP"])
            .count()
            .get();
        const activeCollections = activeSnapshot.data().count;

        // Count bins (placeholder)
        const binsSnapshot = await admin.firestore().collection("bins").count().get();
        const totalSmartBins = binsSnapshot.data().count;

        res.json({
            success: true,
            totalSmartBins,
            totalUsers,
            totalWasteCollected: stats.totalWasteCollected || 0,
            activeCollections,
        });
    } catch (error) {
        console.error("Dashboard error:", error);
        const statusCode = error.message.startsWith("Unauthorized")
            ? 401
            : error.message.startsWith("Forbidden")
                ? 403
                : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get dashboard stats",
        });
    }
});

/**
 * GET /api/admin/bins
 * Response: { bins: [{ binId, location, fillLevel, status, lastUpdated }] }
 *
 * Placeholder — reads from `bins` collection.
 * Smart bin integration will populate this collection later.
 */
router.get("/bins", async (req, res) => {
    try {
        await requireAdmin(req);

        const snapshot = await admin
            .firestore()
            .collection("bins")
            .orderBy("lastUpdated", "desc")
            .get();

        const bins = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            bins.push({
                binId: doc.id,
                location: data.location || "",
                fillLevel: data.fillPercent || 0,
                status: data.status || "unknown",
                type: data.type || "general",
                lastUpdated: data.lastUpdated || null,
            });
        });

        res.json({ success: true, bins, count: bins.length });
    } catch (error) {
        console.error("Get bins error:", error);
        const statusCode = error.message.startsWith("Unauthorized")
            ? 401
            : error.message.startsWith("Forbidden")
                ? 403
                : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get bins",
        });
    }
});

/**
 * GET /api/admin/users
 * Response: { users: [{ id, name, email, role }] }
 */
router.get("/users", async (req, res) => {
    try {
        await requireAdmin(req);

        // Get all users
        const usersSnapshot = await admin.firestore().collection("users").get();
        const users = [];

        usersSnapshot.forEach((doc) => {
            const data = doc.data();
            users.push({
                id: doc.id,
                name: data.name || "",
                email: data.email || "",
                role: "user",
                phone: data.phone || "",
                createdAt: data.createdAt || null,
            });
        });

        // Get all collectors
        const collectorsSnapshot = await admin.firestore().collection("collectors").get();
        collectorsSnapshot.forEach((doc) => {
            const data = doc.data();
            users.push({
                id: doc.id,
                name: data.name || "",
                email: data.email || "",
                role: "collector",
                phone: data.phone || "",
                createdAt: data.createdAt || null,
            });
        });

        // Sort by createdAt descending
        users.sort((a, b) => {
            const aTime = a.createdAt ? (a.createdAt.toDate ? a.createdAt.toDate() : new Date(a.createdAt)) : new Date(0);
            const bTime = b.createdAt ? (b.createdAt.toDate ? b.createdAt.toDate() : new Date(b.createdAt)) : new Date(0);
            return bTime - aTime;
        });

        res.json({ success: true, users, count: users.length });
    } catch (error) {
        console.error("Get users error:", error);
        const statusCode = error.message.startsWith("Unauthorized")
            ? 401
            : error.message.startsWith("Forbidden")
                ? 403
                : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get users",
        });
    }
});

// =============================================================
//  PICKUP APPROVAL ENDPOINTS
// =============================================================

/**
 * GET /api/admin/pickups/pending-approval
 * Response: { pickups: [{ pickupId, userId, collectorInfo, wasteTypes, weightKg, ... }] }
 */
router.get("/pickups/pending-approval", async (req, res) => {
    try {
        await requireAdmin(req);

        const snapshot = await admin
            .firestore()
            .collection("pickupRequests")
            .where("status", "==", "AWAITING_ADMIN_APPROVAL")
            .orderBy("updatedAt", "desc")
            .get();

        const pickups = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            pickups.push({
                pickupId: doc.id,
                userId: data.userId,
                address: data.address,
                date: data.date,
                time: data.time,
                wasteTypes: data.wasteTypes,
                weightKg: data.weightKg,
                price: data.price,
                collectorId: data.collectorId,
                collectorInfo: data.collectorInfo || {},
                createdAt: data.createdAt,
                updatedAt: data.updatedAt,
            });
        });

        res.json({ success: true, pickups, count: pickups.length });
    } catch (error) {
        console.error("Get pending approval error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401
            : error.message.startsWith("Forbidden") ? 403 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get pending approvals",
        });
    }
});

/**
 * PUT /api/admin/pickups/:id/approve
 * Body: { approved: true/false, reason?: string }
 *
 * If approved: status → ACCEPTED
 * If rejected: status → PENDING, collectorId cleared
 */
router.put("/pickups/:id/approve", async (req, res) => {
    try {
        await requireAdmin(req);
        const pickupId = req.params.id;
        const { approved, reason } = req.body;

        if (typeof approved !== "boolean") {
            return res.status(400).json({
                success: false,
                error: "approved (boolean) is required",
            });
        }

        const pickupRef = admin.firestore().collection("pickupRequests").doc(pickupId);
        const pickupDoc = await pickupRef.get();

        if (!pickupDoc.exists) {
            return res.status(404).json({ success: false, error: "Pickup not found" });
        }

        const pickupData = pickupDoc.data();

        if (pickupData.status !== "AWAITING_ADMIN_APPROVAL") {
            return res.status(400).json({
                success: false,
                error: `Pickup is not awaiting approval (current: ${pickupData.status})`,
            });
        }

        if (approved) {
            const approveTimeline = {
                status: "ACCEPTED",
                timestamp: new Date().toISOString(),
                message: "Admin approved the pickup assignment",
            };

            await pickupRef.update({
                status: "ACCEPTED",
                timeline: FieldValue.arrayUnion(approveTimeline),
                updatedAt: FieldValue.serverTimestamp(),
            });

            res.json({ success: true, message: "Pickup approved and assigned to collector" });
        } else {
            const rejectTimeline = {
                status: "REJECTED",
                timestamp: new Date().toISOString(),
                message: reason || "Admin rejected the pickup assignment",
            };

            await pickupRef.update({
                status: "PENDING",
                collectorId: null,
                collectorInfo: null,
                timeline: FieldValue.arrayUnion(rejectTimeline),
                updatedAt: FieldValue.serverTimestamp(),
            });

            res.json({ success: true, message: "Pickup assignment rejected, returned to pending" });
        }
    } catch (error) {
        console.error("Approve pickup error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401
            : error.message.startsWith("Forbidden") ? 403 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to process approval",
        });
    }
});

module.exports = router;
