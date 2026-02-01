import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Authentication Service - Handles local auth for testing
/// Will be replaced with backend auth (Firebase/API) later
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Login - Mock auth for testing the app flow
  /// Replace with actual backend authentication later
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Basic validation for testing
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Email and password required'};
    }

    if (password.length < 6) {
      return {'success': false, 'message': 'Invalid credentials'};
    }

    // Create a basic collector profile for testing
    final collector = Collector(
      id: 'collector_${DateTime.now().millisecondsSinceEpoch}',
      name: email
          .split('@')
          .first
          .replaceAll('.', ' ')
          .split(' ')
          .map((w) =>
              w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' '),
      email: email,
      phone: '',
      isOnline: false,
      rating: 0.0,
      totalPickups: 0,
      totalHoursToday: 0,
    );

    // Save to local storage
    await _saveToken('token_${collector.id}');
    await _saveUser(collector);

    return {
      'success': true,
      'token': 'token_${collector.id}',
      'collector': collector,
    };
  }

  /// Signup - Mock registration for testing
  /// Replace with actual backend registration later
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Basic validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'All fields are required'};
    }

    // Create collector profile
    final collector = Collector(
      id: 'collector_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      isOnline: false,
      rating: 0.0,
      totalPickups: 0,
      totalHoursToday: 0,
    );

    // Save to local storage
    await _saveToken('token_${collector.id}');
    await _saveUser(collector);

    return {
      'success': true,
      'token': 'token_${collector.id}',
      'collector': collector,
    };
  }

  /// Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty) {
      return {'success': false, 'message': 'Email is required'};
    }

    // Backend will handle password reset email
    return {'success': true, 'message': 'Password reset link sent'};
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get stored user data
  static Future<Collector?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return Collector.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Private helpers
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> _saveUser(Collector collector) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(collector.toJson()));
  }
}
