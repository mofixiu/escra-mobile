import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/controllers/escrow_controller.dart';
import '../../../shared/widgets/high_contrast_button.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _escrowCtrl = GetIt.I<EscrowController>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _currency = 'NGN';
  String? _deliveryMode;
  String? _salesChannel;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Image.asset(
          'assets/logos/escralogonobackground.png',
          height: 20,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New Escrow Order',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secure your transaction with our automated escrow vault.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Card 1: TRANSACTION PARTICULARS
                _buildSectionHeader('TRANSACTION PARTICULARS'),
                const SizedBox(height: 8),
                _buildCardGroup([
                  // ORDER TITLE
                  _buildLabel('ORDER TITLE'),
                  TextFormField(
                    controller: _titleCtrl,
                    style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
                    decoration: _inputDecoration('e.g. MacBook Pro M2'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // DESCRIPTION
                  _buildLabel('DESCRIPTION'),
                  TextFormField(
                    controller: _descCtrl,
                    style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 3,
                    decoration: _inputDecoration('Provide clear details about the item or service...'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // AMOUNT & CURRENCY
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('AMOUNT'),
                            TextFormField(
                              controller: _amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800),
                              decoration: _inputDecoration('0.00'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if ((double.tryParse(v) ?? 0) <= 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CURRENCY'),
                            DropdownButtonFormField<String>(
                              initialValue: _currency,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              menuMaxHeight: 300,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
                              decoration: _inputDecoration(''),
                              items: ['NGN', 'USD'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _currency = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                // Card 2: LOGISTICS & SALES ROUTE
                _buildSectionHeader('LOGISTICS & SALES ROUTE'),
                const SizedBox(height: 8),
                _buildCardGroup([
                  // DELIVERY MODE
                  _buildLabel('DELIVERY MODE'),
                  DropdownButtonFormField<String>(
                    initialValue: _deliveryMode,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    menuMaxHeight: 300,
                    hint: const Text('Select delivery option', style: TextStyle(color: Colors.black38, fontSize: 14)),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
                    decoration: _inputDecoration(''),
                    items: ['Digital Delivery', 'Physical Shipping', 'In-Person Meetup'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setState(() => _deliveryMode = v);
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // SALES CHANNEL
                  _buildLabel('SALES CHANNEL'),
                  DropdownButtonFormField<String>(
                    initialValue: _salesChannel,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    menuMaxHeight: 300,
                    hint: const Text('Where did you agree on this sale?', style: TextStyle(color: Colors.black38, fontSize: 14)),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
                    decoration: _inputDecoration(''),
                    items: ['Twitter/X', 'Instagram', 'Facebook', 'WhatsApp', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setState(() => _salesChannel = v);
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ]),
                const SizedBox(height: 24),

                // TERMS BLOCK (Modern Glassmorphic look)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: Colors.black26),
                          onChanged: (v) {
                            setState(() => _agreedToTerms = v ?? false);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.5, fontFamily: 'Montserrat'),
                            children: [
                              TextSpan(
                                text: 'Escrow Terms & Conditions',
                                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                              TextSpan(text: '. Funds will only be released upon mutual confirmation.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ListenableBuilder(
            listenable: _escrowCtrl,
            builder: (context, _) {
              return _escrowCtrl.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    )
                  : HighContrastButton(
                      text: 'GENERATE SECURE ESCROW',
                      onPressed: _agreedToTerms
                          ? () async {
                              if (!_formKey.currentState!.validate()) return;
                              final kobo = CurrencyFormatter.nairaToKobo(
                                double.parse(_amountCtrl.text),
                              );
                              final ok = await _escrowCtrl.createAgreement(
                                title: _titleCtrl.text.trim(),
                                amountKobo: kobo,
                                sellerEmail: 'seller@escra.com',
                                description: _descCtrl.text.trim(),
                              );
                              if (ok && context.mounted) Navigator.pop(context);
                            }
                          : null,
                    );
            },
          ),
        ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
