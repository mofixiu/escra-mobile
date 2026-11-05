import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
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
    debugPrint('[WalletScreen] Fetching transaction history...');
    setState(() => _loadingHistory = true);
    try {
      final history = await _walletRepo.getTransactions();
      debugPrint('[WalletScreen] Transaction history fetch succeeded. Count: ${history.length}');
      setState(() {
        _history = history;
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint('[WalletScreen] Transaction history fetch failed: $e');
      setState(() {
        _loadingHistory = false;
      });
      rethrow;
    }
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
                  text: 'PROCEED TO DEPOSIT',
                  onPressed: () async {
                    final doubleVal = double.tryParse(amountController.text) ?? 0.0;
                    if (doubleVal <= 0) return;

                    Navigator.pop(context);
                    final koboAmount = CurrencyFormatter.nairaToKobo(doubleVal);

                    setState(() => _loadingHistory = true);
                    debugPrint('[WalletScreen] Initiating Kora wallet deposit. Amount (Kobo): $koboAmount');
                    try {
                      final checkoutUrl = await _walletRepo.startWalletFundingCheckout(koboAmount);
                      debugPrint('[WalletScreen] Wallet deposit checkout URL obtained: $checkoutUrl');
                      final uri = Uri.parse(checkoutUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                      } else {
                        throw 'Could not launch payment page';
                      }
                    } catch (e) {
                      debugPrint('[WalletScreen] Wallet deposit checkout failed: $e');
                      _showStatusSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
                    } finally {
                      setState(() => _loadingHistory = false);
                      _fetchHistory();
                    }
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
    final bankAccountController = TextEditingController();
    final fundUidController = TextEditingController();

    String currentMethod = 'internal'; // 'internal', 'kora', 'quidax'

    List<Map<String, String>> banks = [];
    bool loadingBanks = false;
    String? bankError;
    String? selectedBankCode;
    bool resolvingBank = false;
    String? resolvedName;

    String selectedCrypto = 'USDT';
    final cryptoOptions = ['USDT', 'BTC', 'ETH', 'USDC'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            void loadBanks() async {
              if (banks.isNotEmpty || loadingBanks) return;
              debugPrint('[WalletScreen] Loading supported banks...');
              setModalState(() {
                loadingBanks = true;
                bankError = null;
              });
              try {
                final list = await _walletRepo.getSupportedBanks();
                debugPrint('[WalletScreen] Supported banks loaded successfully. Count: ${list.length}');
                setModalState(() {
                  banks = list;
                  loadingBanks = false;
                });
              } catch (e) {
                debugPrint('[WalletScreen] Failed to load supported banks: $e');
                setModalState(() {
                  bankError = e.toString().replaceAll('Exception: ', '');
                  loadingBanks = false;
                });
              }
            }

            void resolveAccount() async {
              if (selectedBankCode == null || bankAccountController.text.trim().length != 10) return;
              debugPrint('[WalletScreen] Resolving bank account. Bank Code: $selectedBankCode, Account Number: ${bankAccountController.text.trim()}');
              setModalState(() {
                resolvingBank = true;
                resolvedName = null;
              });
              try {
                final res = await _walletRepo.resolveBankAccount(
                  bankCode: selectedBankCode!,
                  accountNumber: bankAccountController.text.trim(),
                );
                debugPrint('[WalletScreen] Bank account resolved. Account Name: ${res['account_name']}');
                setModalState(() {
                  resolvedName = res['account_name'] as String?;
                  resolvingBank = false;
                });
              } catch (e) {
                debugPrint('[WalletScreen] Bank account resolution failed: $e');
                setModalState(() {
                  resolvingBank = false;
                  resolvedName = null;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            }

            if (currentMethod == 'kora') {
              loadBanks();
            }

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
                      'Choose payout method and authorise transaction.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => currentMethod = 'internal'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: currentMethod == 'internal' ? Colors.black : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'INTERNAL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: currentMethod == 'internal' ? Colors.white : Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => currentMethod = 'kora'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: currentMethod == 'kora' ? Colors.black : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'BANK (KORA)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: currentMethod == 'kora' ? Colors.white : Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => currentMethod = 'quidax'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: currentMethod == 'quidax' ? Colors.black : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'CRYPTO (QDX)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: currentMethod == 'quidax' ? Colors.white : Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (currentMethod == 'internal') ...[
                      TextField(
                        controller: recipientController,
                        style: const TextStyle(color: Colors.black, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Recipient Wallet ID or Phone',
                          prefixIcon: Icon(Icons.person_outline, size: 18, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (currentMethod == 'kora') ...[
                      if (loadingBanks)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          ),
                        )
                      else if (bankError != null)
                        Text(
                          'Error: $bankError',
                          style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedBankCode,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          menuMaxHeight: 300,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Select Bank',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black, width: 1.2),
                            ),
                          ),
                          items: banks.map((bank) {
                            return DropdownMenuItem<String>(
                              value: bank['code'],
                              child: Text(bank['name']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedBankCode = val;
                            });
                            resolveAccount();
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: bankAccountController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: 'Account Number',
                            prefixIcon: Icon(Icons.account_balance_rounded, size: 18, color: Colors.black54),
                          ),
                          onChanged: (val) {
                            if (val.trim().length == 10) {
                              resolveAccount();
                            } else {
                              if (resolvedName != null) {
                                setModalState(() => resolvedName = null);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (resolvingBank)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            ),
                          )
                        else if (resolvedName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    resolvedName!,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.success),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ] else if (currentMethod == 'quidax') ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedCrypto,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select Crypto Currency',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2),
                          ),
                        ),
                        items: cryptoOptions.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedCrypto = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: fundUidController,
                        style: const TextStyle(color: Colors.black, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Wallet Destination / Fund UID',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

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
                        if (doubleVal <= 0) return;

                        if (currentMethod == 'internal') {
                          final recipient = recipientController.text.trim();
                          if (recipient.isEmpty) return;
                          Navigator.pop(context);
                          _openPinPadSheet(doubleVal, false, payoutMethod: 'internal', recipient: recipient);
                        } else if (currentMethod == 'kora') {
                          final acct = bankAccountController.text.trim();
                          if (selectedBankCode == null || acct.length != 10 || resolvedName == null) return;
                          Navigator.pop(context);
                          _openPinPadSheet(
                            doubleVal,
                            false,
                            payoutMethod: 'kora',
                            bankCode: selectedBankCode,
                            bankAccount: acct,
                            accountName: resolvedName,
                          );
                        } else if (currentMethod == 'quidax') {
                          final fundUid = fundUidController.text.trim();
                          if (fundUid.isEmpty) return;
                          Navigator.pop(context);
                          _openPinPadSheet(
                            doubleVal,
                            false,
                            payoutMethod: 'quidax',
                            cryptoCurrency: selectedCrypto,
                            fundUid: fundUid,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openPinPadSheet(
    double nairaAmount,
    bool isFunding, {
    String payoutMethod = 'internal',
    String? recipient,
    String? bankCode,
    String? bankAccount,
    String? accountName,
    String? cryptoCurrency,
    String? fundUid,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String subtitleMsg = '';
        if (isFunding) {
          subtitleMsg = 'Securing deposit of ${CurrencyFormatter.formatKobo(CurrencyFormatter.nairaToKobo(nairaAmount))}';
        } else if (payoutMethod == 'internal') {
          subtitleMsg = 'Securing transfer of ${CurrencyFormatter.formatKobo(CurrencyFormatter.nairaToKobo(nairaAmount))} to $recipient';
        } else if (payoutMethod == 'kora') {
          subtitleMsg = 'Securing payout of ${CurrencyFormatter.formatKobo(CurrencyFormatter.nairaToKobo(nairaAmount))} to $accountName';
        } else if (payoutMethod == 'quidax') {
          subtitleMsg = 'Securing withdrawal of $nairaAmount $cryptoCurrency to $fundUid';
        }

        return CustomPinPad(
          title: isFunding ? 'Confirm Deposit' : 'Authorise Payout',
          subtitle: subtitleMsg,
          onComplete: (pin) async {
            Navigator.pop(context);
            final koboAmount = CurrencyFormatter.nairaToKobo(nairaAmount);

            if (isFunding) {
              debugPrint('[WalletScreen] Initiating wallet funding. Amount (Kobo): $koboAmount');
              try {
                await _walletRepo.fundWallet(koboAmount);
                debugPrint('[WalletScreen] Wallet funding succeeded.');
                final newBal = _authCtrl.currentUser!.balanceKobo + koboAmount;
                _authCtrl.updateBalance(newBal);
                _showStatusSnackBar('Wallet credited successfully!', isError: false);
                _fetchHistory();
              } catch (e) {
                debugPrint('[WalletScreen] Wallet funding failed: $e');
                _showStatusSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
              }
            } else {
              if (payoutMethod != 'quidax' && _authCtrl.currentUser!.balanceKobo < koboAmount) {
                debugPrint('[WalletScreen] Transfer failed: Insufficient balance. Balance: ${_authCtrl.currentUser!.balanceKobo}, Attempted: $koboAmount');
                _showStatusSnackBar('Insufficient balance.', isError: true);
                return;
              }
              try {
                if (payoutMethod == 'internal') {
                  debugPrint('[WalletScreen] Initiating internal transfer. Amount (Kobo): $koboAmount, Recipient: $recipient');
                  await _walletRepo.transferFunds(koboAmount, recipient ?? 'Recipient', pin);
                  debugPrint('[WalletScreen] Internal transfer succeeded.');
                  final newBal = _authCtrl.currentUser!.balanceKobo - koboAmount;
                  _authCtrl.updateBalance(newBal);
                  _showStatusSnackBar('Payout transfer completed!', isError: false);
                } else if (payoutMethod == 'kora') {
                  debugPrint('[WalletScreen] Initiating bank payout via Kora. Amount (Kobo): $koboAmount, Bank: $bankCode, Account: $bankAccount');
                  await _walletRepo.initiateBankPayout(
                    bankCode: bankCode!,
                    accountNumber: bankAccount!,
                    accountName: accountName,
                    amountKobo: koboAmount,
                    pin: pin,
                  );
                  debugPrint('[WalletScreen] Bank payout via Kora succeeded.');
                  final newBal = _authCtrl.currentUser!.balanceKobo - koboAmount;
                  _authCtrl.updateBalance(newBal);
                  _showStatusSnackBar('Bank payout completed!', isError: false);
                } else if (payoutMethod == 'quidax') {
                  debugPrint('[WalletScreen] Initiating crypto withdrawal via Quidax. Currency: $cryptoCurrency, Amount (Naira): $nairaAmount, Fund UID: $fundUid');
                  await _walletRepo.initiateCryptoWithdrawal(
                    currency: cryptoCurrency!,
                    amount: nairaAmount,
                    fundUid: fundUid!,
                    pin: pin,
                  );
                  debugPrint('[WalletScreen] Crypto withdrawal via Quidax succeeded.');
                  final newBal = _authCtrl.currentUser!.balanceKobo - koboAmount;
                  _authCtrl.updateBalance(newBal);
                  _showStatusSnackBar('Crypto withdrawal initiated!', isError: false);
                }
                _fetchHistory();
              } catch (e) {
                debugPrint('[WalletScreen] Payout failed. Method: $payoutMethod. Error: $e');
                _showStatusSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
              }
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
