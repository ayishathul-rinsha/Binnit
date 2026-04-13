import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Google Sign-In ─────────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Create/update user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          fullName: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Email/Password Sign Up ─────────────────────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(fullName);

      // Send email verification
      await credential.user?.sendEmailVerification();

      // Create user document in Firestore
      await _createUserDocument(
        uid: credential.user!.uid,
        fullName: fullName,
        email: email,
      );

      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ─── Email/Password Login ──────────────────────────────────────────────────
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Auto-provision User Document if it doesn't exist (e.g., cross-app login from Collector/Admin apps)
      if (credential.user != null) {
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (!doc.exists) {
          await _createUserDocument(
            uid: credential.user!.uid,
            fullName: credential.user!.displayName ?? email.split('@')[0],
            email: email,
          );
        }
      }
      
      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ─── Email Verification ─────────────────────────────────────────────────────
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ─── Password Reset ────────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── User Document ─────────────────────────────────────────────────────────
  Future<void> _createUserDocument({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'ecoPoints': 0,
      'totalWasteRecycled': 0.0,
      'co2Saved': 0.0,
      'subscriptionPlan': 'Free',
      'profileImageUrl': '',
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data();
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    await _firestore.collection('users').doc(currentUser!.uid).update(data);
  }

  // Get friendly error messages
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-credential':
          return 'Invalid credentials. Please check and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }
}
