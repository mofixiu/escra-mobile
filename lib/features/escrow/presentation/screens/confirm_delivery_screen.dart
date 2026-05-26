import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import '../../../shared/widgets/custom_pin_pad.dart';
import 'buyer_order_details_screen.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../auth/data/models/user_model.dart';

class ConfirmDeliveryScreen extends StatefulWidget {
  final OrderModel order;

  const ConfirmDeliveryScreen({super.key, required this.order});

  @override
  State<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends State<ConfirmDeliveryScreen> {
  final _escrowCtrl = GetIt.I<EscrowController>();
  String _enteredCode = '';

  void _onCodeComplete(String code) {
    setState(() {
      _enteredCode = code;
    });
  }

  Future<void> _submitConfirmation() async {
    // Escrow confirmation logic
    await _escrowCtrl.updateStatus(widget.order.id, EscrowStatus.completed);
    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BuyerOrderDetailsScreen(order: widget.order.copyWith(status: EscrowStatus.completed))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = GetIt.I<AuthController>();
    final user = authCtrl.currentUser;
    final canBuyerAct = user != null && user.role == UserRole.buyer && user.id == widget.order.buyerId;
    final isCodeValid = _enteredCode.length == 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DELIVERY_PENDING_CONFIRMATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Confirm Delivery',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter the 4-digit code provided by the seller to release funds from escrow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: Color(0xFFD32F2F)),
                        SizedBox(width: 8),
                        Text(
                          'Auto-release in 23h 45m',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                    if (!canBuyerAct) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3F3),
                          border: Border.all(color: const Color(0xFFD32F2F)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Only the buyer can confirm delivery or open a dispute for this order.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    
                    // Pin Pad
                    IgnorePointer(
                      ignoring: !canBuyerAct,
                      child: CustomPinPad(
                        isInline: true,
                        pinLength: 4,
                        onComplete: _onCodeComplete,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Transaction Summary Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Transaction ID', style: TextStyle(color: Colors.black54, fontSize: 13)),
                              const Text('#ESC-8924-VL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Escrow Amount', style: TextStyle(color: Colors.black54, fontSize: 14)),
                              Text(
                                CurrencyFormatter.formatKobo(widget.order.amountKobo),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: canBuyerAct && isCodeValid ? _submitConfirmation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canBuyerAct && isCodeValid ? Colors.black : Colors.black12,
                        foregroundColor: canBuyerAct && isCodeValid ? Colors.white : Colors.black38,
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: const Text(
                        'Confirm Delivery & Release\nFunds',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (canBuyerAct)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Goes back to order details where Open Dispute is available
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        icon: const Icon(Icons.gavel_outlined, size: 18),
                        label: const Text(
                          'Open Dispute',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),

                    const SizedBox(height: 32),
                    const Text(
                      'By confirming, you agree the item was received as described. This action is irreversible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
