import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Firestore Service - Centralized Firestore operations
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========================
  // USERS / COLLECTORS
  // ========================

  /// Get collector profile
  static Future<Collector?> getCollector(String userId) async {
    final doc = await _db.collection('collectors').doc(userId).get();
    if (doc.exists) {
      return Collector.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  /// Update collector profile
  static Future<void> updateCollector(Collector collector) async {
    await _db.collection('collectors').doc(collector.id).update(collector.toJson());
  }

  /// Update collector online status
  static Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await _db.collection('collectors').doc(userId).update({
      'is_online': isOnline,
    });
  }

  /// Update collector profile fields
  static Future<void> updateCollectorFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    await _db.collection('collectors').doc(userId).update(fields);
  }

  // ========================
  // PICKUP REQUESTS
  // ========================

  /// Get pending pickup requests (available for collector)
  static Future<List<PickupRequest>> getPendingPickups() async {
    final snapshot = await _db
        .collection('pickupRequests')
        .where('status', isEqualTo: PickupStatus.pending.index)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  /// Get active pickups for a collector
  static Future<List<PickupRequest>> getActivePickups(
      String collectorId) async {
    final snapshot = await _db
        .collection('pickupRequests')
        .where('collector_id', isEqualTo: collectorId)
        .where('status', whereIn: [
          PickupStatus.accepted.index,
          PickupStatus.onTheWay.index,
          PickupStatus.reached.index,
          PickupStatus.pickedUp.index,
        ])
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  /// Get pickup history for a collector
  static Future<List<PickupRequest>> getPickupHistory(
    String collectorId, {
    DateTime? startDate,
    DateTime? endDate,
    WasteCategory? category,
  }) async {
    Query query = _db
        .collection('pickupRequests')
        .where('collector_id', isEqualTo: collectorId)
        .where('status', whereIn: [
      PickupStatus.completed.index,
      PickupStatus.cancelled.index,
    ]);

    if (startDate != null) {
      query = query.where('created_at',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.where('created_at',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.orderBy('created_at', descending: true).get();

    var results = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PickupRequest.fromJson({...data, 'id': doc.id});
    }).toList();

    // Filter by category client-side (Firestore doesn't support multiple whereIn)
    if (category != null) {
      results = results.where((r) => r.category == category).toList();
    }

    return results;
  }

  /// Accept a pickup request
  static Future<bool> acceptPickup(
    String pickupId,
    String collectorId,
  ) async {
    try {
      await _db.collection('pickupRequests').doc(pickupId).update({
        'status': PickupStatus.accepted.index,
        'collector_id': collectorId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reject a pickup (just remove collector assignment)
  static Future<bool> rejectPickup(String pickupId) async {
    try {
      await _db.collection('pickupRequests').doc(pickupId).update({
        'status': PickupStatus.pending.index,
        'collector_id': FieldValue.delete(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update pickup status
  static Future<bool> updatePickupStatus(
    String pickupId,
    PickupStatus status,
  ) async {
    try {
      final updates = <String, dynamic>{
        'status': status.index,
      };

      // If completed, add completion timestamp
      if (status == PickupStatus.completed) {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _db.collection('pickupRequests').doc(pickupId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========================
  // EARNINGS
  // ========================

  /// Get earnings for a collector
  static Future<Earnings> getEarnings(String collectorId) async {
    final doc = await _db.collection('earnings').doc(collectorId).get();

    if (doc.exists) {
      return Earnings.fromJson(doc.data()!);
    }

    // Return empty earnings if no document exists yet
    return Earnings(
      todayEarnings: 0,
      weeklyEarnings: 0,
      monthlyEarnings: 0,
      pendingPayment: 0,
      receivedPayment: 0,
      transactions: [],
    );
  }

  /// Get earning transactions for a collector
  static Future<List<EarningTransaction>> getTransactions(
    String collectorId,
  ) async {
    final snapshot = await _db
        .collection('earnings')
        .doc(collectorId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) {
      return EarningTransaction.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  /// Listen to pickup requests in real-time (stream)
  static Stream<List<PickupRequest>> pickupRequestsStream() {
    return _db
        .collection('pickupRequests')
        .where('status', isEqualTo: PickupStatus.pending.index)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  /// Listen to active pickups in real-time
  static Stream<List<PickupRequest>> activePickupsStream(String collectorId) {
    return _db
        .collection('pickupRequests')
        .where('collector_id', isEqualTo: collectorId)
        .where('status', whereIn: [
          PickupStatus.accepted.index,
          PickupStatus.onTheWay.index,
          PickupStatus.reached.index,
          PickupStatus.pickedUp.index,
        ])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }
}
