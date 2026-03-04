import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

/// OTP Service — Fake OTP for development + Firebase Anonymous Auth
///
/// Generates OTP locally and verifies it in-app.
/// After verification, signs in anonymously to Firebase for a real UID.
class OtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory store: phone -> { otp, expiresAt }
  static final Map<String, _OtpEntry> _otpStore = {};

  /// Send (generate) a fake OTP for the given phone number.
  ///
  /// Returns `{ success: true, otp: "123456" }` so the UI can display it.
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    // Simulate a tiny network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final otp = _generateOtp();
    _otpStore[phone] = _OtpEntry(
      otp: otp,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    return {
      'success': true,
      'otp': otp,
      'message': 'OTP sent successfully (dev mode)',
    };
  }

  /// Verify the OTP for the given phone number.
  ///
  /// On success, signs in anonymously to Firebase to get a real UID.
  /// Returns `{ success: true }` or `{ success: false, message: "..." }`.
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final stored = _otpStore[phone];

    if (stored == null) {
      return {
        'success': false,
        'message': 'OTP not found. Please request a new one.',
      };
    }

    if (DateTime.now().isAfter(stored.expiresAt)) {
      _otpStore.remove(phone);
      return {
        'success': false,
        'message': 'OTP expired. Please request a new one.',
      };
    }

    if (stored.otp != otp) {
      return {
        'success': false,
        'message': 'Invalid OTP. Please try again.',
      };
    }

    // OTP verified — clean up
    _otpStore.remove(phone);

    // Sign in anonymously to Firebase for a real UID
    try {
      await _auth.signInAnonymously();
      return {
        'success': true,
        'message': 'Phone verified successfully!',
      };
    } catch (e) {
      return {
        'success': true,
        'message': 'Phone verified (offline mode)',
      };
    }
  }

  /// Generate a random 6-digit OTP
  static String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}

/// Internal class to hold OTP data
class _OtpEntry {
  final String otp;
  final DateTime expiresAt;

  _OtpEntry({required this.otp, required this.expiresAt});
}
