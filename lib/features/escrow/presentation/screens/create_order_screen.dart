import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/controllers/escrow_controller.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light off-white background from screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'ESCRA',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
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
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secure your transaction with our automated escrow vault.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // ORDER TITLE
                _buildLabel('ORDER TITLE'),
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: _inputDecoration('e.g. MacBook Pro M2'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
                // DESCRIPTION
                _buildLabel('DESCRIPTION'),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 4,
                  decoration: _inputDecoration('Provide clear details about the item or service...'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
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
                            style: const TextStyle(color: Colors.black, fontSize: 16),
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
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CURRENCY'),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                            style: const TextStyle(color: Colors.black, fontSize: 16),
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
                const SizedBox(height: 24),
                
                // DELIVERY MODE
                _buildLabel('DELIVERY MODE'),
                DropdownButtonFormField<String>(
                  initialValue: _deliveryMode,
                  hint: const Text('Select delivery option', style: TextStyle(color: Colors.black54)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: _inputDecoration(''),
                  items: ['Digital Delivery', 'Physical Shipping', 'In-Person Meetup'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() => _deliveryMode = v);
                  },
                ),
                const SizedBox(height: 24),
                
                // SALES CHANNEL
                _buildLabel('SALES CHANNEL'),
                DropdownButtonFormField<String>(
                  initialValue: _salesChannel,
                  hint: const Text('Where did you agree on this sale?', style: TextStyle(color: Colors.black54)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: _inputDecoration(''),
                  items: ['Twitter/X', 'Instagram', 'Facebook', 'WhatsApp', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() => _salesChannel = v);
                  },
                ),
                const SizedBox(height: 24),
                
                // TERMS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    border: Border.all(color: Colors.black12, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: Colors.black,
                          side: const BorderSide(color: Colors.black26),
                          onChanged: (v) {
                            setState(() => _agreedToTerms = v ?? false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                            children: [
                              TextSpan(
                                text: 'Escrow Terms & Conditions',
                                style: TextStyle(decoration: TextDecoration.underline),
                              ),
                              TextSpan(text: '. Funds will only be released upon mutual confirmation.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListenableBuilder(
            listenable: _escrowCtrl,
            builder: (context, _) {
              return ElevatedButton(
                onPressed: (_agreedToTerms && !_escrowCtrl.isLoading)
                    ? () async {
                        if (!_formKey.currentState!.validate()) return;
                        final kobo = CurrencyFormatter.nairaToKobo(
                          double.parse(_amountCtrl.text),
                        );
                        // For mock purposes, default to a dummy seller email if not provided
                        final ok = await _escrowCtrl.createAgreement(
                          title: _titleCtrl.text.trim(),
                          amountKobo: kobo,
                          sellerEmail: 'seller@escra.com', // In a real app we'd ask for this
                          description: _descCtrl.text.trim(),
                        );
                        if (ok && context.mounted) Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: _escrowCtrl.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'GENERATE ESCROW ORDER',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.black12, width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.black12, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }
}
