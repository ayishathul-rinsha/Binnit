import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/earnings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Earnings screen with breakdown and transactions
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEarnings();
    });
  }

  Future<void> _loadEarnings() async {
    if (!mounted) return;
    final provider = Provider.of<EarningsProvider>(context, listen: false);
    await provider.fetchEarnings();
  }

  void _showWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _WithdrawBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.earnings),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEarnings),
        ],
      ),
      body: Consumer<EarningsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.earnings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.earnings == null) {
            return ErrorState(
              message: provider.error!,
              onAction: _loadEarnings,
            );
          }

          final earnings = provider.earnings;

          return RefreshIndicator(
            onRefresh: _loadEarnings,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEarningsCard(provider),
                  const SizedBox(height: AppDimens.paddingL),
                  _buildPeriodSelector(provider),
                  const SizedBox(height: AppDimens.paddingL),
                  _buildPaymentStatusCards(earnings),
                  const SizedBox(height: AppDimens.paddingL),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _showWithdrawSheet,
                      icon: const Icon(Icons.account_balance_wallet, size: 24),
                      label: Text(
                        l10n.withdraw,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  _buildTransactionsSection(earnings),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningsCard(EarningsProvider provider) {
    final l10n = AppLocalizations.of(context);
    final periodLabel = provider.selectedPeriod == 'Today'
        ? l10n.today
        : provider.selectedPeriod == 'Weekly'
            ? l10n.weekly
            : l10n.monthly;
    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$periodLabel ${l10n.earnings}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              CurrencyHelper.formatCurrency(provider.displayedEarnings),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(EarningsProvider provider) {
    final l10n = AppLocalizations.of(context);
    final periods = [
      {'key': 'Today', 'label': l10n.today},
      {'key': 'Weekly', 'label': l10n.weekly},
      {'key': 'Monthly', 'label': l10n.monthly},
    ];

    return Row(
      children: periods.map((period) {
        final isSelected = provider.selectedPeriod == period['key'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: period != periods.last ? AppDimens.paddingS : 0,
            ),
            child: GestureDetector(
              onTap: () => provider.setSelectedPeriod(period['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingM,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  period['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentStatusCards(earnings) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _PaymentCard(
            title: l10n.pending,
            amount: earnings?.pendingPayment ?? 0,
            icon: Icons.schedule,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppDimens.paddingM),
        Expanded(
          child: _PaymentCard(
            title: l10n.received,
            amount: earnings?.receivedPayment ?? 0,
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(earnings) {
    final l10n = AppLocalizations.of(context);
    final transactions = earnings?.transactions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentTransactions,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimens.paddingM),
        if (transactions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: AppDimens.paddingM),
                    Text(
                      l10n.noTransactions,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...transactions
              .take(10)
              .map((txn) => _TransactionCard(transaction: txn)),
      ],
    );
  }
}

/// Payment status card
class _PaymentCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _PaymentCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.paddingS),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppDimens.paddingS),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              CurrencyHelper.formatCurrency(amount),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction card
class _TransactionCard extends StatelessWidget {
  final dynamic transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingS),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (transaction.isPaid ? AppColors.success : AppColors.warning)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusS),
          ),
          child: Icon(
            transaction.isPaid ? Icons.check_circle : Icons.schedule,
            color: transaction.isPaid ? AppColors.success : AppColors.warning,
            size: 20,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(DateHelper.formatDate(transaction.date)),
        trailing: Text(
          '+${CurrencyHelper.formatCurrency(transaction.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

/// Withdraw bottom sheet
class _WithdrawBottomSheet extends StatefulWidget {
  const _WithdrawBottomSheet();

  @override
  State<_WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<_WithdrawBottomSheet> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidAmount),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<EarningsProvider>(context, listen: false);
    final success = await provider.requestPayout(amount);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.withdrawRequested
                : provider.error ?? l10n.withdrawFailed,
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.paddingL,
        right: AppDimens.paddingL,
        top: AppDimens.paddingL,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.paddingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingL),
          Text(
            l10n.withdrawFunds,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimens.paddingS),
          Text(
            l10n.enterWithdrawAmount,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.paddingL),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.amount,
              prefixText: '₹ ',
              hintText: '0.00',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimens.paddingS),
          Wrap(
            spacing: AppDimens.paddingS,
            children: [500, 1000, 2000, 5000].map((amount) {
              return ActionChip(
                label: Text('₹$amount'),
                onPressed: () {
                  _amountController.text = amount.toString();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.paddingL),
          CustomButton(
            text: l10n.withdraw,
            onPressed: _handleWithdraw,
            isLoading: _isLoading,
          ),
          const SizedBox(height: AppDimens.paddingM),
        ],
      ),
    );
  }
}
