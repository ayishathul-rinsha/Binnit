import 'dart:math';

/// Fake OTP Service — generates and verifies OTP locally (no backend needed)
///
/// For development/demo purposes. The OTP is generated in-app and
/// displayed to the user via a snackbar so they can enter it.
class OtpService {
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
  /// Returns `{ success: true }` if the OTP matches,
  /// or `{ success: false, message: "..." }` on failure.
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    // Simulate a tiny network delay
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

    return {
      'success': true,
      'message': 'OTP verified successfully',
    };
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
