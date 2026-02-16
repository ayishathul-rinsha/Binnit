/**
 * Auth Routes — /api/auth
 *
 * POST /register   — Create user with email/password
 * POST /login      — Sign in with email/password (custom token)
 * POST /google     — Sign in with Google ID token
 * POST /send-otp   — Placeholder (OTP sent by Firebase client SDK)
 * POST /verify-otp — Verify phone auth token
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");

/**
 * POST /api/auth/register
 * Body: { name, email, phone, password }
 * Response: { userId, token }
 */
router.post("/register", async (req, res) => {
    try {
        const { name, email, phone, password } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                error: "name, email, and password are required",
            });
        }

        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName: name,
            phoneNumber: phone || undefined,
        });

        // Create Firestore user profile
        await admin.firestore().collection("users").doc(userRecord.uid).set({
            name,
            email,
            phone: phone || "",
            role: "user",
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        });

        // Create custom token for immediate sign-in
        const token = await admin.auth().createCustomToken(userRecord.uid);

        // Initialize wallet with zero balance
        await admin.firestore().collection("wallet").doc(userRecord.uid).set({
            userId: userRecord.uid,
            balance: 0,
            updatedAt: FieldValue.serverTimestamp(),
        });

        res.status(201).json({
            success: true,
            userId: userRecord.uid,
            token,
        });
    } catch (error) {
        console.error("Register error:", error);
        const statusCode = error.code === "auth/email-already-exists" ? 409 : 500;
        res.status(statusCode).json({
            success: false,
            error: error.message || "Registration failed",
        });
    }
});

/**
 * POST /api/auth/login
 * Body: { email, password }
 * Response: { userId, token, name }
 *
 * Note: Firebase Admin SDK cannot verify email/password directly.
 * The frontend should use Firebase Client SDK signInWithEmailAndPassword().
 * This endpoint provides a custom token given a verified ID token from client.
 * Alternative: accepts email to look up user and create custom token.
 */
router.post("/login", async (req, res) => {
    try {
        const { email, idToken } = req.body;

        if (!email && !idToken) {
            return res.status(400).json({
                success: false,
                error: "email or idToken is required",
            });
        }

        let userRecord;

        if (idToken) {
            // Verify the ID token from client-side sign-in
            const decoded = await admin.auth().verifyIdToken(idToken);
            userRecord = await admin.auth().getUser(decoded.uid);
        } else {
            // Look up user by email
            userRecord = await admin.auth().getUserByEmail(email);
        }

        // Get user profile from Firestore
        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(userRecord.uid)
            .get();
        const userData = userDoc.exists ? userDoc.data() : {};

        // Create custom token
        const token = await admin.auth().createCustomToken(userRecord.uid);

        res.json({
            success: true,
            userId: userRecord.uid,
            token,
            name: userData.name || userRecord.displayName || "",
        });
    } catch (error) {
        console.error("Login error:", error);
        res.status(401).json({
            success: false,
            error: error.message || "Login failed",
        });
    }
});

/**
 * POST /api/auth/google
 * Body: { googleIdToken }
 * Response: { userId, token, name }
 */
router.post("/google", async (req, res) => {
    try {
        const { googleIdToken } = req.body;

        if (!googleIdToken) {
            return res.status(400).json({
                success: false,
                error: "googleIdToken is required",
            });
        }

        // Verify the Google ID token
        const decoded = await admin.auth().verifyIdToken(googleIdToken);
        const uid = decoded.uid;

        // Check if user profile exists, create if not
        const userDoc = await admin.firestore().collection("users").doc(uid).get();

        if (!userDoc.exists) {
            const userRecord = await admin.auth().getUser(uid);
            await admin.firestore().collection("users").doc(uid).set({
                name: userRecord.displayName || decoded.name || "",
                email: userRecord.email || decoded.email || "",
                phone: userRecord.phoneNumber || "",
                role: "user",
                createdAt: FieldValue.serverTimestamp(),
                updatedAt: FieldValue.serverTimestamp(),
            });

            // Initialize wallet
            await admin.firestore().collection("wallet").doc(uid).set({
                userId: uid,
                balance: 0,
                updatedAt: FieldValue.serverTimestamp(),
            });
        }

        const userData = userDoc.exists ? userDoc.data() : {};
        const token = await admin.auth().createCustomToken(uid);

        res.json({
            success: true,
            userId: uid,
            token,
            name: userData.name || decoded.name || "",
        });
    } catch (error) {
        console.error("Google auth error:", error);
        res.status(401).json({
            success: false,
            error: error.message || "Google authentication failed",
        });
    }
});

/**
 * POST /api/auth/send-otp
 * Body: { phone }
 * Response: { success, message }
 *
 * Note: Actual OTP sending is handled by Firebase Client SDK (verifyPhoneNumber).
 * This endpoint is a placeholder for backend acknowledgement.
 */
router.post("/send-otp", async (req, res) => {
    try {
        const { phone } = req.body;

        if (!phone) {
            return res.status(400).json({
                success: false,
                error: "phone is required",
            });
        }

        // In production, you could integrate Twilio here for custom OTP.
        // For now, OTP is handled by Firebase Client SDK.
        res.json({
            success: true,
            message:
                "OTP should be sent via Firebase Client SDK (verifyPhoneNumber). This endpoint acknowledges the request.",
        });
    } catch (error) {
        console.error("Send OTP error:", error);
        res.status(500).json({
            success: false,
            error: error.message || "Failed to process OTP request",
        });
    }
});

/**
 * POST /api/auth/verify-otp
 * Body: { phone, idToken }
 * Response: { userId, token }
 *
 * The client verifies OTP via Firebase SDK then sends the resulting idToken here.
 */
router.post("/verify-otp", async (req, res) => {
    try {
        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).json({
                success: false,
                error: "idToken is required (obtained after client-side OTP verification)",
            });
        }

        // Verify the ID token from phone auth
        const decoded = await admin.auth().verifyIdToken(idToken);
        const uid = decoded.uid;

        // Create or update user profile
        const userDoc = await admin.firestore().collection("users").doc(uid).get();

        if (!userDoc.exists) {
            const userRecord = await admin.auth().getUser(uid);
            await admin.firestore().collection("users").doc(uid).set({
                name: userRecord.displayName || "",
                email: userRecord.email || "",
                phone: userRecord.phoneNumber || decoded.phone_number || "",
                role: "user",
                createdAt: FieldValue.serverTimestamp(),
                updatedAt: FieldValue.serverTimestamp(),
            });

            // Initialize wallet
            await admin.firestore().collection("wallet").doc(uid).set({
                userId: uid,
                balance: 0,
                updatedAt: FieldValue.serverTimestamp(),
            });
        }

        const token = await admin.auth().createCustomToken(uid);

        res.json({
            success: true,
            userId: uid,
            token,
        });
    } catch (error) {
        console.error("Verify OTP error:", error);
        res.status(401).json({
            success: false,
            error: error.message || "OTP verification failed",
        });
    }
});

module.exports = router;
