import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'firestore_service.dart';

/// Earnings Service - Now connected to Firebase Firestore
class EarningsService {
  static String? get _collectorId => FirebaseAuth.instance.currentUser?.uid;

  /// Fetch earnings data for the collector from Firestore
  static Future<Earnings> getEarnings() async {
    if (_collectorId == null) {
      return Earnings(
        todayEarnings: 0,
        weeklyEarnings: 0,
        monthlyEarnings: 0,
        pendingPayment: 0,
        receivedPayment: 0,
        transactions: [],
      );
    }

    final earnings = await FirestoreService.getEarnings(_collectorId!);
    final transactions = await FirestoreService.getTransactions(_collectorId!);

    return Earnings(
      todayEarnings: earnings.todayEarnings,
      weeklyEarnings: earnings.weeklyEarnings,
      monthlyEarnings: earnings.monthlyEarnings,
      pendingPayment: earnings.pendingPayment,
      receivedPayment: earnings.receivedPayment,
      transactions: transactions,
    );
  }

  /// Request payout
  static Future<Map<String, dynamic>> requestPayout(double amount) async {
    if (amount <= 0) {
      return {'success': false, 'message': 'Invalid amount'};
    }

    // Backend/Cloud Function can handle actual payout processing
    return {'success': true, 'message': 'Payout request submitted'};
  }
}
