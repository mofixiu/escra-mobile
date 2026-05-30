import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_parser.dart';

import '../../../auth/domain/auth_controller.dart';
import '../../../shared/widgets/custom_pin_pad.dart';
import '../../../shared/widgets/high_contrast_button.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/wallet_repository.dart';

/// Gorgeous light wallet screen with action modals.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _walletRepo = GetIt.I<WalletRepository>();
  final _authCtrl = GetIt.I<AuthController>();

  List<TransactionModel> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loadingHistory = true);
    final history = await _walletRepo.getTransactions();
    setState(() {
      _history = history;
      _loadingHistory = false;
    });
  }

  void _openFundSheet() {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fund Escra Wallet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter the Naira amount you want to deposit directly.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: amountController,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '₦ ',
                    prefixStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 28),
                HighContrastButton(
                  text: 'PROCEED TO AUTHORISE',
                  onPressed: () {
                    final doubleVal = double.tryParse(amountController.text) ?? 0.0;
                    if (doubleVal <= 0) return;

                    Navigator.pop(context);
                    _openPinPadSheet(doubleVal, true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTransferSheet() {
    final amountController = TextEditingController();
    final recipientController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transfer Payout',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Withdraw wallet funds to external recipient account.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: recipientController,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Recipient Name or Bank Account',
                    prefixIcon: Icon(Icons.person_outline, size: 18, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '₦ ',
                    prefixStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 28),
                HighContrastButton(
                  text: 'PROCEED TO AUTHORISE',
                  onPressed: () {
                    final doubleVal = double.tryParse(amountController.text) ?? 0.0;
                    final recipient = recipientController.text.trim();
                    if (doubleVal <= 0 || recipient.isEmpty) return;

                    Navigator.pop(context);
                    _openPinPadSheet(doubleVal, false, recipient: recipient);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPinPadSheet(double nairaAmount, bool isFunding, {String? recipient}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomPinPad(
          title: isFunding ? 'Confirm Deposit' : 'Authorise Payout',
          subtitle: isFunding
              ? 'Securing deposit of ${CurrencyFormatter.formatKobo(CurrencyFormatter.nairaToKobo(nairaAmount))}'
              : 'Securing transfer of ${CurrencyFormatter.formatKobo(CurrencyFormatter.nairaToKobo(nairaAmount))} to $recipient',
          onComplete: (pin) async {
            Navigator.pop(context);
            if (pin == '1234') {
              final koboAmount = CurrencyFormatter.nairaToKobo(nairaAmount);

              if (isFunding) {
                await _walletRepo.fundWallet(koboAmount);
                final newBal = _authCtrl.currentUser!.balanceKobo + koboAmount;
                _authCtrl.updateBalance(newBal);
                _showStatusSnackBar('Wallet credited successfully!', isError: false);
              } else {
                if (_authCtrl.currentUser!.balanceKobo < koboAmount) {
                  _showStatusSnackBar('Insufficient balance.', isError: true);
                  return;
                }
                await _walletRepo.transferFunds(koboAmount, recipient ?? 'Recipient');
                final newBal = _authCtrl.currentUser!.balanceKobo - koboAmount;
                _authCtrl.updateBalance(newBal);
                _showStatusSnackBar('Payout transfer completed!', isError: false);
              }
              _fetchHistory();
            } else {
              _showStatusSnackBar('Verification failed: Invalid transaction PIN.', isError: true);
            }
          },
        );
      },
    );
  }

  void _showStatusSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authCtrl,
      builder: (context, _) {
        final user = _authCtrl.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F7F7),
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Wallet',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Image.asset(
                  'assets/logos/escralogonobackground.png',
                  height: 20,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _fetchHistory,
            color: Colors.white,
            backgroundColor: Colors.black,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              children: [
                // Minimalist black card for wallet
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ACTIVE ACCOUNT WALLET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Icon(
                            Icons.shield,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        CurrencyFormatter.formatKobo(user.balanceKobo),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Secure Identity: ${user.name} • ${user.role.name.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Deposit/Payout triggers
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openFundSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text(
                          'DEPOSIT FUNDS',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openTransferSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.black12, width: 1),
                          ),
                        ),
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: const Text(
                          'PAYOUT FUNDS',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // History List
                const Text(
                  'WALLET HISTORY LOGS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),

                if (_loadingHistory)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                else if (_history.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'No transactions recorded yet.',
                        style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final tx = _history[index];
                        final isCredit = tx.type == TransactionType.credit;

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCredit
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                                child: Icon(
                                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isCredit ? AppColors.success : Colors.black87,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.description,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateParser.getRelativeTime(tx.timestamp),
                                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? "+" : "-"}${CurrencyFormatter.formatKoboCompact(tx.amountKobo)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isCredit ? AppColors.success : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
