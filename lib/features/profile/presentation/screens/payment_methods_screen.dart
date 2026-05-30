import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';

/// Luxury high-fidelity Card Funding Payment Methods Screen for Buyers.
/// Features a live-updating interactive premium obsidian visual credit card.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Live credit card fields
  String _cardNumber = '•••• •••• •••• ••••';
  String _cardHolder = 'ALEX CHEN';
  String _expiryDate = '12/28';

  final List<Map<String, String>> _savedCards = [
    {
      'type': 'Visa Gold Debit',
      'last4': '4920',
      'expiry': '10/27',
      'holder': 'ALEX CHEN',
    },
    {
      'type': 'Mastercard Premium',
      'last4': '9820',
      'expiry': '04/29',
      'holder': 'ALEX CHEN',
    },
  ];

  void _openAddCardSheet() {
    final formKey = GlobalKey<FormState>();
    final cardNoCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    // Setup local listeners to update visual card live
    cardNoCtrl.addListener(() {
      setState(() {
        if (cardNoCtrl.text.isEmpty) {
          _cardNumber = '•••• •••• •••• ••••';
        } else {
          // Format with spaces
          final text = cardNoCtrl.text.replaceAll(' ', '');
          final buffer = StringBuffer();
          for (int i = 0; i < text.length; i++) {
            if (i > 0 && i % 4 == 0) {
              buffer.write(' ');
            }
            buffer.write(text[i]);
          }
          _cardNumber = buffer.toString();
        }
      });
    });

    holderCtrl.addListener(() {
      setState(() {
        _cardHolder = holderCtrl.text.isEmpty ? 'CARD HOLDER' : holderCtrl.text.toUpperCase();
      });
    });

    expiryCtrl.addListener(() {
      setState(() {
        _expiryDate = expiryCtrl.text.isEmpty ? 'MM/YY' : expiryCtrl.text;
      });
    });

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
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'LINK SECURE VAULT CARD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.8,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Inputs
                    _buildLabel('CARD NUMBER'),
                    TextFormField(
                      controller: cardNoCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: _sheetInputDecoration('e.g. 5238 9201 2390 8820'),
                      validator: (v) => (v == null || v.length < 16) ? 'Invalid card number' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('CARD HOLDER NAME'),
                    TextFormField(
                      controller: holderCtrl,
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: _sheetInputDecoration('e.g. Alex Chen'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('EXPIRY DATE'),
                              TextFormField(
                                controller: expiryCtrl,
                                keyboardType: TextInputType.datetime,
                                maxLength: 5,
                                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                decoration: _sheetInputDecoration('MM/YY'),
                                validator: (v) => (v == null || v.length != 5) ? 'Invalid' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('CVV CODE'),
                              TextFormField(
                                controller: cvvCtrl,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 3,
                                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                decoration: _sheetInputDecoration('•••'),
                                validator: (v) => (v == null || v.length != 3) ? 'Invalid' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    HighContrastButton(
                      text: 'SAVE AND AUTHORIZE CARD',
                      icon: Icons.credit_card_rounded,
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        
                        setState(() {
                          _savedCards.add({
                            'type': 'Visa Credit',
                            'last4': cardNoCtrl.text.substring(12),
                            'expiry': expiryCtrl.text,
                            'holder': holderCtrl.text.toUpperCase(),
                          });
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 12),
                                Text('Card authorized and linked successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // Revert temporary visual display card back to generic state if not saved
      setState(() {
        _cardNumber = '•••• •••• •••• ••••';
        _cardHolder = 'ALEX CHEN';
        _expiryDate = '12/28';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Payment Methods',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // DYNAMIC PREMIUM LIVE CARD
            Container(
              height: 200,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // Sleek obsidian / luxury metallic titanium gradient
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
                      const Text(
                        'ESCRA VAULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.contactless_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  
                  // Live Number
                  Text(
                    _cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _cardHolder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // SAVED SYSTEM CARDS LIST
            _buildSectionHeader('SAVED TRANSACTION FUNDING CARDS'),
            const SizedBox(height: 8),
            _buildCardGroup(
              List.generate(_savedCards.length, (i) {
                final card = _savedCards[i];
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.credit_card_rounded, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card['type']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '•••• •••• •••• ${card['last4']!} • Exp: ${card['expiry']!}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          onPressed: () {
                            setState(() {
                              _savedCards.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                    if (i != _savedCards.length - 1)
                      const Divider(height: 24, color: AppColors.border),
                  ],
                );
              }),
            ),
            const SizedBox(height: 36),

            HighContrastButton(
              text: 'LINK NEW SECURE CARD',
              icon: Icons.add_rounded,
              onPressed: _openAddCardSheet,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: AppColors.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  InputDecoration _sheetInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }
}
