import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../shared/widgets/custom_pin_pad.dart';
import 'order_detail_screen.dart';

class FundEscrowScreen extends StatefulWidget {
  final OrderModel order;

  const FundEscrowScreen({super.key, required this.order});

  @override
  State<FundEscrowScreen> createState() => _FundEscrowScreenState();
}

class _FundEscrowScreenState extends State<FundEscrowScreen> {
  final _escrowCtrl = GetIt.I<EscrowController>();
  final _authCtrl = GetIt.I<AuthController>();
  String _enteredPin = '';

  void _onPinComplete(String pin) {
    setState(() {
      _enteredPin = pin;
    });
  }

  Future<void> _submitFunding() async {
    // In a real app, verify PIN securely
    await _escrowCtrl.updateStatus(widget.order.id, EscrowStatus.funded);
    if (!mounted) return;
    
    // Navigate back to dashboard and refresh, or show success
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: widget.order.copyWith(status: EscrowStatus.funded))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _authCtrl.currentUser?.balanceKobo ?? 150000000; // Mock balance or real
    final isPinValid = _enteredPin.length == 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ESCRA',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Fund Escrow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Authorize transaction to secure funds.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            
            // Balances
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Wallet Balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatKobo(balance),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount Due',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatKobo(widget.order.amountKobo),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Custom Pin Pad (Inline)
            CustomPinPad(
              isInline: true,
              onComplete: _onPinComplete,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: isPinValid ? _submitFunding : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPinValid ? Colors.black : Colors.black12,
              foregroundColor: isPinValid ? Colors.white : Colors.black38,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirm Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
