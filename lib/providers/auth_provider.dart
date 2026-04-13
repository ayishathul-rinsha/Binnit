import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

/// Authentication Provider — Email + Password Auth
class AuthProvider extends ChangeNotifier {
  Collector? _collector;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  // Getters
  Collector? get collector => _collector;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  /// Initialize auth state from Firebase
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storedUser = await AuthService.getStoredUser();
        if (storedUser != null) {
          _collector = storedUser;
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email + password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create collector profile
      await AuthService.getOrCreateCollectorProfile(userCredential.user!);

      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      // Sign out since they need to verify
      await FirebaseAuth.instance.signOut();

      _isLoading = false;
      notifyListeners();
      return {
        'success': true,
        'message':
            'Account created! Please check your email to verify your account.',
      };
    } on FirebaseAuthException catch (e) {
      _error = _getAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Login with email + password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': _error};
      }

      // Fetch or create collector profile from Firestore
      final collector = await AuthService.getOrCreateCollectorProfile(user);
      
      // Update provider state
      _collector = collector;
      _isLoggedIn = true;

      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': 'Logged in successfully!'};
    } on FirebaseAuthException catch (e) {
      _error = _getAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Login with Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        _error = 'Sign-in cancelled';
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Sign-in cancelled'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        _error = 'Google authentication failed';
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': _error};
      }

      // Fetch or create collector profile from Firestore
      final collector = await AuthService.getOrCreateCollectorProfile(user);
      _collector = collector;
      _isLoggedIn = true;

      _isLoading = false;
      notifyListeners();
      return {
        'success': true,
        'message': 'Logged in with Google successfully!',
        'collector': collector,
      };
    } on FirebaseAuthException catch (e) {
      _error = _getAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Resend email verification
  Future<void> resendVerification() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (_) {}
  }

  /// Logout from Firebase
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_collector != null) {
        LocationService().stopTracking(_collector!.id);
      }
      await AuthService.logout();
      _collector = null;
      _isLoggedIn = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update local collector data
  void updateCollector(Collector collector) {
    _collector = collector;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Human-readable error messages
  String _getAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
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
