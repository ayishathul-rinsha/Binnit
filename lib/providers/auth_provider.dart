import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

/// Authentication Provider for state management
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

  /// Initialize auth state from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
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

  /// Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);

      if (result['success'] == true && result['collector'] != null) {
        _collector = result['collector'] as Collector;
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Login failed';
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

  /// Signup
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (result['success'] == true && result['collector'] != null) {
        _collector = result['collector'] as Collector;
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Signup failed';
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

  /// Forgot password
  Future<bool> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.forgotPassword(email);
      _isLoading = false;

      if (result['success'] != true) {
        _error = result['message'];
      }
      notifyListeners();
      return result['success'] == true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
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

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
