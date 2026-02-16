/**
 * User Routes (Express) — /api/users
 *
 * GET  /profile    — Get authenticated user's profile
 * PUT  /profile    — Update profile
 * GET  /addresses  — List saved addresses
 * POST /addresses  — Add new address
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");

// Helper: verify auth from request
async function getAuthUser(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Unauthorized: No token provided");
    }
    const token = authHeader.split("Bearer ")[1];
    return admin.auth().verifyIdToken(token);
}

/**
 * GET /api/users/profile
 * Response: { user: { ... } }
 */
router.get("/profile", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);

        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(decoded.uid)
            .get();

        if (!userDoc.exists) {
            return res.status(404).json({
                success: false,
                error: "User profile not found",
            });
        }

        res.json({
            success: true,
            user: { id: userDoc.id, ...userDoc.data() },
        });
    } catch (error) {
        console.error("Get profile error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get profile",
        });
    }
});

/**
 * PUT /api/users/profile
 * Body: { name, phone, address, ... }
 * Response: { message }
 */
router.put("/profile", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const { name, phone, address, photoUrl } = req.body;

        const updateData = {
            updatedAt: FieldValue.serverTimestamp(),
        };

        if (name !== undefined) updateData.name = name;
        if (phone !== undefined) updateData.phone = phone;
        if (address !== undefined) updateData.address = address;
        if (photoUrl !== undefined) updateData.photoUrl = photoUrl;

        await admin.firestore().collection("users").doc(decoded.uid).update(updateData);

        res.json({
            success: true,
            message: "Profile updated successfully",
        });
    } catch (error) {
        console.error("Update profile error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to update profile",
        });
    }
});

/**
 * GET /api/users/addresses
 * Response: { addresses: [...] }
 */
router.get("/addresses", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);

        const snapshot = await admin
            .firestore()
            .collection("users")
            .doc(decoded.uid)
            .collection("addresses")
            .orderBy("createdAt", "desc")
            .get();

        const addresses = [];
        snapshot.forEach((doc) => {
            addresses.push({ id: doc.id, ...doc.data() });
        });

        res.json({ success: true, addresses });
    } catch (error) {
        console.error("Get addresses error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get addresses",
        });
    }
});

/**
 * POST /api/users/addresses
 * Body: { label, fullAddress, lat, lng }
 * Response: { addressId, message }
 */
router.post("/addresses", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const { label, fullAddress, lat, lng, isDefault } = req.body;

        if (!label || !fullAddress) {
            return res.status(400).json({
                success: false,
                error: "label and fullAddress are required",
            });
        }

        const addressData = {
            label,
            fullAddress,
            lat: lat || null,
            lng: lng || null,
            isDefault: isDefault || false,
            createdAt: FieldValue.serverTimestamp(),
        };

        // If this is set as default, unset other defaults
        if (isDefault) {
            const existingAddresses = await admin
                .firestore()
                .collection("users")
                .doc(decoded.uid)
                .collection("addresses")
                .where("isDefault", "==", true)
                .get();

            const batch = admin.firestore().batch();
            existingAddresses.forEach((doc) => {
                batch.update(doc.ref, { isDefault: false });
            });

            const newRef = admin
                .firestore()
                .collection("users")
                .doc(decoded.uid)
                .collection("addresses")
                .doc();
            batch.set(newRef, addressData);
            await batch.commit();

            return res.status(201).json({
                success: true,
                addressId: newRef.id,
                message: "Address added successfully",
            });
        }

        const docRef = await admin
            .firestore()
            .collection("users")
            .doc(decoded.uid)
            .collection("addresses")
            .add(addressData);

        res.status(201).json({
            success: true,
            addressId: docRef.id,
            message: "Address added successfully",
        });
    } catch (error) {
        console.error("Add address error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to add address",
        });
    }
});

module.exports = router;
