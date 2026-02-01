/// Model for individual earning transaction
class EarningTransaction {
  final String id;
  final String pickupId;
  final double amount;
  final DateTime date;
  final bool isPaid;
  final String description;

  EarningTransaction({
    required this.id,
    required this.pickupId,
    required this.amount,
    required this.date,
    this.isPaid = false,
    required this.description,
  });

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] ?? '',
      pickupId: json['pickup_id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isPaid: json['is_paid'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup_id': pickupId,
      'amount': amount,
      'date': date.toIso8601String(),
      'is_paid': isPaid,
      'description': description,
    };
  }
}

/// Model for earnings summary
class Earnings {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double pendingPayment;
  final double receivedPayment;
  final List<EarningTransaction> transactions;

  Earnings({
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.pendingPayment = 0.0,
    this.receivedPayment = 0.0,
    this.transactions = const [],
  });

  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      todayEarnings: (json['today_earnings'] ?? 0.0).toDouble(),
      weeklyEarnings: (json['weekly_earnings'] ?? 0.0).toDouble(),
      monthlyEarnings: (json['monthly_earnings'] ?? 0.0).toDouble(),
      pendingPayment: (json['pending_payment'] ?? 0.0).toDouble(),
      receivedPayment: (json['received_payment'] ?? 0.0).toDouble(),
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map((e) => EarningTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_earnings': todayEarnings,
      'weekly_earnings': weeklyEarnings,
      'monthly_earnings': monthlyEarnings,
      'pending_payment': pendingPayment,
      'received_payment': receivedPayment,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  double get totalEarnings => receivedPayment + pendingPayment;
}
