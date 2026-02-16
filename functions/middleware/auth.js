const admin = require("firebase-admin");

/**
 * Validates the Firebase Auth token from the request header.
 * Returns the decoded token with user info.
 */
async function verifyAuth(req) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new Error("Unauthorized: No token provided");
  }

  const token = authHeader.split("Bearer ")[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return decodedToken;
  } catch (error) {
    throw new Error("Unauthorized: Invalid token");
  }
}

/**
 * Gets the user's role from Firestore.
 * Returns "user", "collector", or "admin".
 */
async function getUserRole(uid) {
  const db = admin.firestore();

  // Check admin collection first
  const adminDoc = await db.collection("admins").doc(uid).get();
  if (adminDoc.exists) return "admin";

  // Check collectors
  const collectorDoc = await db.collection("collectors").doc(uid).get();
  if (collectorDoc.exists) return "collector";

  // Default to user
  return "user";
}

/**
 * Middleware-style helper that verifies auth AND checks role.
 * Usage: const { uid, role } = await verifyAuthAndRole(req, ["admin"]);
 */
async function verifyAuthAndRole(req, allowedRoles = []) {
  const decodedToken = await verifyAuth(req);
  const role = await getUserRole(decodedToken.uid);

  if (allowedRoles.length > 0 && !allowedRoles.includes(role)) {
    throw new Error(`Forbidden: Role '${role}' is not authorized for this action`);
  }

  return { uid: decodedToken.uid, email: decodedToken.email, role };
}

/**
 * CORS headers helper for HTTP functions.
 * Handles preflight OPTIONS requests.
 */
function handleCors(req, res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}

/**
 * Standard error response helper.
 */
function sendError(res, error, statusCode = 500) {
  const message = error.message || "Internal server error";

  if (message.startsWith("Unauthorized")) {
    return res.status(401).json({ success: false, error: message });
  }
  if (message.startsWith("Forbidden")) {
    return res.status(403).json({ success: false, error: message });
  }
  if (message.startsWith("Not found")) {
    return res.status(404).json({ success: false, error: message });
  }
  if (message.startsWith("Bad request")) {
    return res.status(400).json({ success: false, error: message });
  }

  return res.status(statusCode).json({ success: false, error: message });
}

/**
 * Standard success response helper.
 */
function sendSuccess(res, data = {}, statusCode = 200) {
  return res.status(statusCode).json({ success: true, ...data });
}

module.exports = {
  verifyAuth,
  getUserRole,
  verifyAuthAndRole,
  handleCors,
  sendError,
  sendSuccess,
};
