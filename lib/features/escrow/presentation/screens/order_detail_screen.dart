import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_parser.dart';
import '../../data/models/order_model.dart';


class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

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
        return 'DELIVERY PENDING CONFIRMATION';
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

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              '#ESC-${order.id.substring(0, 5).toUpperCase()}',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      color: _getStatusColor(order.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(order.status),
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
                    CurrencyFormatter.formatKobo(order.amountKobo),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Buyer', '@${order.buyerName.toLowerCase().replaceAll(' ', '_')}', subtitle: '★ 4.9 (120 tx)'),
                  const Divider(color: Colors.black12, height: 1),
                  _buildDetailRow('Seller', order.sellerName, subtitle: 'Official Merchant'),
                  const Divider(color: Colors.black12, height: 1),
                  _buildDetailRow('Item', order.title, subtitle: order.description),
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
                    time: DateParser.getRelativeTime(order.createdAt), // Simulated for demo
                    isCompleted: true,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Escrow Funded',
                    time: order.status.index >= EscrowStatus.funded.index ? 'Confirmed' : 'Pending',
                    isCompleted: order.status.index >= EscrowStatus.funded.index,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Shipped',
                    time: order.status.index >= EscrowStatus.delivered.index ? 'Tracking ID available' : 'Awaiting dispatch',
                    isCompleted: order.status.index >= EscrowStatus.delivered.index,
                    isActive: order.status == EscrowStatus.funded,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Delivered',
                    time: order.status.index >= EscrowStatus.delivered.index ? 'Pending Buyer Confirmation' : 'Awaiting Delivery',
                    isCompleted: order.status.index >= EscrowStatus.completed.index,
                    isActive: order.status == EscrowStatus.delivered,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Funds Released',
                    time: order.status == EscrowStatus.completed ? 'Completed' : 'Awaiting Delivery',
                    isCompleted: order.status == EscrowStatus.completed,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
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
          // Indicator column
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.black : (isActive ? Colors.white : Colors.white),
                  border: Border.all(
                    color: isCompleted ? Colors.black : (isActive ? Colors.black : Colors.black12),
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
                              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
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
          // Content column
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
                      color: isCompleted || isActive ? Colors.black : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCompleted || isActive ? Colors.black54 : Colors.black26,
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
