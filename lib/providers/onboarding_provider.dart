import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages onboarding state and first-time user detection
class OnboardingProvider extends ChangeNotifier {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _permissionsGrantedKey = 'permissions_granted';
  static const String _riderRegisteredKey = 'rider_registered';

  bool _isFirstTimeUser = true;
  bool _permissionsGranted = false;
  bool _riderRegistered = false;
  bool _isInitialized = false;

  bool get isFirstTimeUser => _isFirstTimeUser;
  bool get permissionsGranted => _permissionsGranted;
  bool get riderRegistered => _riderRegistered;
  bool get isInitialized => _isInitialized;

  /// Initialize from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _isFirstTimeUser = !(prefs.getBool(_onboardingCompleteKey) ?? false);
    _permissionsGranted = prefs.getBool(_permissionsGrantedKey) ?? false;
    _riderRegistered = prefs.getBool(_riderRegisteredKey) ?? false;
    _isInitialized = true;

    notifyListeners();
  }

  /// Mark permissions as granted
  Future<void> setPermissionsGranted() async {
    _permissionsGranted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsGrantedKey, true);
    notifyListeners();
  }

  /// Mark rider as registered
  Future<void> setRiderRegistered() async {
    _riderRegistered = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_riderRegisteredKey, true);
    notifyListeners();
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    _isFirstTimeUser = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    notifyListeners();
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
    await prefs.remove(_permissionsGrantedKey);
    await prefs.remove(_riderRegisteredKey);
    _isFirstTimeUser = true;
    _permissionsGranted = false;
    _riderRegistered = false;
    notifyListeners();
  }
}
