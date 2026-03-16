/**
 * Admin Routes — /api/admin
 *
 * POST /admins                   — Create a new admin (super-admin only)
 * GET  /admins                   — List all admins
 * GET  /admins/me                — Get own admin profile
 * GET  /admins/:id               — Get admin profile by ID
 * PUT  /admins/:id               — Update admin profile
 * DELETE /admins/:id             — Delete/deactivate admin
 *
 * GET  /dashboard               — Dashboard stats
 * GET  /bins                    — Bin activity list
 * GET  /users                   — User management
 * GET  /pickups                 — All pickup requests (with optional ?status filter)
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

// =============================================================
//  ADMIN PROFILE ENDPOINTS
// =============================================================

/**
 * POST /api/admin/admins
 * Body: { name, email, password, phone?, role?, permissions? }
 * Response: { adminId, name, email }
 *
 * Creates a new admin. Requires super-admin (isSuperAdmin: true).
 */
router.post("/admins", async (req, res) => {
    try {
        const decoded = await requireAdmin(req);

        // Only super-admins can create other admins
        const callerDoc = await admin.firestore().collection("admins").doc(decoded.uid).get();
        if (!callerDoc.data()?.isSuperAdmin) {
            return res.status(403).json({ success: false, error: "Only super-admins can create other admins" });
        }

        const { name, email, password, phone, role, permissions } = req.body;
        if (!name || !email || !password) {
            return res.status(400).json({ success: false, error: "name, email, and password are required" });
        }

        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName: name,
            phoneNumber: phone || undefined,
        });

        // Store full admin profile in admins collection
        const adminData = {
            name,
            email,
            phone: phone || "",
            role: role || "admin",
            isSuperAdmin: false,
            permissions: permissions || ["dashboard", "users", "pickups", "collectors"],
            isActive: true,
            createdBy: decoded.uid,
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        };

        await admin.firestore().collection("admins").doc(userRecord.uid).set(adminData);

        res.status(201).json({
            success: true,
            adminId: userRecord.uid,
            name,
            email,
        });
    } catch (error) {
        console.error("Create admin error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401
            : error.message.startsWith("Forbidden") ? 403
            : error.code === "auth/email-already-exists" ? 409 : 500;
        res.status(statusCode).json({ success: false, error: error.message || "Failed to create admin" });
    }
});

/**
 * GET /api/admin/admins
 * Response: { admins: [...] }
 *
 * Lists all admin profiles.
 */
