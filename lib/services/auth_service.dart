import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Authentication Service — Firebase Email/Password Auth
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userKey = 'user_data';

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  static Future<Map<String, dynamic>> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return {'success': false, 'message': 'Authentication failed'};
      }

      // Fetch / create collector profile from Firestore
      final collector = await getOrCreateCollectorProfile(result.user!);

      // Cache locally
      await _saveUser(collector);

      return {
        'success': true,
        'collector': collector,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Logout
  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Check if user is logged in (Firebase session)
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  /// Get stored user data (from local cache, falls back to Firestore)
  static Future<Collector?> getStoredUser() async {
    // First check if Firebase user exists
    final user = _auth.currentUser;
    if (user == null) return null;

    // Try local cache first
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return Collector.fromJson(jsonDecode(userData));
    }

    // Fall back to Firestore
    return await getOrCreateCollectorProfile(user);
  }

  /// Get or create collector profile from Firestore
  static Future<Collector> getOrCreateCollectorProfile(User user) async {
    final doc = await _firestore.collection('collectors').doc(user.uid).get();

    if (doc.exists) {
      return Collector.fromJson({...doc.data()!, 'id': user.uid});
    }

    // Create new profile if doesn't exist
    final collector = Collector(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      phone: '',
      isOnline: false,
      rating: 0.0,
      totalPickups: 0,
      totalHoursToday: 0,
    );

    await _firestore.collection('collectors').doc(user.uid).set(collector.toJson(), SetOptions(merge: true));
    return collector;
  }

  /// Update collector profile in Firestore
  static Future<void> updateCollectorProfile(Collector collector) async {
    await _firestore
        .collection('collectors')
        .doc(collector.id)
        .update(collector.toJson());
    await _saveUser(collector);
  }

  // Private helper — cache user locally
  static Future<void> _saveUser(Collector collector) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(collector.toJson()));
  }

  /// Get human-readable error message from Firebase error codes
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication error: $code';
    }
  }
}
