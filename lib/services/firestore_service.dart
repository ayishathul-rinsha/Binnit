// Removed dart:io since we use flutter/foundation for cross-platform now
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Firestore Service - Centralized Firestore operations
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

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
      'isOnline': isOnline,
    });
  }

  /// Update collector profile fields
  static Future<void> updateCollectorFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    await _db.collection('collectors').doc(userId).update(fields);
  }

  /// Upload image bytes to Firebase Storage (Web & Mobile safe)
  static Future<String> uploadImageBytes(
      Uint8List bytes, String name, String extension) async {
    String contentType = 'image/jpeg'; // Default
    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    }

    final ref = _storage.ref().child('profiles/$name.$extension');
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  // ========================
  // PICKUP REQUESTS
  // ========================

  /// Get pending pickup requests (available for collector)
  static Future<List<PickupRequest>> getPendingPickups() async {
    final snapshot = await _db
        .collection('pickupRequests')
        .where('status', isEqualTo: PickupStatus.pending.firestoreValue)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  static Future<List<PickupRequest>> getActivePickups(
      String collectorId) async {
    final snapshot = await _db
        .collection('pickupRequests')
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: [
          'ACCEPTED', 'accepted',
          'ON_THE_WAY', 'on_the_way',
          'REACHED', 'reached',
          'PICKED_UP', 'picked_up',
        ])
        .orderBy('createdAt', descending: true)
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
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: [
      PickupStatus.completed.firestoreValue,
      PickupStatus.cancelled.firestoreValue,
    ]);

    if (startDate != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.where('createdAt',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();

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

  static Future<List<PickupRequest>> getAssignedPickups(String collectorId) async {
    final snapshot = await _db
        .collection('pickupRequests')
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: ['ASSIGNED', 'assigned'])
        .get();

    final results = snapshot.docs.map((doc) {
      return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
    // Sort client-side to avoid composite index requirement
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  static Stream<List<PickupRequest>> assignedPickupsStream(String collectorId) {
    return _db
        .collection('pickupRequests')
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: ['ASSIGNED', 'assigned'])
        .snapshots()
        .map((snapshot) {
      final results = snapshot.docs.map((doc) {
        return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    });
  }

  /// Collector accepts an assigned pickup (ASSIGNED -> ACCEPTED)
  static Future<bool> collectorAcceptPickup(String pickupId) async {
    try {
      await _db.collection('pickupRequests').doc(pickupId).update({
        'status': PickupStatus.accepted.firestoreValue,
      });

      // Notify the Admin web dashboard
      await _db.collection('collectorAssign').doc(pickupId).set({
        'status': 'accepted',
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Collector rejects an assigned pickup (ASSIGNED -> PENDING, remove collector)
  static Future<bool> collectorRejectPickup(String pickupId) async {
    try {
      await _db.collection('pickupRequests').doc(pickupId).update({
        'status': PickupStatus.pending.firestoreValue,
        'collectorId': FieldValue.delete(),
        'assignedAt': FieldValue.delete(),
      });

      // Notify the Admin web dashboard
      await _db.collection('collectorAssign').doc(pickupId).set({
        'status': 'rejected',
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Accept a pickup request
  static Future<bool> acceptPickup(
    String pickupId,
    String collectorId,
  ) async {
    try {
      await _db.collection('pickupRequests').doc(pickupId).update({
        'status': PickupStatus.accepted.firestoreValue,
        'collectorId': collectorId,
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
        'status': PickupStatus.pending.firestoreValue,
        'collectorId': FieldValue.delete(),
        'assignedAt': FieldValue.delete(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update pickup status
  static Future<bool> updatePickupStatus(
    String pickupId,
    PickupStatus status, {
    String? proofPhotoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.firestoreValue,
      };

      if (proofPhotoUrl != null) {
        updates['proofPhotoUrl'] = proofPhotoUrl;
      }

      // If completed, add completion timestamp and award eco points
      if (status == PickupStatus.completed) {
        updates['completedAt'] = DateTime.now().toIso8601String();
        
        // Award Eco Impact to user
        final doc = await _db.collection('pickupRequests').doc(pickupId).get();
        if (doc.exists) {
          final data = doc.data()!;
          final userId = data['userId'];
          final weight = (data['weight'] ?? data['weightKg'] ?? data['estimatedWeight'] ?? 0.0).toDouble();
          
          if (userId != null && weight > 0) {
            final int ecoPoints = (weight * 10).toInt(); // 10 points per Kg
            final double co2Saved = weight * 2.5; // ~2.5 kg CO2 per kg recycled
            final double treesEquivalent = co2Saved / 21.0; // ~21 kg CO2 per tree per year
            
            await _db.collection('users').doc(userId).update({
              'ecoPoints': FieldValue.increment(ecoPoints),
              'totalWasteRecycled': FieldValue.increment(weight),
              'co2Saved': FieldValue.increment(co2Saved),
              'treesEquivalent': FieldValue.increment(treesEquivalent),
              'totalPickups': FieldValue.increment(1),
            }).catchError((e) => debugPrint('Notice: Error updating eco impact: $e'));
          }
        }
      }

      await _db.collection('pickupRequests').doc(pickupId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating pickup status: $e');
      return false;
    }
  }

  // ========================
  // EARNINGS
  // ========================

  /// Get earnings for a collector
  static Future<Earnings> getEarnings(String collectorId) async {
    try {
      // Get collector profile for total earnings
      final collector = await getCollector(collectorId);
      
      // Get today's completed pickups to calculate today's earnings
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      
      final todaySnapshot = await _db
          .collection('pickupRequests')
          .where('collectorId', isEqualTo: collectorId)
          .where('status', isEqualTo: PickupStatus.completed.firestoreValue)
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .get();

      double todayEarnings = 0;
      for (var doc in todaySnapshot.docs) {
        final data = doc.data();
        todayEarnings += (data['earnings'] ?? 0.0).toDouble();
      }

      return Earnings(
        todayEarnings: todayEarnings,
        weeklyEarnings: todayEarnings, // Simplified for now as backend doesn't aggregate weekly
        monthlyEarnings: todayEarnings, // Simplified
        pendingPayment: 0,
        receivedPayment: collector?.totalEarnings ?? 0,
        transactions: [],
      );
    } catch (e) {
      return Earnings();
    }
  }

  /// Get earning transactions for a collector (Not currently implemented in backend)
  static Future<List<EarningTransaction>> getTransactions(
    String collectorId,
  ) async {
    return [];
  }

  /// Listen to pickup requests in real-time (stream)
  static Stream<List<PickupRequest>> pickupRequestsStream() {
    return _db
        .collection('pickupRequests')
        .where('status', isEqualTo: PickupStatus.pending.firestoreValue)
        .orderBy('createdAt', descending: true)
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
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: [
          'ACCEPTED', 'accepted',
          'ON_THE_WAY', 'on_the_way',
          'REACHED', 'reached',
          'PICKED_UP', 'picked_up',
        ])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  /// Get dynamic stats for profile (pickups, rating, today's hours)
  static Future<Map<String, dynamic>> getCollectorStats(String collectorId) async {
    try {
      final snapshot = await _db
          .collection('pickupRequests')
          .where('collectorId', isEqualTo: collectorId)
          .where('status', isEqualTo: PickupStatus.completed.firestoreValue)
          .get();

      int totalPickups = snapshot.docs.length;
      
      double totalRating = 0.0;
      int ratingCount = 0;
      double todayHours = 0.0;

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Rating
        if (data['userRating'] != null) {
          final r = (data['userRating'] as num).toDouble();
          if (r > 0) {
            totalRating += r;
            ratingCount++;
          }
        }

        // Today's hours
        if (data['completedAt'] != null) {
          final completedAt = data['completedAt'] is Timestamp 
              ? (data['completedAt'] as Timestamp).toDate() 
              : DateTime.tryParse(data['completedAt'].toString());
              
          if (completedAt != null && completedAt.isAfter(startOfToday)) {
            if (data['assignedAt'] != null) {
              final assignedAt = data['assignedAt'] is Timestamp 
                  ? (data['assignedAt'] as Timestamp).toDate() 
                  : DateTime.tryParse(data['assignedAt'].toString());
              if (assignedAt != null) {
                 final duration = completedAt.difference(assignedAt);
                 todayHours += duration.inMinutes / 60.0;
              } else {
                 todayHours += 1.0; 
              }
            } else {
               todayHours += 1.0; 
            }
          }
        }
      }

      double avgRating = ratingCount > 0 ? (totalRating / ratingCount) : 0.0;

      return {
        'totalPickups': totalPickups,
        'rating': avgRating,
        'totalHoursToday': todayHours,
      };
    } catch (e) {
      return {
        'totalPickups': 0,
        'rating': 0.0,
        'totalHoursToday': 0.0,
      };
    }
  }
}

