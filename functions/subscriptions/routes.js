/**
 * Subscription Routes — /api/subscriptions
 *
 * GET  /plans              — List available plans
 * POST /subscribe          — Subscribe or upgrade
 * GET  /current?userId=xxx — Current active plan
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue, Timestamp } = require("firebase-admin/firestore");

// Helper: verify auth from request
async function getAuthUser(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Unauthorized: No token provided");
    }
    const token = authHeader.split("Bearer ")[1];
    return admin.auth().verifyIdToken(token);
}

// Default plans (seeded if collection is empty)
const DEFAULT_PLANS = [
    {
        name: "Free",
        price: 0,
        features: [
            "2 pickups per month",
            "Basic waste tracking",
            "Standard support",
            "Marketplace access",
        ],
    },
    {
        name: "Pro",
        price: 99,
        features: [
            "Unlimited pickups",
            "Priority scheduling",
            "Real-time tracking",
            "Premium support",
            "Eco rewards 2x",
            "Marketplace access",
        ],
    },
    {
        name: "Business",
        price: 299,
        features: [
            "Unlimited pickups",
            "Priority scheduling",
            "Real-time tracking",
            "Dedicated account manager",
            "Eco rewards 3x",
            "Bulk waste collection",
            "Custom reports",
            "API access",
            "Marketplace access",
        ],
    },
];

// Seed plans if collection is empty
async function ensurePlansExist() {
    const snapshot = await admin.firestore().collection("subscriptionPlans").limit(1).get();

    if (snapshot.empty) {
        const batch = admin.firestore().batch();
        DEFAULT_PLANS.forEach((plan) => {
            const docRef = admin.firestore().collection("subscriptionPlans").doc();
            batch.set(docRef, {
                ...plan,
                createdAt: FieldValue.serverTimestamp(),
            });
        });
        await batch.commit();
    }
}

/**
 * GET /api/subscriptions/plans
 * Response: { plans: [...] }
 */
router.get("/plans", async (req, res) => {
    try {
        await ensurePlansExist();

        // Optionally check current user's plan
        let currentPlanId = null;
        try {
            const decoded = await getAuthUser(req);
            const subSnapshot = await admin
                .firestore()
                .collection("subscriptions")
                .where("userId", "==", decoded.uid)
                .where("status", "==", "active")
                .limit(1)
                .get();

            if (!subSnapshot.empty) {
                currentPlanId = subSnapshot.docs[0].data().planId;
            }
        } catch {
            // Auth is optional for listing plans
        }

        const snapshot = await admin
            .firestore()
            .collection("subscriptionPlans")
            .orderBy("price")
            .get();

        const plans = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            plans.push({
                planId: doc.id,
                name: data.name,
                price: data.price,
                features: data.features,
                isCurrent: doc.id === currentPlanId,
            });
        });

        res.json({ success: true, plans });
    } catch (error) {
        console.error("Get plans error:", error);
        res.status(500).json({
            success: false,
            error: error.message || "Failed to get plans",
        });
    }
});

/**
 * POST /api/subscriptions/subscribe
 * Body: { planId, paymentMethod }
 * Response: { success, validUntil }
 */
router.post("/subscribe", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const { planId, paymentMethod } = req.body;

        if (!planId) {
            return res.status(400).json({
                success: false,
                error: "planId is required",
            });
        }

        // Verify plan exists
        const planDoc = await admin
            .firestore()
            .collection("subscriptionPlans")
            .doc(planId)
            .get();

        if (!planDoc.exists) {
            return res.status(404).json({
                success: false,
                error: "Plan not found",
            });
        }

        // Deactivate existing active subscription
        const existingSubs = await admin
            .firestore()
            .collection("subscriptions")
            .where("userId", "==", decoded.uid)
            .where("status", "==", "active")
            .get();

        const batch = admin.firestore().batch();
        existingSubs.forEach((doc) => {
            batch.update(doc.ref, {
                status: "cancelled",
                cancelledAt: FieldValue.serverTimestamp(),
            });
        });

        // Create new subscription
        const startDate = new Date();
        const endDate = new Date();
        endDate.setMonth(endDate.getMonth() + 1); // 1 month subscription

        const subRef = admin.firestore().collection("subscriptions").doc();
        batch.set(subRef, {
            userId: decoded.uid,
            planId,
            planName: planDoc.data().name,
            price: planDoc.data().price,
            paymentMethod: paymentMethod || "CARD",
            startDate: Timestamp.fromDate(startDate),
            endDate: Timestamp.fromDate(endDate),
            status: "active",
            createdAt: FieldValue.serverTimestamp(),
        });

        await batch.commit();

        res.status(201).json({
            success: true,
            subscriptionId: subRef.id,
            validUntil: endDate.toISOString(),
        });
    } catch (error) {
        console.error("Subscribe error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to subscribe",
        });
    }
});

/**
 * GET /api/subscriptions/current?userId=xxx
 * Response: { subscription details }
 */
router.get("/current", async (req, res) => {
    try {
        const decoded = await getAuthUser(req);
        const userId = req.query.userId || decoded.uid;

        const snapshot = await admin
            .firestore()
            .collection("subscriptions")
            .where("userId", "==", userId)
            .where("status", "==", "active")
            .limit(1)
            .get();

        if (snapshot.empty) {
            return res.json({
                success: true,
                subscription: null,
                message: "No active subscription",
            });
        }

        const doc = snapshot.docs[0];
        const data = doc.data();

        // Get plan details
        const planDoc = await admin
            .firestore()
            .collection("subscriptionPlans")
            .doc(data.planId)
            .get();
        const planData = planDoc.exists ? planDoc.data() : {};

        res.json({
            success: true,
            subscription: {
                subscriptionId: doc.id,
                planId: data.planId,
                planName: data.planName,
                price: data.price,
                features: planData.features || [],
                startDate: data.startDate,
                endDate: data.endDate,
                status: data.status,
            },
        });
    } catch (error) {
        console.error("Get current subscription error:", error);
        const statusCode = error.message.startsWith("Unauthorized") ? 401 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Failed to get subscription",
        });
    }
});

module.exports = router;
