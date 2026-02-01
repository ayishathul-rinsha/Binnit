import '../models/models.dart';

/// Earnings Service - Backend ready (returns empty/zero data until backend is connected)
class EarningsService {
  /// Fetch earnings data for the collector
  /// Returns empty earnings - will be populated from backend after completed pickups
  static Future<Earnings> getEarnings() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Return empty earnings - no hardcoded values
    return Earnings(
      todayEarnings: 0,
      weeklyEarnings: 0,
      monthlyEarnings: 0,
      pendingPayment: 0,
      receivedPayment: 0,
      transactions: [], // No fake transactions
    );
  }

  /// Request payout - returns result map
  static Future<Map<String, dynamic>> requestPayout(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate amount
    if (amount <= 0) {
      return {'success': false, 'message': 'Invalid amount'};
    }

    // Backend will handle actual payout
    return {'success': true, 'message': 'Payout request submitted'};
  }
}
