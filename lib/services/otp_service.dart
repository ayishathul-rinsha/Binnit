import 'dart:convert';
import 'package:http/http.dart' as http;

/// OTP Service — calls the custom backend OTP endpoints
class OtpService {
  static const String _baseUrl =
      'https://us-central1-emptikko.cloudfunctions.net/api';

  /// Send OTP to the given phone number.
  ///
  /// Returns `{ success: true, otp: "1234" }` in dev mode,
  /// or `{ success: false, message: "..." }` on error.
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Verify the OTP for the given phone number.
  ///
  /// On success returns `{ success: true, token: "<firebase-custom-token>" }`.
  /// On failure returns `{ success: false, message: "..." }`.
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
