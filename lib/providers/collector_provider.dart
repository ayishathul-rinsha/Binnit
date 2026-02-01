import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Collector Provider for managing collector profile state
class CollectorProvider extends ChangeNotifier {
  Collector? _collector;
  bool _isLoading = false;
  String? _error;

  // Getters
  Collector? get collector => _collector;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _collector?.isOnline ?? false;

  /// Set collector data (called after login)
  void setCollector(Collector collector) {
    _collector = collector;
    notifyListeners();
  }

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    if (_collector == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      _collector = _collector!.copyWith(isOnline: !_collector!.isOnline);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update collector profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    if (_collector == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _collector = _collector!.copyWith(
        name: name ?? _collector!.name,
        phone: phone ?? _collector!.phone,
        photoUrl: photoUrl ?? _collector!.photoUrl,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update vehicle details
  Future<bool> updateVehicleDetails(VehicleDetails vehicle) async {
    if (_collector == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _collector = _collector!.copyWith(vehicle: vehicle);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update bank details
  Future<bool> updateBankDetails(BankDetails bankDetails) async {
    if (_collector == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _collector = _collector!.copyWith(bankDetails: bankDetails);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear collector data (on logout)
  void clear() {
    _collector = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
