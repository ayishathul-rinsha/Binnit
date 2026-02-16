/**
 * Waste Management Backend — Main Entry Point
 *
 * Single Express app exported as Firebase HTTP function `api`.
 * All REST routes are mounted under /api/...
 * Firestore triggers are exported separately.
 */

const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

// Initialize Firebase Admin (once)
admin.initializeApp();

// Global options for all functions
setGlobalOptions({ maxInstances: 10 });

// --- Express App Setup ---
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Mount route modules
const authRoutes = require("./auth/routes");
const pickupRoutes = require("./pickups/routes");
const paymentRoutes = require("./payments/routes");
const marketplaceRoutes = require("./marketplace/routes");
const subscriptionRoutes = require("./subscriptions/routes");
const userRoutes = require("./users/routes");
const adminRoutes = require("./admin/routes");
const walletRoutes = require("./wallet/routes");
const collectorRoutes = require("./collectors/routes");
const earningsRoutes = require("./earnings/routes");

app.use("/api/auth", authRoutes);
app.use("/api/pickups", pickupRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/wallet", walletRoutes);
app.use("/api/marketplace", marketplaceRoutes);
app.use("/api/subscriptions", subscriptionRoutes);
app.use("/api/users", userRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/collectors", collectorRoutes);
app.use("/api/earnings", earningsRoutes);

// Health check
app.get("/api/health", (req, res) => {
  res.json({ success: true, message: "Waste Management API is running", timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, error: `Route ${req.method} ${req.path} not found` });
});

// Export Express app as single Firebase HTTP function
exports.api = onRequest(app);

// --- Firestore Triggers (from existing modules) ---
const userTriggers = require("./users/index");
const collectorTriggers = require("./collectors/index");

exports.onUserCreated = userTriggers.onUserCreated;
exports.onCollectorCreated = collectorTriggers.onCollectorCreated;
