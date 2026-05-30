import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';
import '../../data/models/merchant_profile_store.dart';

/// Premium visual Payout Settings Screen for Sellers.
/// Fully dynamic bank registration bottom-sheet simulator with dynamic account-name resolver.
class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  final _profileStore = MerchantProfileStore();

  @override
  void initState() {
    super.initState();
    _profileStore.addListener(_rebuild);
  }

  @override
  void dispose() {
    _profileStore.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Mask account number for premium security look
    final maskAcct = _profileStore.accountNumber.length >= 10
        ? '${_profileStore.accountNumber.substring(0, 4)} •••• •••• ${_profileStore.accountNumber.substring(8)}'
        : _profileStore.accountNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payout Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Dynamic Premium Bank Card Visual
          Container(
            height: 200,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _profileStore.bankName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Icon(
                      Icons.contactless_outlined,
                      color: Colors.white30,
                      size: 24,
                    ),
                  ],
                ),
                Text(
                  maskAcct,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCOUNT HOLDER',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profileStore.accountName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_rounded, color: AppColors.success, size: 10),
                          SizedBox(width: 4),
                          Text(
                            'PRIMARY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Payout Frequency Section
          _buildSectionHeader('PAYOUT SCHEDULE FREQUENCY'),
          const SizedBox(height: 12),
          const Text(
            'Choose how rapidly your settled trade escrows clear into your primary settlement bank account.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Toggle Buttons
          Row(
            children: [
              Expanded(
                child: _buildFrequencyButton(
                  label: 'Instant',
                  subtitle: 'Immediate settle',
                  value: 'Instant',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFrequencyButton(
                  label: 'Daily',
                  subtitle: '12:00 AM daily',
                  value: 'Daily',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFrequencyButton(
                  label: 'Weekly',
                  subtitle: 'Every Monday',
                  value: 'Weekly',
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Settlement Bank Details Section
          _buildSectionHeader('SETTLEMENT DETAILS'),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildBankDetailsRow('Settlement Bank', _profileStore.bankName),
            _buildBankDetailsRow('Account Number', _profileStore.accountNumber),
            _buildBankDetailsRow('Account Name', _profileStore.accountName),
            _buildBankDetailsRow('Settlement Currency', 'NGN (₦)'),
          ]),
          const SizedBox(height: 36),

          // Link New Account Action
          HighContrastButton(
            text: 'LINK NEW SETTLEMENT ACCOUNT',
            onPressed: () => _openLinkBankSheet(context),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.secondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppColors.border),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildBankDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton({
    required String label,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _profileStore.payoutFrequency == value;

    return InkWell(
      onTap: () {
        _profileStore.updatePayoutFrequency(value);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white54 : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLinkBankSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _LinkBankSheet();
      },
    );
  }
}

/// Simulated Bank account validation bottom sheet.
/// Triggers a mock API resolution when 10 digits are inputted.
class _LinkBankSheet extends StatefulWidget {
  const _LinkBankSheet();

  @override
  State<_LinkBankSheet> createState() => _LinkBankSheetState();
}

class _LinkBankSheetState extends State<_LinkBankSheet> {
  final _profileStore = MerchantProfileStore();
  final _acctController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedBank;
  bool _isResolving = false;
  String? _resolvedName;

  @override
  void initState() {
    super.initState();
    _acctController.addListener(_onAccountNumberChanged);
  }

  @override
  void dispose() {
    _acctController.removeListener(_onAccountNumberChanged);
    _acctController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged() {
    final text = _acctController.text.trim();
    if (text.length == 10 && _selectedBank != null) {
      _resolveAccountName();
    } else {
      if (_resolvedName != null) {
        setState(() {
          _resolvedName = null;
        });
      }
    }
  }

  Future<void> _resolveAccountName() async {
    setState(() {
      _isResolving = true;
      _resolvedName = null;
    });

    // Simulate NIBSS bank resolver API delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isResolving = false;
        _resolvedName = _profileStore.businessName.toUpperCase();
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate() || _selectedBank == null || _resolvedName == null) {
      return;
    }

    _profileStore.updatePayoutSettings(
      bank: _selectedBank!,
      account: _acctController.text.trim(),
      name: _resolvedName!,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Settlement account updated successfully!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Link Settlement Bank',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Add secondary settlement channels for clearing completed escrow disbursements.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                initialValue: _selectedBank,
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
                items: _profileStore.mockBanks.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank['name'],
                    child: Text(bank['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBank = val;
                  });
                  // Trigger resolution if account number was already typed
                  if (_acctController.text.trim().length == 10) {
                    _resolveAccountName();
                  }
                },
                validator: (val) => val == null ? 'Please select a bank' : null,
              ),
              const SizedBox(height: 16),

              // Account Number Input
              TextFormField(
                controller: _acctController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Account Number',
                  prefixIcon: const Icon(Icons.account_balance_rounded, size: 18, color: Colors.black54),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black, width: 1.2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (val.trim().length != 10) return 'Must be exactly 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account verification resolver spinner / results
              if (_isResolving)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resolving Account Name...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_resolvedName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _resolvedName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              HighContrastButton(
                text: 'LINK ACCOUNT',
                onPressed: _resolvedName != null ? _handleSubmit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
