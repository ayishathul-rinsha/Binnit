/**
 * Auth Routes — /api/auth
 *
 * POST /register   — Create user with email/password
 * POST /login      — Sign in with email/password (custom token)
 * POST /google     — Sign in with Google ID token
 * POST /send-otp   — Generate & store a 6-digit OTP (returned in response for dev)
 * POST /verify-otp — Verify the OTP code and authenticate user
 */

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const crypto = require("crypto");

// ─── OTP Config ────────────────────────────────────────────────
const OTP_EXPIRY_MINUTES = 5;
const MAX_OTP_ATTEMPTS = 5; // max wrong attempts before OTP is invalidated
const MAX_OTP_REQUESTS_PER_HOUR = 5; // rate-limit per phone number

/**
 * Generate a cryptographically secure 6-digit OTP
 */
function generateOTP() {
    return crypto.randomInt(100000, 999999).toString();
}

// ─── Existing Routes (register, login, google) ────────────────

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

// ─── OTP Routes ────────────────────────────────────────────────

/**
 * POST /api/auth/send-otp
 * Body: { phone }
 * Response: { success, message, otp (DEV ONLY) }
 *
 * Generates a 6-digit OTP, stores it in Firestore "otps" collection
 * with a 5-minute expiry. The OTP is returned in the response for
 * development/testing. In production, integrate an SMS provider
 * (e.g. Twilio, AWS SNS) to send the OTP via SMS instead.
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

        // Validate phone format (basic check for E.164 or 10+ digits)
        const cleanPhone = phone.replace(/[\s\-()]/g, "");
        if (cleanPhone.length < 10) {
            return res.status(400).json({
                success: false,
                error: "Invalid phone number format",
            });
        }

        // Rate limiting — max OTP requests per phone per hour
        const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
        const recentOtps = await admin
            .firestore()
            .collection("otps")
            .where("phone", "==", cleanPhone)
            .where("createdAt", ">", oneHourAgo)
            .get();

        if (recentOtps.size >= MAX_OTP_REQUESTS_PER_HOUR) {
            return res.status(429).json({
                success: false,
                error: "Too many OTP requests. Please try again later.",
            });
        }

        // Invalidate any existing unused OTPs for this phone
        const existingOtps = await admin
            .firestore()
            .collection("otps")
            .where("phone", "==", cleanPhone)
            .where("verified", "==", false)
            .get();

        const batch = admin.firestore().batch();
        existingOtps.forEach((doc) => {
            batch.update(doc.ref, { verified: true }); // mark old ones as used
        });
        await batch.commit();

        // Generate and store new OTP
        const otp = generateOTP();
        const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

        await admin.firestore().collection("otps").add({
            phone: cleanPhone,
            otp,
            expiresAt,
            createdAt: new Date(),
            verified: false,
            attempts: 0,
        });

        // ──────────────────────────────────────────────────────
        // TODO (Production): Replace the response below with an
        // SMS send call. Example with Twilio:
        //
        //   const twilio = require("twilio")(accountSid, authToken);
        //   await twilio.messages.create({
        //       body: `Your Binnit verification code is: ${otp}`,
        //       from: "+1XXXXXXXXXX",
        //       to: cleanPhone,
        //   });
        //
        // Then remove "otp" from the response body.
        // ──────────────────────────────────────────────────────

        console.log(`[DEV] OTP for ${cleanPhone}: ${otp}`);

        res.json({
            success: true,
            message: `OTP sent successfully. Valid for ${OTP_EXPIRY_MINUTES} minutes.`,
            otp, // ⚠️ DEV ONLY — remove this in production
        });
    } catch (error) {
        console.error("Send OTP error:", error);
        res.status(500).json({
            success: false,
            error: error.message || "Failed to send OTP",
        });
    }
});

/**
 * POST /api/auth/verify-otp
 * Body: { phone, otp }
 * Response: { success, userId, token }
 *
 * Verifies the OTP against Firestore, then either finds or creates
 * the user by phone number and returns a Firebase custom token.
 */
router.post("/verify-otp", async (req, res) => {
    try {
        const { phone, otp } = req.body;

        if (!phone || !otp) {
            return res.status(400).json({
                success: false,
                error: "phone and otp are required",
            });
        }

        const cleanPhone = phone.replace(/[\s\-()]/g, "");

        // Find the latest unverified OTP for this phone
        const otpSnapshot = await admin
            .firestore()
            .collection("otps")
            .where("phone", "==", cleanPhone)
            .where("verified", "==", false)
            .orderBy("createdAt", "desc")
            .limit(1)
            .get();

        if (otpSnapshot.empty) {
            return res.status(400).json({
                success: false,
                error: "No OTP found. Please request a new one.",
            });
        }

        const otpDoc = otpSnapshot.docs[0];
        const otpData = otpDoc.data();

        // Check if OTP has expired
        const now = new Date();
        const expiresAt = otpData.expiresAt.toDate
            ? otpData.expiresAt.toDate()
            : new Date(otpData.expiresAt);

        if (now > expiresAt) {
            await otpDoc.ref.update({ verified: true });
            return res.status(400).json({
                success: false,
                error: "OTP has expired. Please request a new one.",
            });
        }

        // Check max attempts
        if (otpData.attempts >= MAX_OTP_ATTEMPTS) {
            await otpDoc.ref.update({ verified: true });
            return res.status(400).json({
                success: false,
                error: "Too many failed attempts. Please request a new OTP.",
            });
        }

        // Verify OTP
        if (otpData.otp !== otp) {
            await otpDoc.ref.update({ attempts: (otpData.attempts || 0) + 1 });
            return res.status(400).json({
                success: false,
                error: "Invalid OTP. Please try again.",
                attemptsRemaining: MAX_OTP_ATTEMPTS - (otpData.attempts + 1),
            });
        }

        // OTP is valid — mark as verified
        await otpDoc.ref.update({ verified: true, verifiedAt: new Date() });

        // Find or create user by phone number
        let userRecord;
        try {
            // Try to find existing user with this phone number
            userRecord = await admin.auth().getUserByPhoneNumber(
                cleanPhone.startsWith("+") ? cleanPhone : `+${cleanPhone}`
            );
        } catch (err) {
            if (err.code === "auth/user-not-found") {
                // Create a new Firebase Auth user with this phone number
                userRecord = await admin.auth().createUser({
                    phoneNumber: cleanPhone.startsWith("+") ? cleanPhone : `+${cleanPhone}`,
                });

                // Create Firestore user profile
                await admin.firestore().collection("users").doc(userRecord.uid).set({
                    name: "",
                    email: "",
                    phone: cleanPhone,
                    role: "user",
                    createdAt: FieldValue.serverTimestamp(),
                    updatedAt: FieldValue.serverTimestamp(),
                });

                // Initialize wallet
                await admin.firestore().collection("wallet").doc(userRecord.uid).set({
                    userId: userRecord.uid,
                    balance: 0,
                    updatedAt: FieldValue.serverTimestamp(),
                });
            } else {
                throw err;
            }
        }

        // Create custom token for client sign-in
        const token = await admin.auth().createCustomToken(userRecord.uid);

        res.json({
            success: true,
            userId: userRecord.uid,
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

