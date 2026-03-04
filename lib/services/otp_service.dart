import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// OTP Service — Firebase Phone Authentication
///
/// Uses Firebase's built-in phone auth to send real SMS OTPs
/// and verify them. Returns a signed-in Firebase User on success.
class OtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store verification ID for later use
  static String? _verificationId;
  static int? _resendToken;

  /// Send OTP to the given phone number via Firebase.
  ///
  /// [phone] should be the 10-digit number (without country code).
  /// Returns `{ success: true }` when code is sent,
  /// or `{ success: false, message: "..." }` on error.
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final completer = Completer<Map<String, dynamic>>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,

        // Called when Firebase auto-verifies (instant verification)
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign-in (happens on some Android devices)
          try {
            await _auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete({
                'success': true,
                'autoVerified': true,
                'message': 'Phone auto-verified!',
              });
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete({
                'success': false,
                'message': 'Auto-verification failed: ${e.toString()}',
              });
            }
          }
        },

        // Called when Firebase fails to verify
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': _getPhoneAuthError(e.code),
            });
          }
        },

        // Called when code is sent to the phone
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'autoVerified': false,
              'message': 'OTP sent successfully!',
            });
          }
        },

        // Called when the auto-retrieval timeout expires
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete({
          'success': false,
          'message': 'Error: ${e.toString()}',
        });
      }
    }

    return completer.future;
  }

  /// Verify the OTP entered by the user.
  ///
  /// Returns `{ success: true }` if verified (user is now signed in),
  /// or `{ success: false, message: "..." }` on failure.
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    try {
      if (_verificationId == null) {
        return {
          'success': false,
          'message': 'No verification in progress. Please request a new OTP.',
        };
      }

      // Create credential from the verification ID and user-entered OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Clean up
        _verificationId = null;
        _resendToken = null;

        return {
          'success': true,
          'message': 'Phone verified successfully!',
        };
      } else {
        return {
          'success': false,
          'message': 'Verification failed. Please try again.',
        };
      }
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getPhoneAuthError(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Check if user is already signed in from auto-verification
  static bool get isAutoVerified => _auth.currentUser != null;

  /// Get human-readable error messages
  static String _getPhoneAuthError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again tomorrow.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'app-not-authorized':
        return 'App not authorized. Please check Firebase config.';
      case 'missing-client-identifier':
        return 'Device verification failed. Please try again.';
      default:
        return 'Verification error: $code';
    }
  }
}
