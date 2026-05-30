import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import 'buyer_order_details_screen.dart';
import '../../../../core/utils/escra_router.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../auth/data/models/user_model.dart';

class OpenDisputeScreen extends StatefulWidget {
  final OrderModel order;

  const OpenDisputeScreen({super.key, required this.order});

  @override
  State<OpenDisputeScreen> createState() => _OpenDisputeScreenState();
}

class _OpenDisputeScreenState extends State<OpenDisputeScreen> {
  final _escrowCtrl = GetIt.I<EscrowController>();
  String? _selectedReason;

  final List<String> _reasons = [
    'Item not received',
    'Item not as described',
    'Counterfeit item',
    'Damaged during shipping',
  ];

  Future<void> _submitDispute() async {
    if (_selectedReason == null) return;
    
    await _escrowCtrl.updateStatus(widget.order.id, EscrowStatus.disputed);
    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
    EscraRouter.push(
      context,
      BuyerOrderDetailsScreen(order: widget.order.copyWith(status: EscrowStatus.disputed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = GetIt.I<AuthController>();
    final user = authCtrl.currentUser;
    final canBuyerAct = user != null && user.role == UserRole.buyer && user.id == widget.order.buyerId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Open Dispute',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'ESCRA',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!canBuyerAct) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  border: Border.all(color: const Color(0xFFD32F2F)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Only the buyer can open a dispute for this order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER REFERENCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#ESC-8924-VL',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'ESCROW AMOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatKobo(widget.order.amountKobo),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Reason
            const Text(
              'SELECT REASON',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: _reasons.map((reason) {
                  return Column(
                    children: [
                      // ignore: deprecated_member_use
                      RadioListTile<String>(
                        value: reason,
                        // ignore: deprecated_member_use
                        groupValue: _selectedReason,
                        // ignore: deprecated_member_use
                        onChanged: canBuyerAct
                            ? (value) {
                                setState(() => _selectedReason = value);
                              }
                            : null,
                        title: Text(
                          reason,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        activeColor: Colors.black,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (reason != _reasons.last) const Divider(height: 1, color: Colors.black12),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Evidence Upload
            const Text(
              'EVIDENCE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26, style: BorderStyle.solid), // Should be dashed, but using solid for standard Flutter without extra deps
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.black54),
                  const SizedBox(height: 12),
                  const Text(
                    'Attach Photos/Videos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PNG, JPG or MP4 (Max 50MB)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'DESCRIPTION OF ISSUE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Provide detailed information regarding the dispute...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                border: const Border(left: BorderSide(color: Colors.black, width: 4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, size: 18, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'The ', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
                          TextSpan(text: 'ESCRA Trust Team ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold, height: 1.4)),
                          TextSpan(
                            text: 'will review this case within 24-48 hours. Funds will remain securely locked in escrow until a resolution is reached or both parties agree to a settlement.',
                            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            ElevatedButton(
              onPressed: canBuyerAct && _selectedReason != null ? _submitDispute : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canBuyerAct && _selectedReason != null ? Colors.black : Colors.black12,
                foregroundColor: canBuyerAct && _selectedReason != null ? Colors.white : Colors.black38,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SUBMIT DISPUTE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.send, size: 14),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL AND RETURN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
