import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  String? get _uid => _auth.currentUser?.uid;
  String? get currentUserId => _uid;

  // ═══════════════════════════════════════════════════════════════════════════
  // PICKUPS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Schedule a new waste pickup
  Future<String> schedulePickup({
    required String address,
    required String addressLabel,
    required DateTime date,
    required String timeSlot,
    required double weight,
    required List<String> wasteTypes,
    required double amount,
    String? notes,
    bool fragileItems = false,
    bool needBags = false,
    bool heavyItems = false,
    double? latitude,
    double? longitude,
  }) async {
    if (_uid == null) throw Exception('User not logged in');

    // Fetch user profile so Collector & Admin apps can display user details
    String userName = 'User';
    String userPhone = '';
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        userName = data['fullName'] ?? data['name'] ?? 'User';
        userPhone = data['phone'] ?? data['phoneNumber'] ?? '';
      }
    } catch (_) {}

    // Derive a single 'type' string from the wasteTypes list for the collector app
    final String primaryType = wasteTypes.isNotEmpty ? wasteTypes.first : 'plastic';

    final docRef = await _db.collection('pickupRequests').add({
      'userId': _uid,
      // User details — read by Collector & Admin apps
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': address,
      // Original fields
      'address': address,
      'addressLabel': addressLabel,
      'date': Timestamp.fromDate(date),
      'time': timeSlot,
      'weightKg': weight,
      'weight': weight,              // alias for collector app
      'wasteTypes': wasteTypes,
      'type': primaryType,            // single-value alias for collector app
      'amount': amount,
      'earnings': amount,             // alias for collector app
      'notes': notes ?? '',
      'fragileItems': fragileItems,
      'needBags': needBags,
      'heavyItems': heavyItems,
      'status': 'PENDING',
      'paymentStatus': 'PENDING',
      'driverId': null,
      'driverName': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });

    return docRef.id;
  }

  /// Get all pickups for the current user
  Stream<QuerySnapshot> getUserPickups({String? statusFilter}) {
    if (_uid == null) throw Exception('User not logged in');

    Query query = _db
        .collection('pickupRequests')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.snapshots();
  }

  /// Get upcoming pickups (scheduled or confirmed)
  Stream<QuerySnapshot> getUpcomingPickups() {
    if (_uid == null) throw Exception('User not logged in');

    return _db
        .collection('pickupRequests')
        .where('userId', isEqualTo: _uid)
        .where('status', whereIn: ['PENDING', 'ASSIGNED', 'ACCEPTED', 'ON_THE_WAY', 'REACHED'])
        .orderBy('date')
        .limit(5)
        .snapshots();
  }

  /// Get a single pickup by ID
  Stream<DocumentSnapshot> getPickup(String pickupId) {
    return _db.collection('pickupRequests').doc(pickupId).snapshots();
  }

  /// Update pickup status
  Future<void> updatePickupStatus(String pickupId, String status) async {
    await _db.collection('pickupRequests').doc(pickupId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update payment status for a pickup
  Future<void> updatePaymentStatus({
    required String pickupId,
    required String paymentStatus,
    String? paymentMethod,
    String? transactionId,
  }) async {
    await _db.collection('pickupRequests').doc(pickupId).update({
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paidAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel a pickup
  Future<void> cancelPickup(String pickupId) async {
    await _db.collection('pickupRequests').doc(pickupId).update({
      'status': 'CANCELLED',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART BINS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get smart bin data for the current user
  Stream<QuerySnapshot> getUserBins() {
    if (_uid == null) throw Exception('User not logged in');

    return _db
        .collection('bins')
        .where('userId', isEqualTo: _uid)
        .snapshots();
  }

  /// Initialize default bins for a new user
  Future<void> initializeUserBins() async {
    if (_uid == null) return;

    final existingBins = await _db
        .collection('bins')
        .where('userId', isEqualTo: _uid)
        .get();

    if (existingBins.docs.isNotEmpty) return; // Already initialized

    final defaultBins = [
      {
        'name': 'General Waste',
        'type': 'general',
        'fillLevel': 0.45,
        'lastEmptied': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'autoSchedule': true,
        'threshold': 0.85,
        'icon': 'delete_outline',
        'color': 0xFF607D8B,
      },
      {
        'name': 'Recyclable',
        'type': 'recyclable',
        'fillLevel': 0.72,
        'lastEmptied': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'autoSchedule': true,
        'threshold': 0.80,
        'icon': 'recycling',
        'color': 0xFF2E7D32,
      },
      {
        'name': 'Organic',
        'type': 'organic',
        'fillLevel': 0.30,
        'lastEmptied': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'autoSchedule': false,
        'threshold': 0.90,
        'icon': 'eco',
        'color': 0xFF8D6E63,
      },
      {
        'name': 'Hazardous',
        'type': 'hazardous',
        'fillLevel': 0.15,
        'lastEmptied': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'autoSchedule': true,
        'threshold': 0.70,
        'icon': 'warning_amber',
        'color': 0xFFE53935,
      },
    ];

    final batch = _db.batch();
    for (final bin in defaultBins) {
      final docRef = _db.collection('bins').doc();
      batch.set(docRef, {
        ...bin,
        'userId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Update bin fill level
  Future<void> updateBinFillLevel(String binId, double fillLevel) async {
    await _db.collection('bins').doc(binId).update({
      'fillLevel': fillLevel,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MARKETPLACE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get marketplace items (global — all users can see)
  Stream<QuerySnapshot> getMarketplaceItems({String? category}) {
    Query query = _db
        .collection('marketplace')
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots();
  }

  /// List an item for sale on marketplace
  Future<String> listItemForSale({
    required String name,
    required String category,
    required double weight,
    required double pricePerKg,
    String? description,
  }) async {
    if (_uid == null) throw Exception('User not logged in');

    final userName = _auth.currentUser?.displayName ?? 'User';
    final docRef = await _db.collection('marketplace').add({
      'userId': _uid,
      'sellerName': userName,
      'name': name,
      'category': category,
      'weight': weight,
      'pricePerKg': pricePerKg,
      'totalPrice': weight * pricePerKg,
      'description': description ?? '',
      'status': 'available', // available, sold, expired
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Get market rates (global pricing data)
  Stream<QuerySnapshot> getMarketRates() {
    return _db.collection('marketRates').snapshots();
  }

  /// Initialize default market rates if they don't exist
  Future<void> initializeMarketRates() async {
    final existing = await _db.collection('marketRates').get();
    if (existing.docs.isNotEmpty) return;

    final rates = [
      {'name': 'Paper', 'rate': 12.0, 'change': '+2.5', 'isUp': true, 'icon': 'description', 'color': 0xFF42A5F5},
      {'name': 'Plastic', 'rate': 15.0, 'change': '+1.8', 'isUp': true, 'icon': 'local_drink', 'color': 0xFFFF7043},
      {'name': 'Metal', 'rate': 35.0, 'change': '-0.5', 'isUp': false, 'icon': 'settings', 'color': 0xFF78909C},
      {'name': 'Glass', 'rate': 8.0, 'change': '+0.3', 'isUp': true, 'icon': 'wine_bar', 'color': 0xFF26A69A},
      {'name': 'E-Waste', 'rate': 50.0, 'change': '+5.0', 'isUp': true, 'icon': 'devices', 'color': 0xFFAB47BC},
      {'name': 'Cardboard', 'rate': 10.0, 'change': '+1.0', 'isUp': true, 'icon': 'inventory_2', 'color': 0xFF8D6E63},
    ];

    final batch = _db.batch();
    for (final rate in rates) {
      final docRef = _db.collection('marketRates').doc();
      batch.set(docRef, rate);
    }
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS / PAYMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Record a payment transaction
  Future<String> recordTransaction({
    required String pickupId,
    required double amount,
    required String paymentMethod,
    required String type, // payment, earning, refund
  }) async {
    if (_uid == null) throw Exception('User not logged in');

    final docRef = await _db.collection('transactions').add({
      'userId': _uid,
      'pickupId': pickupId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'type': type,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update eco points
    if (type == 'payment') {
      final ecoPoints = (amount * 2).toInt();
      await _db.collection('users').doc(_uid).update({
        'ecoPoints': FieldValue.increment(ecoPoints),
      });
    }

    return docRef.id;
  }

  /// Get user's transaction history
  Stream<QuerySnapshot> getUserTransactions({String? typeFilter}) {
    if (_uid == null) throw Exception('User not logged in');

    Query query = _db
        .collection('transactions')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true);

    if (typeFilter != null) {
      query = query.where('type', isEqualTo: typeFilter);
    }

    return query.snapshots();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update user's subscription plan
  Future<void> updateSubscription(String plan) async {
    if (_uid == null) return;

    await _db.collection('users').doc(_uid).update({
      'subscriptionPlan': plan,
      'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get subscription plans (global)
  Stream<QuerySnapshot> getSubscriptionPlans() {
    return _db.collection('subscriptionPlans').snapshots();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER STATS / ECO-IMPACT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get user profile data as a stream
  Stream<DocumentSnapshot> getUserProfileStream() {
    if (_uid == null) throw Exception('User not logged in');
    return _db.collection('users').doc(_uid).snapshots();
  }

  /// Update eco-impact stats after a completed pickup
  Future<void> updateEcoImpact({
    required double wasteWeight,
    required List<String> wasteTypes,
  }) async {
    if (_uid == null) return;

    // Rough calculations for eco-impact
    final co2Saved = wasteWeight * 2.5; // ~2.5 kg CO2 per kg recycled
    final treesEquivalent = co2Saved / 21.0; // ~21 kg CO2 per tree per year

    await _db.collection('users').doc(_uid).update({
      'totalWasteRecycled': FieldValue.increment(wasteWeight),
      'co2Saved': FieldValue.increment(co2Saved),
      'treesEquivalent': FieldValue.increment(treesEquivalent),
      'totalPickups': FieldValue.increment(1),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDRESSES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get user's saved addresses
  Stream<QuerySnapshot> getUserAddresses() {
    if (_uid == null) throw Exception('User not logged in');

    return _db
        .collection('users')
        .doc(_uid)
        .collection('addresses')
        .snapshots();
  }

  /// Save a new address
  Future<String> saveAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    String? landmark,
    bool isDefault = false,
  }) async {
    if (_uid == null) throw Exception('User not logged in');

    // If setting as default, clear default on other addresses first
    if (isDefault) {
      final batch = _db.batch();
      final existing = await _db
          .collection('users')
          .doc(_uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .get();
      
      for (var doc in existing.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }

    final docRef = await _db
        .collection('users')
        .doc(_uid)
        .collection('addresses')
        .add({
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark ?? '',
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}
