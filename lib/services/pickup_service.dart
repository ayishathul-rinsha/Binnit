import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'firestore_service.dart';

/// Pickup Service - Now connected to Firebase Firestore
class PickupService {
  static String? get _collectorId => FirebaseAuth.instance.currentUser?.uid;

  /// Fetch incoming pickup requests (pending pickups available)
  static Future<List<PickupRequest>> getPickupRequests() async {
    return await FirestoreService.getPendingPickups();
  }

  /// Fetch active pickups for current collector
  static Future<List<PickupRequest>> getActivePickups() async {
    if (_collectorId == null) return [];
    return await FirestoreService.getActivePickups(_collectorId!);
  }

  /// Fetch pickup history
  static Future<List<PickupRequest>> getPickupHistory({
    DateTime? startDate,
    DateTime? endDate,
    WasteCategory? category,
  }) async {
    if (_collectorId == null) return [];
    return await FirestoreService.getPickupHistory(
      _collectorId!,
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }

  /// Accept a pickup request
  static Future<Map<String, dynamic>> acceptPickup(String pickupId) async {
    if (_collectorId == null) {
      return {'success': false, 'message': 'Not logged in'};
    }

    final success =
        await FirestoreService.acceptPickup(pickupId, _collectorId!);
    return {
      'success': success,
      'message': success ? 'Pickup accepted' : 'Failed to accept pickup',
    };
  }

  /// Reject a pickup request
  static Future<Map<String, dynamic>> rejectPickup(String pickupId) async {
    final success = await FirestoreService.rejectPickup(pickupId);
    return {
      'success': success,
      'message': success ? 'Pickup rejected' : 'Failed to reject pickup',
    };
  }

  /// Update pickup status
  static Future<Map<String, dynamic>> updatePickupStatus(
    String pickupId,
    PickupStatus status,
  ) async {
    final success = await FirestoreService.updatePickupStatus(pickupId, status);
    return {
      'success': success,
      'message': success
          ? 'Status updated to ${status.displayName}'
          : 'Failed to update status',
    };
  }

  /// Upload proof of pickup (photo)
  /// Note: Firebase Storage integration can be added later
  static Future<bool> uploadProof(String pickupId, String imagePath) async {
    // TODO: Upload to Firebase Storage when needed
    return true;
  }

  /// Stream of pending pickup requests (real-time)
  static Stream<List<PickupRequest>> pendingPickupsStream() {
    return FirestoreService.pickupRequestsStream();
  }

  /// Stream of active pickups (real-time)
  static Stream<List<PickupRequest>> activePickupsStream() {
    if (_collectorId == null) return Stream.value([]);
    return FirestoreService.activePickupsStream(_collectorId!);
  }
}
