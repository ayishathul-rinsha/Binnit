/**
 * Wallet Routes — /api/wallet
 *
 * GET /balance?userId=xxx — EcoWallet balance
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");

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
 * GET /api/wallet/balance?userId=xxx
 * Response: { balance }
 */
router.get("/balance", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const userId = req.query.userId || decoded.uid;

        const walletDoc = await admin
            .firestore()
            .collection("wallet")
            .doc(userId)
            .get();

        const balance = walletDoc.exists ? walletDoc.data().balance : 0;

        res.json({
            success: true,
            userId,
            balance,
        });
    } catch (error) {
        console.error("Get wallet balance error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get wallet balance",
        });
    }
});

module.exports = router;
