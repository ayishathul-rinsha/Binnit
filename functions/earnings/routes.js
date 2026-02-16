/**
 * Earnings Routes — /api/earnings
 *
 * GET /summary       — Get today/weekly/monthly earnings + pending/received
 * GET /transactions  — Get earnings transaction history
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");

// Helper: verify auth and require collector
async function requireCollector(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Unauthorized: No token provided");
    }
    const token = authHeader.split("Bearer ")[1];
    const decoded = await admin.auth().verifyIdToken(token);

    const collectorDoc = await admin.firestore().collection("collectors").doc(decoded.uid).get();
    if (!collectorDoc.exists) {
        throw new Error("Forbidden: Collector profile not found");
    }
    return decoded;
}

/**
 * GET /api/earnings/summary
 * Response: { todayEarnings, weeklyEarnings, monthlyEarnings, pendingPayment, receivedPayment }
 */
router.get("/summary", async (req, res) => {
    try {
        const decoded = await requireCollector(req);

        const earningsDoc = await admin
            .firestore()
            .collection("earnings")
            .doc(decoded.uid)
            .get();

        if (!earningsDoc.exists) {
            return res.json({
                success: true,
                todayEarnings: 0,
                weeklyEarnings: 0,
                monthlyEarnings: 0,
                pendingPayment: 0,
                receivedPayment: 0,
            });
        }

        const data = earningsDoc.data();

        res.json({
            success: true,
            todayEarnings: data.todayEarnings || 0,
            weeklyEarnings: data.weeklyEarnings || 0,
            monthlyEarnings: data.monthlyEarnings || 0,
            pendingPayment: data.pendingPayment || 0,
            receivedPayment: data.receivedPayment || 0,
        });
    } catch (error) {
        console.error("Get earnings summary error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401
            : error.message.startsWith("Forbidden") ? 403 : 500;
        res.status(statusCode).json({ success: false, error: error.message });
    }
});

/**
 * GET /api/earnings/transactions?limit=20
 * Response: { transactions: [{ id, pickupId, amount, date, isPaid, description }] }
 */
router.get("/transactions", async (req, res) => {
    try {
        const decoded = await requireCollector(req);
        const limit = parseInt(req.query.limit) || 20;

        const snapshot = await admin
            .firestore()
            .collection("earnings")
            .doc(decoded.uid)
            .collection("transactions")
            .orderBy("date", "desc")
            .limit(limit)
            .get();

        const transactions = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            transactions.push({
                id: doc.id,
                pickupId: data.pickupId || "",
                amount: data.amount || 0,
                date: data.date || null,
                isPaid: data.isPaid || false,
                description: data.description || "",
            });
        });

        res.json({ success: true, transactions, count: transactions.length });
    } catch (error) {
        console.error("Get transactions error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401
            : error.message.startsWith("Forbidden") ? 403 : 500;
        res.status(statusCode).json({ success: false, error: error.message });
    }
});

module.exports = router;
