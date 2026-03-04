import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/otp_service.dart';

/// Authentication Provider for state management — Phone OTP Auth
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
      // Check Firebase Auth state
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

  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await OtpService.sendOtp(phone);

      _isLoading = false;
      if (result['success'] != true) {
        _error = result['message'] ?? 'Failed to send OTP';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Verify OTP and sign in with the Firebase custom token
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1 — verify OTP with backend, get Firebase custom token
      final otpResult = await OtpService.verifyOtp(phone, otp);

      if (otpResult['success'] != true) {
        _error = otpResult['message'] ?? 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String? token = otpResult['token'] as String?;
      if (token == null || token.isEmpty) {
        _error = 'No authentication token received';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 2 — sign in to Firebase with the custom token
      final authResult = await AuthService.loginWithCustomToken(token);

      if (authResult['success'] == true && authResult['collector'] != null) {
        _collector = authResult['collector'] as Collector;
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = authResult['message'] ?? 'Authentication failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout from Firebase
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
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

  /// Update local collector data (after profile edits)
  void updateCollector(Collector collector) {
    _collector = collector;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
