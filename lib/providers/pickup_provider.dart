import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/pickup_service.dart';

/// Filter options for pickup requests
class PickupFilter {
  final WasteCategory? category;
  final double? maxDistance;
  final bool? sortByNearest;

  PickupFilter({this.category, this.maxDistance, this.sortByNearest});

  PickupFilter copyWith({
    WasteCategory? category,
    double? maxDistance,
    bool? sortByNearest,
  }) {
    return PickupFilter(
      category: category ?? this.category,
      maxDistance: maxDistance ?? this.maxDistance,
      sortByNearest: sortByNearest ?? this.sortByNearest,
    );
  }
}

/// Pickup Provider for managing pickup requests state
class PickupProvider extends ChangeNotifier {
  List<PickupRequest> _incomingRequests = [];
  List<PickupRequest> _activePickups = [];
  List<PickupRequest> _history = [];
  bool _isLoading = false;
  String? _error;
  PickupFilter _filter = PickupFilter();

  // Getters
  List<PickupRequest> get incomingRequests => _applyFilter(_incomingRequests);
  List<PickupRequest> get activePickups => _activePickups;
  List<PickupRequest> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PickupFilter get filter => _filter;

  /// Apply filter to requests
  List<PickupRequest> _applyFilter(List<PickupRequest> requests) {
    var filtered = List<PickupRequest>.from(requests);

    if (_filter.category != null) {
      filtered = filtered.where((r) => r.category == _filter.category).toList();
    }

    if (_filter.maxDistance != null) {
      filtered =
          filtered.where((r) => r.distance <= _filter.maxDistance!).toList();
    }

    if (_filter.sortByNearest == true) {
      filtered.sort((a, b) => a.distance.compareTo(b.distance));
    }

    return filtered;
  }

  /// Safe notify that uses microtask to avoid build phase issues
  void _safeNotify() {
    Future.microtask(() => notifyListeners());
  }

  /// Fetch incoming pickup requests
  Future<void> fetchIncomingRequests() async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      _incomingRequests = await PickupService.getPickupRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Fetch active pickups
  Future<void> fetchActivePickups() async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      _activePickups = await PickupService.getActivePickups();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Fetch pickup history
  Future<void> fetchHistory({
    DateTime? startDate,
    DateTime? endDate,
    WasteCategory? category,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      _history = await PickupService.getPickupHistory(
        startDate: startDate,
        endDate: endDate,
        category: category,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Accept a pickup request
  Future<bool> acceptPickup(String pickupId) async {
    _error = null;

    try {
      final result = await PickupService.acceptPickup(pickupId);

      if (result['success'] == true) {
        // Move from incoming to active
        final pickupIndex =
            _incomingRequests.indexWhere((p) => p.id == pickupId);
        if (pickupIndex != -1) {
          final pickup = _incomingRequests[pickupIndex];
          _incomingRequests.removeAt(pickupIndex);
          _activePickups.add(pickup.copyWith(status: PickupStatus.accepted));
        }
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reject a pickup request
  Future<bool> rejectPickup(String pickupId) async {
    _error = null;

    try {
      final result = await PickupService.rejectPickup(pickupId);

      if (result['success'] == true) {
        _incomingRequests.removeWhere((p) => p.id == pickupId);
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update pickup status
  Future<bool> updatePickupStatus(String pickupId, PickupStatus status) async {
    _error = null;

    try {
      final result = await PickupService.updatePickupStatus(pickupId, status);

      if (result['success'] == true) {
        final index = _activePickups.indexWhere((p) => p.id == pickupId);
        if (index != -1) {
          if (status == PickupStatus.completed) {
            // Move to history
            final pickup = _activePickups[index].copyWith(status: status);
            _activePickups.removeAt(index);
            _history.insert(0, pickup);
          } else {
            // Update status
            _activePickups[index] = _activePickups[index].copyWith(
              status: status,
            );
          }
        }
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Set filter
  void setFilter(PickupFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  /// Clear filter
  void clearFilter() {
    _filter = PickupFilter();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
