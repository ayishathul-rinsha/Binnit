const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// ──────────────────────────────────────────────
// Initialize Firebase Admin SDK
// ──────────────────────────────────────────────
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

if (fs.existsSync(serviceAccountPath)) {
    // Use service account key file if available
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
    console.log('✅ Firebase Admin initialized with service account key');
} else {
    // Fall back to project ID only (works for some operations)
    admin.initializeApp({
        projectId: 'emptikko',
    });
    console.log('⚠️  No serviceAccountKey.json found!');
    console.log('   Custom token generation will FAIL without it.');
    console.log('   Download it from: Firebase Console → Project Settings → Service Accounts → Generate New Private Key');
    console.log('   Save it as: server/serviceAccountKey.json\n');
}

const app = express();
app.use(cors());
app.use(express.json());

// ──────────────────────────────────────────────
// In-memory OTP store (dev mode only!)
// ──────────────────────────────────────────────
const otpStore = new Map(); // phone -> { otp, expiresAt }

function generateOtp() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// ──────────────────────────────────────────────
// POST /api/auth/send-otp
// Body: { "phone": "9876543210" }
// ──────────────────────────────────────────────
app.post('/api/auth/send-otp', (req, res) => {
    const { phone } = req.body;

    if (!phone || phone.length < 10) {
        return res.status(400).json({
            success: false,
            message: 'Valid phone number is required',
        });
    }

    const otp = generateOtp();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

    otpStore.set(phone, { otp, expiresAt });

    console.log(`📱 OTP for +91${phone}: ${otp}`);

    // In dev mode, return the OTP in the response
    res.json({
        success: true,
        otp: otp,
        message: 'OTP sent successfully',
    });
});

// ──────────────────────────────────────────────
// POST /api/auth/verify-otp
// Body: { "phone": "9876543210", "otp": "123456" }
// ──────────────────────────────────────────────
app.post('/api/auth/verify-otp', async (req, res) => {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
        return res.status(400).json({
            success: false,
            message: 'Phone and OTP are required',
        });
    }

    const stored = otpStore.get(phone);

    if (!stored) {
        return res.status(400).json({
            success: false,
            message: 'OTP not found. Please request a new one.',
        });
    }

    if (Date.now() > stored.expiresAt) {
        otpStore.delete(phone);
        return res.status(400).json({
            success: false,
            message: 'OTP expired. Please request a new one.',
        });
    }

    if (stored.otp !== otp) {
        return res.status(400).json({
            success: false,
            message: 'Invalid OTP. Please try again.',
        });
    }

    // OTP verified — clean up
    otpStore.delete(phone);

    try {
        // Create a Firebase custom token
        const uid = `phone_${phone}`;
        const customToken = await admin.auth().createCustomToken(uid, {
            phone: phone,
        });

        console.log(`✅ Verified +91${phone} → token generated`);

        res.json({
            success: true,
            token: customToken,
            message: 'OTP verified successfully',
        });
    } catch (error) {
        console.error('❌ Error creating custom token:', error.message);

        // If service account is missing, give a helpful message
        if (error.message.includes('credential') || error.code === 'app/invalid-credential') {
            return res.status(500).json({
                success: false,
                message: 'Server missing serviceAccountKey.json. See server console for instructions.',
            });
        }

        res.status(500).json({
            success: false,
            message: 'Failed to generate authentication token',
        });
    }
});

// ──────────────────────────────────────────────
// Health check
// ──────────────────────────────────────────────
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ──────────────────────────────────────────────
// Start server on all interfaces (0.0.0.0)
// so physical devices on the same network can
// reach it.
// ──────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 OTP Server running on http://0.0.0.0:${PORT}`);
    console.log(`   Local:   http://localhost:${PORT}/api/health`);
    console.log(`   Network: http://192.168.10.155:${PORT}/api/health\n`);
});
