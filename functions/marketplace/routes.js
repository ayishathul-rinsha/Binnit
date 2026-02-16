/**
 * Marketplace Routes — /api/marketplace
 *
 * GET  /rates              — Current waste rates
 * GET  /earnings?userId=xxx — User's earnings
 * POST /sell               — Sell waste
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

// Default marketplace rates (seeded if collection is empty)
const DEFAULT_RATES = [
    { material: "Newspaper", category: "paper", ratePerKg: 14, trend: "up", changePercent: 5 },
    { material: "Cardboard", category: "paper", ratePerKg: 10, trend: "up", changePercent: 3 },
    { material: "Office Paper", category: "paper", ratePerKg: 12, trend: "down", changePercent: 2 },
    { material: "PET Bottles", category: "plastic", ratePerKg: 18, trend: "up", changePercent: 8 },
    { material: "HDPE Plastic", category: "plastic", ratePerKg: 15, trend: "up", changePercent: 4 },
    { material: "Mixed Plastic", category: "plastic", ratePerKg: 8, trend: "down", changePercent: 3 },
    { material: "Aluminium", category: "metal", ratePerKg: 90, trend: "up", changePercent: 12 },
    { material: "Iron/Steel", category: "metal", ratePerKg: 28, trend: "down", changePercent: 1 },
    { material: "Copper", category: "metal", ratePerKg: 450, trend: "up", changePercent: 6 },
    { material: "Glass Bottles", category: "glass", ratePerKg: 5, trend: "down", changePercent: 2 },
    { material: "Broken Glass", category: "glass", ratePerKg: 3, trend: "down", changePercent: 5 },
    { material: "Mobile Phones", category: "e_waste", ratePerKg: 150, trend: "up", changePercent: 10 },
    { material: "Computer Parts", category: "e_waste", ratePerKg: 80, trend: "up", changePercent: 7 },
    { material: "Batteries", category: "e_waste", ratePerKg: 60, trend: "up", changePercent: 4 },
    { material: "Food Waste", category: "organic", ratePerKg: 2, trend: "up", changePercent: 1 },
    { material: "Garden Waste", category: "organic", ratePerKg: 3, trend: "up", changePercent: 2 },
];

// Seed rates if collection is empty
async function ensureRatesExist() {
    const snapshot = await admin.firestore().collection("marketplaceRates").limit(1).get();

    if (snapshot.empty) {
        const batch = admin.firestore().batch();
        DEFAULT_RATES.forEach((rate) => {
            const docRef = admin.firestore().collection("marketplaceRates").doc();
            batch.set(docRef, {
                ...rate,
                updatedAt: FieldValue.serverTimestamp(),
            });
        });
        await batch.commit();
    }
}

/**
 * GET /api/marketplace/rates
 * Response: { rates: [...] }
 */
router.get("/rates", async (req, res) => {
    try {
        await ensureRatesExist();

        const snapshot = await admin
            .firestore()
            .collection("marketplaceRates")
            .orderBy("category")
            .get();

        const rates = [];
        snapshot.forEach((doc) => {
            rates.push({ id: doc.id, ...doc.data() });
        });

        res.json({ success: true, rates });
    } catch (error) {
        console.error("Get rates error:", error);
        res.status(500).json({
            success: false,
            error: error.message || "Failed to get marketplace rates",
        });
    }
});

/**
 * GET /api/marketplace/earnings?userId=xxx
 * Response: { totalEarnings, thisMonth, changePercent }
 */
router.get("/earnings", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const userId = req.query.userId || decoded.uid;

        // Get all marketplace orders for this user
        const snapshot = await admin
            .firestore()
            .collection("marketplaceOrders")
            .where("userId", "==", userId)
            .get();

        let totalEarnings = 0;
        let thisMonth = 0;
        let lastMonth = 0;

        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);

        snapshot.forEach((doc) => {
            const data = doc.data();
            totalEarnings += data.amount || 0;

            if (data.createdAt) {
                const orderDate = data.createdAt.toDate ? data.createdAt.toDate() : new Date(data.createdAt);
                if (orderDate >= startOfMonth) {
                    thisMonth += data.amount || 0;
                } else if (orderDate >= startOfLastMonth && orderDate < startOfMonth) {
                    lastMonth += data.amount || 0;
                }
            }
        });

        // Calculate month-over-month change
        const changePercent =
            lastMonth > 0
                ? Math.round(((thisMonth - lastMonth) / lastMonth) * 100)
                : thisMonth > 0
                    ? 100
                    : 0;

        res.json({
            success: true,
            totalEarnings,
            thisMonth,
            changePercent,
        });
    } catch (error) {
        console.error("Get earnings error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get earnings",
        });
    }
});

/**
 * POST /api/marketplace/sell
 * Body: { material, weightKg }
 * Response: { orderId, amount }
 */
router.post("/sell", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const { material, weightKg } = req.body;

        if (!material || !weightKg) {
            return res.status(400).json({
                success: false,
                error: "material and weightKg are required",
            });
        }

        // Look up the rate for this material
        const rateSnapshot = await admin
            .firestore()
            .collection("marketplaceRates")
            .where("material", "==", material)
            .limit(1)
            .get();

        if (rateSnapshot.empty) {
            return res.status(404).json({
                success: false,
                error: `No rate found for material: ${material}`,
            });
        }

        const rateData = rateSnapshot.docs[0].data();
        const amount = Math.round(rateData.ratePerKg * weightKg * 100) / 100;

        // Create marketplace order
        const orderData = {
            userId: decoded.uid,
            material,
            category: rateData.category,
            weightKg,
            ratePerKg: rateData.ratePerKg,
            amount,
            status: "COMPLETED",
            createdAt: FieldValue.serverTimestamp(),
        };

        const docRef = await admin
            .firestore()
            .collection("marketplaceOrders")
            .add(orderData);

        // Credit earnings to wallet
        const walletRef = admin.firestore().collection("wallet").doc(decoded.uid);
        await walletRef.set(
            {
                userId: decoded.uid,
                balance: FieldValue.increment(amount),
                updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true }
        );

        res.status(201).json({
            success: true,
            orderId: docRef.id,
            amount,
        });
    } catch (error) {
        console.error("Sell waste error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to sell waste",
        });
    }
});

module.exports = router;
