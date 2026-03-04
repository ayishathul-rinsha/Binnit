import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// OTP Service — Real Firebase Phone Authentication
///
/// Sends real SMS OTP via Firebase and signs user in on verification.
class OtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store verification ID for later use
  static String? _verificationId;
  static int? _resendToken;

  /// Send OTP to the given phone number via Firebase.
  ///
  /// [phone] should be the 10-digit number (without country code).
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final completer = Completer<Map<String, dynamic>>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,

        // Auto-verification (some Android devices)
        verificationCompleted: (PhoneAuthCredential credential) async {
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

        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': _getPhoneAuthError(e.code),
            });
          }
        },

        // Code sent to phone
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'autoVerified': false,
              'message': 'OTP sent to your phone!',
            });
          }
        },

        // Timeout
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

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
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

  /// Human-readable Firebase error messages
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
      case 'invalid-app-credential':
        return 'App verification failed. Please try again.';
      case 'missing-client-identifier':
        return 'Device verification failed. Please try again.';
      default:
        return 'Verification error: $code';
    }
  }
}
