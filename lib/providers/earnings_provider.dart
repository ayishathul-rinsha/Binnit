import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/earnings_service.dart';

/// Earnings Provider for managing earnings state
class EarningsProvider extends ChangeNotifier {
  Earnings? _earnings;
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'Today'; // Today, Weekly, Monthly

  // Getters
  Earnings? get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;

  double get displayedEarnings {
    if (_earnings == null) return 0.0;
    switch (_selectedPeriod) {
      case 'Today':
        return _earnings!.todayEarnings;
      case 'Weekly':
        return _earnings!.weeklyEarnings;
      case 'Monthly':
        return _earnings!.monthlyEarnings;
      default:
        return _earnings!.todayEarnings;
    }
  }

  /// Safe notify that uses microtask to avoid build phase issues
  void _safeNotify() {
    Future.microtask(() => notifyListeners());
  }

  /// Fetch earnings data
  Future<void> fetchEarnings() async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      _earnings = await EarningsService.getEarnings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Set selected period
  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  /// Request payout
  Future<bool> requestPayout(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await EarningsService.requestPayout(amount);

      _isLoading = false;
      if (result['success'] != true) {
        _error = result['message'];
      }
      notifyListeners();
      return result['success'] == true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
