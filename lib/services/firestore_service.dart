// Removed dart:io since we use flutter/foundation for cross-platform now
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // 1. Explicitly assigned to this collector
    final explicitlyAssignedSnap = await _db
        .collection('pickupRequests')
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: ['ASSIGNED', 'assigned'])
        .get();

    // 2. Broadcasted to this collector's group
    final broadcastedSnap = await _db
        .collection('pickupRequests')
        .where('status', isEqualTo: 'BROADCASTING')
        .get();

    // 3. ANY pending+paid request (fallback when admin dashboard is not open)
    //    This ensures collectors see requests even without the admin broadcasting them.
    final pendingPaidSnap = await _db
        .collection('pickupRequests')
        .where('status', whereIn: ['PENDING', 'pending'])
        .get();

    // Deduplicate by doc ID
    final Map<String, PickupRequest> resultMap = {};
    for (final doc in explicitlyAssignedSnap.docs) {
      resultMap[doc.id] = PickupRequest.fromJson({...doc.data(), 'id': doc.id});
    }
    for (final doc in broadcastedSnap.docs) {
      final notified = doc.data()['notifiedCollectors'] as List?;
      if (notified != null && notified.contains(collectorId)) {
        resultMap[doc.id] = PickupRequest.fromJson({...doc.data(), 'id': doc.id});
      }
    }
    for (final doc in pendingPaidSnap.docs) {
      final data = doc.data();
      // Only show paid pending requests (user has completed payment)
      if (data['paymentStatus'] == 'PAID' || data['paymentStatus'] == 'paid') {
        resultMap[doc.id] = PickupRequest.fromJson({...data, 'id': doc.id});
      }
    }

    final results = resultMap.values.toList();
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  static Stream<List<PickupRequest>> assignedPickupsStream(String collectorId) {
    // Listen for ALL actionable pickups:
    // 1. Explicitly assigned to this collector
    // 2. Broadcasted to this collector's group
    // 3. PENDING+PAID requests (fallback when admin dashboard isn't open)
    return _db.collection('pickupRequests')
        .where('status', whereIn: ['ASSIGNED', 'assigned', 'BROADCASTING', 'PENDING', 'pending'])
        .snapshots()
        .map((snapshot) {
          final filtered = snapshot.docs.where((doc) {
            final data = doc.data();
            final status = data['status'];
            final cId = data['collectorId'];
            final notified = data['notifiedCollectors'] as List?;
            
            // Broadcasted to this collector
            if (status == 'BROADCASTING' && notified != null && notified.contains(collectorId)) {
               return true;
            }
            // Explicitly assigned to this collector
            if ((status == 'ASSIGNED' || status == 'assigned') && cId == collectorId) {
               return true;
            }
            // PENDING + PAID: show to ALL collectors as claimable
            if ((status == 'PENDING' || status == 'pending')) {
               final payStatus = data['paymentStatus'];
               if (payStatus == 'PAID' || payStatus == 'paid') {
                  return true;
               }
            }
            return false;
          });

          final results = filtered.map((doc) {
            return PickupRequest.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
          results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return results;
        });
  }

  /// Collector accepts an assigned or broadcasted pickup
  /// Uses a transaction to ensure FCFS (First-Come First-Served) for broadcasted pickups.
  static Future<bool> collectorAcceptPickup(String pickupId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userRef = _db.collection('collectors').doc(uid);
    final reqRef = _db.collection('pickupRequests').doc(pickupId);
    final assignRef = _db.collection('collectorAssign').doc(pickupId);

    try {
      final success = await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(reqRef);
        if (!snapshot.exists) return false;

        final data = snapshot.data()!;
        final status = data['status'];
        final currentCollector = data['collectorId'];

        // If PENDING (paid), any collector can claim it
        if (status == 'PENDING' || status == 'pending') {
           if (currentCollector != null && currentCollector != uid) {
             return false; // Already claimed by someone else
           }
        }
        // If broadcasted, it MUST be unclaimed
        else if (status == 'BROADCASTING') {
           if (currentCollector != null && currentCollector != uid) {
             return false; // Already claimed by someone else
           }
        } 
        // If assigned, it MUST be assigned to ME
        else if (status == 'ASSIGNED' || status == 'assigned') {
           if (currentCollector != uid) return false;
        } else {
           return false; // Invalid status for acceptance
        }

        // Fetch collector name
        final collSnap = await transaction.get(userRef);
        final collName = collSnap.exists ? (collSnap.data()?['name'] ?? uid) : uid;

        // 1. Update Request
        transaction.update(reqRef, {
          'status': 'ACCEPTED',
          'collectorId': uid,
          'collectorName': collName,
          'acceptedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Create/Merge collectorAssign for Admin Dashboard visibility
        transaction.set(assignRef, {
          'requestId':    pickupId,
          'requestDocId': pickupId,
          'collectorId':  uid,
          'collectorName': collName,
          'status':       'accepted',
          'acceptedAt':   FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 3. Mark collector as busy
        transaction.update(userRef, {
          'isBusy': true,
          'currentAssignId': pickupId,
        });

        return true;
      });

      return success ?? false;
    } catch (e) {
      debugPrint('Claim error: $e');
      return false;
    }
  }

  /// Collector rejects an assigned/broadcasted pickup
  static Future<bool> collectorRejectPickup(String pickupId) async {
    try {
      await _db.collection('pickupRequests').doc(pickupId).update({
        'status': 'PENDING',
        'collectorId': FieldValue.delete(),
        'assignedAt': FieldValue.delete(),
        'notifiedCollectors': FieldValue.delete(), // Stop broadcasting to everyone if one rejects? 
        // Actually, usually we just remove the current user from the notified list.
      });

      // Notify the Admin web dashboard
      await _db.collection('collectorAssign').doc(pickupId).set({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
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
           final collectorId = data['collectorId']; // Usually present for completed pickups
           
           if (userId != null && weight > 0) {
             final int ecoPoints = (weight * 10).toInt(); 
             final double co2Saved = weight * 2.5; 
             final double treesEquivalent = co2Saved / 21.0; 
             
             await _db.collection('users').doc(userId).update({
               'ecoPoints': FieldValue.increment(ecoPoints),
               'totalWasteRecycled': FieldValue.increment(weight),
               'co2Saved': FieldValue.increment(co2Saved),
               'treesEquivalent': FieldValue.increment(treesEquivalent),
               'totalPickups': FieldValue.increment(1),
             }).catchError((e) => debugPrint('Error updating user eco impact: $e'));
           }

           // IMPORTANT: Free up the collector to receive new auto-assignments!
           if (collectorId != null) {
              await _db.collection('collectors').doc(collectorId).update({
                 'isBusy': false,
                 'currentAssignId': FieldValue.delete(),
              }).catchError((e) => debugPrint('Error freeing up collector: $e'));
              
              // Also sync collectorAssign so admin dashboard knows it's completed
              await _db.collection('collectorAssign').doc(pickupId).set({
                 'status': 'completed',
              }, SetOptions(merge: true)).catchError((_) {});
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

