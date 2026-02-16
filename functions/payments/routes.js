/**
 * Payment Routes — /api/payments & /api/wallet
 *
 * POST /calculate     — Price estimation
 * POST /create        — Initiate payment
 * POST /verify        — Confirm payment
 * GET  /wallet/balance — EcoWallet balance (mounted at /api/wallet/balance in index.js via prefix)
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

// Price calculation helper (same logic as pickups)
function calculatePrice(wasteTypes = [], weightKg = 0) {
    const basePrice = 49;
    const weightCharge = weightKg * 5;

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
 * POST /api/payments/calculate
 * Body: { wasteTypes[], weightKg }
 * Response: { basePrice, weightCharge, typeCharge, total }
 */
router.post("/calculate", async (req, res) => {
    try {
        const { wasteTypes, weightKg } = req.body;

        if (!wasteTypes || !weightKg) {
            return res.status(400).json({
                success: false,
                error: "wasteTypes and weightKg are required",
            });
        }

        const priceBreakdown = calculatePrice(wasteTypes, weightKg);

        res.json({
            success: true,
            ...priceBreakdown,
        });
    } catch (error) {
        console.error("Calculate price error:", error);
        res.status(500).json({
            success: false,
            error: error.message || "Failed to calculate price",
        });
    }
});

/**
 * POST /api/payments/create
 * Body: { pickupId, amount, method (UPI/CARD/NET_BANKING/ECO_WALLET/CASH), promoCode }
 * Response: { paymentId, transactionId, status }
 */
router.post("/create", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const { pickupId, amount, method, promoCode } = req.body;

        if (!pickupId || !amount || !method) {
            return res.status(400).json({
                success: false,
                error: "pickupId, amount, and method are required",
            });
        }

        const validMethods = ["UPI", "CARD", "NET_BANKING", "ECO_WALLET", "CASH"];
        if (!validMethods.includes(method)) {
            return res.status(400).json({
                success: false,
                error: `Invalid payment method. Must be one of: ${validMethods.join(", ")}`,
            });
        }

        // Verify pickup exists
        const pickupDoc = await admin
            .firestore()
            .collection("pickupRequests")
            .doc(pickupId)
            .get();

        if (!pickupDoc.exists) {
            return res.status(404).json({
                success: false,
                error: "Pickup not found",
            });
        }

        // Handle ECO_WALLET payment
        if (method === "ECO_WALLET") {
            const walletDoc = await admin
                .firestore()
                .collection("wallet")
                .doc(decoded.uid)
                .get();
            const walletBalance = walletDoc.exists ? walletDoc.data().balance : 0;

            if (walletBalance < amount) {
                return res.status(400).json({
                    success: false,
                    error: "Insufficient wallet balance",
                });
            }
        }

        const transactionId = `TXN_${crypto.randomUUID().slice(0, 12).toUpperCase()}`;

        const paymentData = {
            pickupId,
            userId: decoded.uid,
            amount,
            method,
            transactionId,
            status: "PENDING",
            promoCode: promoCode || null,
            ecoPoints: 0,
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        };

        const docRef = await admin
            .firestore()
            .collection("payments")
            .add(paymentData);

        res.status(201).json({
            success: true,
            paymentId: docRef.id,
            transactionId,
            status: "PENDING",
        });
    } catch (error) {
        console.error("Create payment error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to create payment",
        });
    }
});

/**
 * POST /api/payments/verify
 * Body: { paymentId, gatewayResponse }
 * Response: { success, ecoPoints }
 */
router.post("/verify", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const { paymentId, gatewayResponse } = req.body;

        if (!paymentId) {
            return res.status(400).json({
                success: false,
                error: "paymentId is required",
            });
        }

        const paymentRef = admin.firestore().collection("payments").doc(paymentId);
        const paymentDoc = await paymentRef.get();

        if (!paymentDoc.exists) {
            return res.status(404).json({
                success: false,
                error: "Payment not found",
            });
        }

        const paymentData = paymentDoc.data();

        // Simulate payment verification (in production, verify with Razorpay/Stripe)
        // Calculate eco points: 1 point per ₹10 spent
        const ecoPoints = Math.floor(paymentData.amount / 10);

        // Update payment status
        await paymentRef.update({
            status: "COMPLETED",
            ecoPoints,
            gatewayResponse: gatewayResponse || null,
            verifiedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        });

        // Update pickup status to CONFIRMED
        if (paymentData.pickupId) {
            const pickupRef = admin
                .firestore()
                .collection("pickupRequests")
                .doc(paymentData.pickupId);

            const confirmTimeline = {
                status: "CONFIRMED",
                timestamp: new Date().toISOString(),
                message: "Payment verified, pickup confirmed",
            };

            await pickupRef.update({
                status: "CONFIRMED",
                timeline: FieldValue.arrayUnion(confirmTimeline),
                updatedAt: FieldValue.serverTimestamp(),
            });
        }

        // Credit eco points to wallet
        if (ecoPoints > 0) {
            const walletRef = admin
                .firestore()
                .collection("wallet")
                .doc(decoded.uid);
            await walletRef.set(
                {
                    userId: decoded.uid,
                    balance: FieldValue.increment(ecoPoints),
                    updatedAt: FieldValue.serverTimestamp(),
                },
                { merge: true }
            );
        }

        // If payment was via ECO_WALLET, deduct from wallet
        if (paymentData.method === "ECO_WALLET") {
            const walletRef = admin
                .firestore()
                .collection("wallet")
                .doc(decoded.uid);
            await walletRef.update({
                balance: FieldValue.increment(-paymentData.amount),
                updatedAt: FieldValue.serverTimestamp(),
            });
        }

        res.json({
            success: true,
            ecoPoints,
            message: "Payment verified successfully",
        });
    } catch (error) {
        console.error("Verify payment error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to verify payment",
        });
    }
});

module.exports = router;
