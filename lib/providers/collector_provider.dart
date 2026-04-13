import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

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

  /// Set collector data (called after login) — auto-starts location tracking
  void setCollector(Collector collector) {
    _collector = collector;
    notifyListeners();

    // Auto-start location tracking so the admin can find this collector
    _autoStartTracking(collector);
  }

  /// Automatically start location tracking on login
  Future<void> _autoStartTracking(Collector collector) async {
    try {
      final locationService = LocationService();
      await locationService.startTracking(collector.id);

      // Also mark as online in Firestore
      _collector = _collector?.copyWith(isOnline: true);
      await FirestoreService.updateOnlineStatus(collector.id, true);
      notifyListeners();
    } catch (e) {
      debugPrint('Auto-tracking failed: $e');
    }
  }

  /// Toggle online/offline status - saves to Firestore
  Future<void> toggleOnlineStatus() async {
    if (_collector == null) return;

    final newStatus = !_collector!.isOnline;

    // Optimistic update — UI changes instantly
    _collector = _collector!.copyWith(isOnline: newStatus);
    notifyListeners();
    
    LocationService locationService = LocationService();
    if (newStatus) {
      await locationService.startTracking(_collector!.id);
    } else {
      locationService.stopTracking(_collector!.id);
    }

    try {
      await FirestoreService.updateOnlineStatus(_collector!.id, newStatus);
    } catch (e) {
      // Revert on failure
      _collector = _collector!.copyWith(isOnline: !newStatus);
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update collector profile - saves to Firestore
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? address,
    String? city,
    String? experience,
  }) async {
    if (_collector == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collector = _collector!.copyWith(
        name: name ?? _collector!.name,
        phone: phone ?? _collector!.phone,
        photoUrl: photoUrl ?? _collector!.photoUrl,
        address: address ?? _collector!.address,
        city: city ?? _collector!.city,
        experience: experience ?? _collector!.experience,
      );

      // Save to Firestore
      await AuthService.updateCollectorProfile(_collector!);

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

  /// Update vehicle details - saves to Firestore
  Future<bool> updateVehicleDetails(VehicleDetails vehicle) async {
    if (_collector == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collector = _collector!.copyWith(vehicle: vehicle);

      // Save to Firestore
      await FirestoreService.updateCollectorFields(
        _collector!.id,
        {'vehicle': vehicle.toJson()},
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

  /// Update bank details - saves to Firestore
  Future<bool> updateBankDetails(BankDetails bankDetails) async {
    if (_collector == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collector = _collector!.copyWith(bankDetails: bankDetails);

      // Save to Firestore
      await FirestoreService.updateCollectorFields(
        _collector!.id,
        {'bankDetails': bankDetails.toJson()},
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

  /// Reload collector from Firestore
  Future<void> refreshFromFirestore() async {
    if (_collector == null) return;

    try {
      final updatedCollector =
          await FirestoreService.getCollector(_collector!.id);
      if (updatedCollector != null) {
        _collector = updatedCollector;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
