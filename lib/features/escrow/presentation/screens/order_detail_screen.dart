import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_parser.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../domain/controllers/escrow_controller.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
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
    debugPrint(
      '[OrderDetailScreen] Refreshing order details. Current Order ID: ${_order.id}',
    );
    setState(() => _isLoading = true);
    try {
      final updated = await _escrowCtrl.fetchOrderDetails(_order.id);
      debugPrint(
        '[OrderDetailScreen] Order details refreshed. Title: ${updated.title}, Status: ${updated.status}',
      );
      setState(() {
        _order = updated;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[OrderDetailScreen] Error refreshing order details: $e');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openShipSheet() {
    final trackingCtrl = TextEditingController();
    final proofCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                      'Dispatch & Ship Order',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: trackingCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Tracking Reference (e.g. DHL-123)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: proofCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Delivery Proof URL (Optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Note / Instructions (Optional)',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    debugPrint(
                      '[OrderDetailScreen] Initiating shipOrder. ID: ${_order.id}, Tracking: ${trackingCtrl.text.trim()}, Proof: ${proofCtrl.text.trim()}, Note: ${noteCtrl.text.trim()}',
                    );
                    final success = await _escrowCtrl.shipOrder(
                      _order.id,
                      trackingReference: trackingCtrl.text.trim().isEmpty
                          ? null
                          : trackingCtrl.text.trim(),
                      deliveryProofUrl: proofCtrl.text.trim().isEmpty
                          ? null
                          : proofCtrl.text.trim(),
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                    );
                    debugPrint(
                      '[OrderDetailScreen] shipOrder completed. success: $success',
                    );
                    if (success) {
                      _showSnackBar('Order marked as Shipped!', isError: false);
                    } else {
                      debugPrint(
                        '[OrderDetailScreen] shipOrder failed. Error: ${_escrowCtrl.errorMessage}',
                      );
                      _showSnackBar(
                        _escrowCtrl.errorMessage ?? 'Ship action failed.',
                        isError: true,
                      );
                    }
                    _refreshOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CONFIRM SHIPMENT'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDeliverSheet() {
    final proofCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                      'Mark Order Delivered',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: proofCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Delivery Proof URL (Optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Note / Comments (Optional)',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    debugPrint(
                      '[OrderDetailScreen] Initiating markOrderDelivered. ID: ${_order.id}, Proof: ${proofCtrl.text.trim()}, Note: ${noteCtrl.text.trim()}',
                    );
                    final success = await _escrowCtrl.markOrderDelivered(
                      _order.id,
                      deliveryProofUrl: proofCtrl.text.trim().isEmpty
                          ? null
                          : proofCtrl.text.trim(),
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                    );
                    debugPrint(
                      '[OrderDetailScreen] markOrderDelivered completed. success: $success',
                    );
                    if (success) {
                      _showSnackBar(
                        'Order marked as Delivered!',
                        isError: false,
                      );
                    } else {
                      debugPrint(
                        '[OrderDetailScreen] markOrderDelivered failed. Error: ${_escrowCtrl.errorMessage}',
                      );
                      _showSnackBar(
                        _escrowCtrl.errorMessage ?? 'Delivered action failed.',
                        isError: true,
                      );
                    }
                    _refreshOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CONFIRM DELIVERY'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCancelSheet() {
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                      'Cancel Order',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reason for cancellation (Optional)',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    debugPrint(
                      '[OrderDetailScreen] Initiating cancelOrder. ID: ${_order.id}, Reason: ${reasonCtrl.text.trim()}',
                    );
                    final success = await _escrowCtrl.cancelOrder(
                      _order.id,
                      reason: reasonCtrl.text.trim().isEmpty
                          ? null
                          : reasonCtrl.text.trim(),
                    );
                    debugPrint(
                      '[OrderDetailScreen] cancelOrder completed. success: $success',
                    );
                    if (success) {
                      _showSnackBar(
                        'Order cancelled successfully.',
                        isError: false,
                      );
                    } else {
                      debugPrint(
                        '[OrderDetailScreen] cancelOrder failed. Error: ${_escrowCtrl.errorMessage}',
                      );
                      _showSnackBar(
                        _escrowCtrl.errorMessage ?? 'Cancel action failed.',
                        isError: true,
                      );
                    }
                    _refreshOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CANCEL ORDER'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openRefundSheet() {
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                      'Issue Refund to Buyer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'This will refund the locked escrow amount back to the buyer wallet immediately.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reason for refund (Optional)',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    debugPrint(
                      '[OrderDetailScreen] Initiating refundOrder. ID: ${_order.id}, Reason: ${reasonCtrl.text.trim()}',
                    );
                    final success = await _escrowCtrl.refundOrder(
                      _order.id,
                      reason: reasonCtrl.text.trim().isEmpty
                          ? null
                          : reasonCtrl.text.trim(),
                    );
                    debugPrint(
                      '[OrderDetailScreen] refundOrder completed. success: $success',
                    );
                    if (success) {
                      _showSnackBar(
                        'Refund issued successfully!',
                        isError: false,
                      );
                    } else {
                      debugPrint(
                        '[OrderDetailScreen] refundOrder failed. Error: ${_escrowCtrl.errorMessage}',
                      );
                      _showSnackBar(
                        _escrowCtrl.errorMessage ?? 'Refund action failed.',
                        isError: true,
                      );
                    }
                    _refreshOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('ISSUE FULL REFUND'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authCtrl.currentUser;
    final isSeller =
        user != null &&
        user.role == UserRole.seller &&
        user.id == _order.sellerId;

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
          ),
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
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
                      _order.id.toUpperCase().startsWith('ESC-')
                          ? '#${_order.id.toUpperCase()}'
                          : '#ESC-${_order.id.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(_order.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(_order.status),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'AMOUNT SECURED IN ESCROW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            CurrencyFormatter.formatKobo(_order.amountKobo),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Funds are securely held by ESCRA and will only be released upon mutual confirmation of delivery.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Transaction Details Header
                    const Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 12),

                    // Transaction Details Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Buyer',
                            _order.buyerName,
                            subtitle: _order.buyerName == 'Buyer'
                                ? 'Awaiting checkout'
                                : 'Counterparty',
                          ),
                          const Divider(color: Colors.black12, height: 1),
                          _buildDetailRow(
                            'Seller',
                            _order.sellerName,
                            subtitle: 'Official Merchant',
                          ),
                          const Divider(color: Colors.black12, height: 1),
                          _buildDetailRow(
                            'Item',
                            _order.title,
                            subtitle: _order.description,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Lifecycle Tracking Header
                    const Text(
                      'Lifecycle Tracking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 12),

                    // Timeline Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          _buildTimelineItem(
                            title: 'Order Created',
                            time: DateParser.getRelativeTime(_order.createdAt),
                            isCompleted: true,
                            isLast: false,
                          ),
                          _buildTimelineItem(
                            title: 'Escrow Funded',
                            time:
                                _order.status.index >= EscrowStatus.funded.index
                                ? 'Confirmed'
                                : 'Pending',
                            isCompleted:
                                _order.status.index >=
                                EscrowStatus.funded.index,
                            isLast: false,
                          ),
                          _buildTimelineItem(
                            title: 'Shipped',
                            time:
                                _order.status.index >=
                                    EscrowStatus.delivered.index
                                ? 'Tracking ID available'
                                : 'Awaiting dispatch',
                            isCompleted:
                                _order.status.index >=
                                EscrowStatus.delivered.index,
                            isActive: _order.status == EscrowStatus.funded,
                            isLast: false,
                          ),
                          _buildTimelineItem(
                            title: 'Delivered',
                            time:
                                _order.status.index >=
                                    EscrowStatus.delivered.index
                                ? 'Pending Buyer Confirmation'
                                : 'Awaiting Delivery',
                            isCompleted:
                                _order.status.index >=
                                EscrowStatus.completed.index,
                            isActive: _order.status == EscrowStatus.delivered,
                            isLast: false,
                          ),
                          _buildTimelineItem(
                            title: 'Funds Released',
                            time: _order.status == EscrowStatus.completed
                                ? 'Completed'
                                : 'Awaiting Delivery',
                            isCompleted:
                                _order.status == EscrowStatus.completed,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomSheet: isSeller
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_order.status == EscrowStatus.pendingPayment) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openCancelSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CANCEL ORDER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            debugPrint(
                              '[OrderDetailScreen] Sharing public order link for order: ${_order.id}',
                            );
                            try {
                              var ref = _order.id;
                              if (!ref.toUpperCase().startsWith('ESC-')) {
                                ref = 'ESC-$ref';
                              }

                              final publicBase =
                                  AppConfig.publicOrderBaseUrl.isNotEmpty
                                  ? AppConfig.publicOrderBaseUrl
                                  : AppConfig.backendPublicOrderPreviewBase;
                              final publicUrl = '$publicBase/$ref';

                              final amount = CurrencyFormatter.formatKobo(
                                _order.amountKobo,
                              );
                              final message =
                                  '${_order.title} — $amount\n\nView & pay: $publicUrl';

                              await Share.share(
                                message,
                                subject: 'Pay for ${_order.title} on ESCRA',
                              );
                              _showSnackBar(
                                'Order link shared.',
                                isError: false,
                              );
                            } catch (e) {
                              debugPrint(
                                '[OrderDetailScreen] Error sharing order link: $e',
                              );
                              _showSnackBar(
                                'Failed to share order link.',
                                isError: true,
                              );
                            } finally {
                              setState(() => _isLoading = false);
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
                          child: const Text(
                            'SHARE ORDER LINK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else if (_order.status == EscrowStatus.funded) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openShipSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'MARK SHIPPED',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openDeliverSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'MARK DELIVERED',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openRefundSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'REFUND',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else if (_order.status == EscrowStatus.delivered) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openRefundSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'REFUND',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Expanded(
                        child: Text(
                          'No further actions available for this order state.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
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
                    color: isCompleted
                        ? Colors.black
                        : (isActive ? Colors.black : Colors.black12),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : (isActive
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.black12,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isActive
                          ? Colors.black
                          : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCompleted || isActive
                          ? Colors.black54
                          : Colors.black26,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
