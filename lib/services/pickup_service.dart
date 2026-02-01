import '../models/models.dart';

/// Pickup Service - Backend ready (returns empty data until backend is connected)
class PickupService {
  /// Fetch incoming pickup requests
  /// Returns empty list - will be populated from backend when users request pickups
  static Future<List<PickupRequest>> getPickupRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // No hardcoded data - will come from backend via API
    return [];
  }

  /// Fetch active pickups for current collector
  /// Returns empty list - will be populated when collector accepts a pickup
  static Future<List<PickupRequest>> getActivePickups() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // No hardcoded data - will come from backend
    return [];
  }

  /// Fetch pickup history
  /// Returns empty list - will be populated from backend after pickups are completed
  static Future<List<PickupRequest>> getPickupHistory({
    DateTime? startDate,
    DateTime? endDate,
    WasteCategory? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // No hardcoded data - will come from backend
    return [];
  }

  /// Accept a pickup request - returns result map
  static Future<Map<String, dynamic>> acceptPickup(String pickupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Backend will handle this
    return {'success': true, 'message': 'Pickup accepted'};
  }

  /// Reject a pickup request - returns result map
  static Future<Map<String, dynamic>> rejectPickup(String pickupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Backend will handle this
    return {'success': true, 'message': 'Pickup rejected'};
  }

  /// Update pickup status - returns result map
  static Future<Map<String, dynamic>> updatePickupStatus(
    String pickupId,
    PickupStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Backend will handle this
    return {
      'success': true,
      'message': 'Status updated to ${status.displayName}'
    };
  }

  /// Upload proof of pickup (photo)
  static Future<bool> uploadProof(String pickupId, String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Backend will handle file upload
    return true;
  }
}
