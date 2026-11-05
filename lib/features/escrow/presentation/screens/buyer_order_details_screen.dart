import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_parser.dart';
import '../../../../core/utils/escra_router.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../shared/widgets/custom_pin_pad.dart';
import '../../data/models/order_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import 'confirm_delivery_screen.dart';
import 'open_dispute_screen.dart';

class BuyerOrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const BuyerOrderDetailsScreen({super.key, required this.order});

  @override
  State<BuyerOrderDetailsScreen> createState() => _BuyerOrderDetailsScreenState();
}

class _BuyerOrderDetailsScreenState extends State<BuyerOrderDetailsScreen> {
  final _escrowCtrl = GetIt.I<EscrowController>();
  final _authCtrl = GetIt.I<AuthController>();
  late OrderModel _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    debugPrint('[BuyerOrderDetailsScreen] Refreshing order details. Current Order ID: ${_order.id}');
    setState(() => _isLoading = true);
    try {
      final updated = await _escrowCtrl.fetchOrderDetails(_order.id);
      debugPrint('[BuyerOrderDetailsScreen] Order details refreshed. Title: ${updated.title}, Status: ${updated.status}');
      setState(() {
        _order = updated;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[BuyerOrderDetailsScreen] Error refreshing order details: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(EscrowStatus status) {
    if (status == EscrowStatus.completed) return Colors.green;
    if (status == EscrowStatus.delivered) return Colors.blue;
    if (status == EscrowStatus.disputed) return Colors.red;
    return Colors.black54;
  }

  String _getStatusText(EscrowStatus status) {
    switch (status) {
      case EscrowStatus.pendingPayment:
        return 'AWAITING PAYMENT';
      case EscrowStatus.funded:
        return 'AWAITING DISPATCH / DELIVERY';
      case EscrowStatus.delivered:
        return 'DELIVERED (PENDING RELEASE)';
      case EscrowStatus.completed:
        return 'FUNDS RELEASED';
      case EscrowStatus.disputed:
        return 'DISPUTED';
      case EscrowStatus.refunded:
        return 'REFUNDED';
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openPinPadForWalletFunding() {
    final balance = _authCtrl.currentUser?.balanceKobo ?? 0;
    if (balance < _order.amountKobo) {
      _showSnackBar(
        'Insufficient wallet balance. Please fund your wallet or pay directly with card/bank.',
        isError: true,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomPinPad(
          title: 'Confirm Payment',
          subtitle: 'Pay ${CurrencyFormatter.formatKobo(_order.amountKobo)} from wallet balance',
          onComplete: (pin) async {
            Navigator.pop(context);
            setState(() => _isLoading = true);
            debugPrint('[BuyerOrderDetailsScreen] Funding escrow from wallet. Order ID: ${_order.id}');
            final ok = await _escrowCtrl.updateStatus(
              _order.id,
              EscrowStatus.funded,
              pin: pin,
            );
            debugPrint('[BuyerOrderDetailsScreen] Wallet funding completed. success: $ok, error: ${_escrowCtrl.errorMessage}');
            if (ok) {
              _showSnackBar('Escrow order funded successfully!', isError: false);
            } else {
              _showSnackBar(_escrowCtrl.errorMessage ?? 'Payment failed.', isError: true);
            }
            _refreshOrder();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BuyerOrderDetailsScreen] Rebuilding screen. Order ID: ${_order.id}, Reference: #ESC-${_order.id.toUpperCase()}, Status: ${_order.status}');
    final user = _authCtrl.currentUser;
    final canBuyerAct = user != null && user.role == UserRole.buyer && user.id == _order.buyerId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              onRefresh: _refreshOrder,
              color: Colors.white,
              backgroundColor: Colors.black,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    const Text(
                      'ESCROW TRANSACTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order.id.toUpperCase().startsWith('ESC-')
                          ? 'Order #${_order.id.toUpperCase()}'
                          : 'Order #ESC-${_order.id.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_order.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(_order.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          CurrencyFormatter.formatKobo(_order.amountKobo),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 24),

                    // Carrier/Payment Status Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _order.status == EscrowStatus.pendingPayment
                                      ? Icons.payment_outlined
                                      : Icons.local_shipping_outlined,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _order.status == EscrowStatus.pendingPayment
                                          ? 'Payment Status'
                                          : 'Delivery Status',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _order.status == EscrowStatus.pendingPayment
                                          ? 'Awaiting Funding'
                                          : 'In Transit',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _order.status == EscrowStatus.pendingPayment
                                          ? 'Please fund this escrow order to alert the seller to prepare dispatch.'
                                          : 'Funds are securely locked in the Escrow vault awaiting shipping completion.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
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
                    const SizedBox(height: 16),

                    // Item Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Item Description',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.black12, height: 1),
                          const SizedBox(height: 16),
                          Text(
                            _order.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _order.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Parties
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Parties',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.black12, height: 1),
                          const SizedBox(height: 16),
                          const Text(
                            'Seller',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _order.sellerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Buyer',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _order.buyerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Transaction Timeline
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Timeline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black12, height: 1),
                          const SizedBox(height: 24),
                          _buildTimelineItem(
                            title: 'Order Created',
                            subtitle: DateParser.getRelativeTime(_order.createdAt),
                            isCompleted: true,
                            isLast: false,
                          ),
                          _buildTimelineItem(
                            title: 'Funds Secured in Escrow',
                            subtitle: _order.status.index >= EscrowStatus.funded.index ? 'Confirmed' : 'Pending',
                            isCompleted: _order.status.index >= EscrowStatus.funded.index,
                            isCurrent: _order.status == EscrowStatus.pendingPayment,
                            isLast: false,
                            badge: _order.status.index >= EscrowStatus.funded.index
                                ? Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${CurrencyFormatter.formatKobo(_order.amountKobo)} Locked',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          _buildTimelineItem(
                            title: 'Item Shipped',
                            subtitle: _order.status.index >= EscrowStatus.funded.index
                                ? (_order.status.index >= EscrowStatus.delivered.index ? 'Shipped' : 'Awaiting dispatch')
                                : 'Pending',
                            isCompleted: _order.status.index >= EscrowStatus.delivered.index,
                            isCurrent: _order.status == EscrowStatus.funded,
                            isLast: false,
                          ),
                          _buildTimelineItem(
                            title: 'Delivery & Inspection',
                            subtitle: _order.status.index >= EscrowStatus.delivered.index
                                ? (_order.status.index >= EscrowStatus.completed.index ? 'Delivered' : 'In inspection window')
                                : 'Pending',
                            isCompleted: _order.status.index >= EscrowStatus.completed.index,
                            isCurrent: _order.status == EscrowStatus.delivered,
                            isLast: false,
                            description: '48-hour inspection period begins upon delivery.',
                          ),
                          _buildTimelineItem(
                            title: 'Funds Released',
                            subtitle: _order.status == EscrowStatus.completed ? 'Completed' : 'Pending',
                            isCompleted: _order.status == EscrowStatus.completed,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F7),
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: SafeArea(
          child: canBuyerAct
              ? (_order.status == EscrowStatus.pendingPayment
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _openPinPadForWalletFunding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.black),
                              ),
                            ),
                            child: const Text(
                              'PAY FROM WALLET',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              debugPrint('[BuyerOrderDetailsScreen] Initiating Kora checkout for order: ${_order.id}');
                              try {
                                final checkoutUrl = await _escrowCtrl.startCheckout(_order.id);
                                if (checkoutUrl != null) {
                                  debugPrint('[BuyerOrderDetailsScreen] Checkout URL: $checkoutUrl');
                                  final uri = Uri.parse(checkoutUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                                  } else {
                                    throw 'Could not launch payment URL';
                                  }
                                } else {
                                  _showSnackBar(_escrowCtrl.errorMessage ?? 'Checkout failed.', isError: true);
                                }
                              } catch (e) {
                                _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
                              } finally {
                                setState(() => _isLoading = false);
                                _refreshOrder();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text(
                              'PAY WITH CARD (KORA)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  : (_order.status == EscrowStatus.funded || _order.status == EscrowStatus.delivered
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  EscraRouter.push(
                                    context,
                                    OpenDisputeScreen(order: _order),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.black),
                                  ),
                                ),
                                child: const Text(
                                  'OPEN DISPUTE',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  EscraRouter.push(
                                    context,
                                    ConfirmDeliveryScreen(order: _order),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.verified_user_outlined, size: 16),
                                label: const Text(
                                  'CONFIRM DELIVERY',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Text(
                            'No further actions available for this order state.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                        )))
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Text(
                    'Only the buyer can confirm delivery, fund, or open a dispute for this order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isCurrent = false,
    required bool isLast,
    Widget? badge,
    String? description,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isCurrent || isCompleted ? Colors.black : Colors.black26,
                    width: isCurrent ? 4 : 1,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isCurrent
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: isCompleted || isCurrent ? Colors.black26 : Colors.black12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCompleted || isCurrent ? Colors.black : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted || isCurrent ? Colors.black87 : Colors.black45,
                    ),
                  ),
                  // ignore: use_null_aware_elements
                  if (badge != null) badge,
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted || isCurrent ? Colors.black87 : Colors.black38,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