router.get("/admins", async (req, res) => {
    try {
        await requireAdmin(req);

        const snapshot = await admin.firestore()
            .collection("admins")
            .orderBy("createdAt", "desc")
            .get();

        const admins = [];
        snapshot.forEach((doc) => {
            const d = doc.data();
            admins.push({
                adminId: doc.id,
                name: d.name,
                email: d.email,
                phone: d.phone || "",
                role: d.role || "admin",
                isSuperAdmin: d.isSuperAdmin || false,
                permissions: d.permissions || [],
                isActive: d.isActive !== false,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
            });
        });

        res.json({ success: true, admins, count: admins.length });
    } catch (error) {
        console.error("List admins error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 403;
        res.status(statusCode).json({ success: false, error: error.message || "Failed to list admins" });
    }
});

/**
 * GET /api/admin/admins/me
 * Response: { admin profile }
 */
router.get("/admins/me", async (req, res) => {
    try {
        const decoded = await requireAdmin(req);
        const doc = await admin.firestore().collection("admins").doc(decoded.uid).get();
        const d = doc.data();

        res.json({
            success: true,
            admin: {
                adminId: doc.id,
                name: d.name,
                email: d.email,
                phone: d.phone || "",
                role: d.role || "admin",
                isSuperAdmin: d.isSuperAdmin || false,
                permissions: d.permissions || [],
                isActive: d.isActive !== false,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
            },
        });
    } catch (error) {
        console.error("Get own admin profile error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 403;
        res.status(statusCode).json({ success: false, error: error.message });
    }
});

/**
 * GET /api/admin/admins/:id
 * Response: { admin profile }
 */
router.get("/admins/:id", async (req, res) => {
    try {
        await requireAdmin(req);
        const doc = await admin.firestore().collection("admins").doc(req.params.id).get();

        if (!doc.exists) {
            return res.status(404).json({ success: false, error: "Admin not found" });
        }

        const d = doc.data();
        res.json({
            success: true,
            admin: {
                adminId: doc.id,
                name: d.name,
                email: d.email,
                phone: d.phone || "",
                role: d.role || "admin",
                isSuperAdmin: d.isSuperAdmin || false,
                permissions: d.permissions || [],
                isActive: d.isActive !== false,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
            },
        });
    } catch (error) {
        console.error("Get admin profile error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 403;
        res.status(statusCode).json({ success: false, error: error.message });
    }
});

/**
 * PUT /api/admin/admins/:id
 * Body: { name?, phone?, role?, permissions?, isActive? }
 * Response: { success }
 */
router.put("/admins/:id", async (req, res) => {
    try {
        const decoded = await requireAdmin(req);
        const targetId = req.params.id;

        // Can only update own profile unless super-admin
        const callerDoc = await admin.firestore().collection("admins").doc(decoded.uid).get();
        const isSuperAdmin = callerDoc.data()?.isSuperAdmin || false;

        if (decoded.uid !== targetId && !isSuperAdmin) {
            return res.status(403).json({ success: false, error: "You can only update your own profile" });
        }

        const targetDoc = await admin.firestore().collection("admins").doc(targetId).get();
        if (!targetDoc.exists) {
            return res.status(404).json({ success: false, error: "Admin not found" });
        }

        const { name, phone, role, permissions, isActive } = req.body;
        const updates = { updatedAt: FieldValue.serverTimestamp() };

        if (name !== undefined) updates.name = name;
        if (phone !== undefined) updates.phone = phone;
        if (isSuperAdmin && role !== undefined) updates.role = role;
        if (isSuperAdmin && permissions !== undefined) updates.permissions = permissions;
        if (isSuperAdmin && isActive !== undefined) updates.isActive = isActive;

        await admin.firestore().collection("admins").doc(targetId).update(updates);

        // Sync name to Firebase Auth if changed
        if (name) {
            await admin.auth().updateUser(targetId, { displayName: name }).catch(() => {});
        }

        res.json({ success: true, message: "Admin profile updated" });
    } catch (error) {
        console.error("Update admin profile error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 403;
        res.status(statusCode).json({ success: false, error: error.message });
    }
});

/**
 * DELETE /api/admin/admins/:id
 * Deactivates (soft delete) an admin. Super-admin only.
 */
router.delete("/admins/:id", async (req, res) => {
    try {
        const decoded = await requireAdmin(req);

        const callerDoc = await admin.firestore().collection("admins").doc(decoded.uid).get();
        if (!callerDoc.data()?.isSuperAdmin) {
            return res.status(403).json({ success: false, error: "Only super-admins can delete admins" });
        }

        const targetId = req.params.id;
        if (targetId === decoded.uid) {
            return res.status(400).json({ success: false, error: "You cannot delete your own account" });
        }

        const targetDoc = await admin.firestore().collection("admins").doc(targetId).get();
        if (!targetDoc.exists) {
            return res.status(404).json({ success: false, error: "Admin not found" });
        }

        // Soft-delete: mark as inactive and disable Firebase Auth account
        await admin.firestore().collection("admins").doc(targetId).update({
            isActive: false,
            updatedAt: FieldValue.serverTimestamp(),
        });
        await admin.auth().updateUser(targetId, { disabled: true }).catch(() => {});

        res.json({ success: true, message: "Admin deactivated" });
    } catch (error) {
        console.error("Delete admin error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 403;
        res.status(statusCode).json({ success: false, error: error.message });
    }
});

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
//  PICKUP MANAGEMENT ENDPOINTS
// =============================================================

/**
 * GET /api/admin/pickups?status=xxx
 * Response: { pickups: [...], count }
 *
 * Returns all pickup requests. Optionally filter by status query param.
 * Valid statuses: PENDING, AWAITING_ADMIN_APPROVAL, ACCEPTED, ON_THE_WAY,
 *                 REACHED, PICKED_UP, COMPLETED, CANCELLED
 */
router.get("/pickups", async (req, res) => {
    try {
        await requireAdmin(req);
        const { status } = req.query;

        let query = admin.firestore().collection("pickupRequests");

        if (status) {
            query = query.where("status", "==", status.toUpperCase());
        }

        query = query.orderBy("createdAt", "desc");

        const snapshot = await query.get();

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
                status: data.status,
                collectorId: data.collectorId || null,
                collectorInfo: data.collectorInfo || null,
                driverInfo: data.driverInfo || null,
                notes: data.notes || "",
                isFragile: data.isFragile || false,
                needBags: data.needBags || false,
                needHelp: data.needHelp || false,
                timeline: data.timeline || [],
                priceBreakdown: data.priceBreakdown || null,
                createdAt: data.createdAt,
                updatedAt: data.updatedAt,
            });
        });

        res.json({ success: true, pickups, count: pickups.length });
    } catch (error) {
        console.error("Get all pickups error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401
            : error.message.startsWith("Forbidden") ? 403 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get pickups",
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
