import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import 'buyer_order_details_screen.dart';
import '../../../auth/domain/auth_controller.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final escrowCtrl = GetIt.I<EscrowController>();
    final authCtrl = GetIt.I<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Transactions',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: escrowCtrl,
        builder: (context, _) {
          final user = authCtrl.currentUser;
          
          return CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search orders or merchants...',
                            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Icon(Icons.tune, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              // Mock Month Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'RECENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              if (escrowCtrl.isLoading && escrowCtrl.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Colors.black)),
                )
              else if (escrowCtrl.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = escrowCtrl.orders[index];
                        final isMyBuyerOrder = order.buyerId == user?.id;
                        
                        return _TransactionCard(
                          order: order,
                          isBuyer: isMyBuyerOrder,
                          onTap: () {
                            if (isMyBuyerOrder) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BuyerOrderDetailsScreen(order: order)),
                              ).then((_) => escrowCtrl.fetchOrders());
                            } else {
                              // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seller details coming soon')));
                            }
                          },
                        );
                      },
                      childCount: escrowCtrl.orders.length,
                    ),
                  ),
                ),

              // Escrow Protection Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Escrow Protection Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'All your funds are secured in a multi-signature vault until you confirm delivery.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.verified_user,
                          color: Colors.white.withValues(alpha: 0.1),
                          size: 64,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Contact Support
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.support_agent, size: 32, color: Colors.black),
                        const SizedBox(height: 12),
                        const Text(
                          'Need help with an order?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final OrderModel order;
  final bool isBuyer;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.order,
    required this.isBuyer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor() {
      switch (order.status) {
        case EscrowStatus.completed: return Colors.black;
        case EscrowStatus.delivered: return Colors.white; // "IN ESCROW"
        case EscrowStatus.disputed: return const Color(0xFFD32F2F); // Red
        case EscrowStatus.pendingPayment:
        case EscrowStatus.funded: return Colors.black12;
        case EscrowStatus.refunded: return Colors.black12;
      }
    }

    Color getStatusTextColor() {
      switch (order.status) {
        case EscrowStatus.completed: return Colors.white;
        case EscrowStatus.delivered: return Colors.black; // "IN ESCROW"
        case EscrowStatus.disputed: return Colors.white;
        case EscrowStatus.pendingPayment:
        case EscrowStatus.funded: return Colors.black54;
        case EscrowStatus.refunded: return Colors.black54;
      }
    }

    String getStatusText() {
      switch (order.status) {
        case EscrowStatus.completed: return 'COMPLETED';
        case EscrowStatus.delivered: return 'IN ESCROW';
        case EscrowStatus.disputed: return 'DISPUTED';
        case EscrowStatus.pendingPayment: return 'PENDING';
        case EscrowStatus.funded: return 'FUNDED';
        case EscrowStatus.refunded: return 'REFUNDED';
      }
    }

    IconData getIcon() {
      switch (order.status) {
        case EscrowStatus.completed: return Icons.shopping_bag_outlined;
        case EscrowStatus.delivered: return Icons.lock_outline;
        case EscrowStatus.disputed: return Icons.error_outline;
        default: return Icons.access_time;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(getIcon(), color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuyer ? '@${order.sellerName.toLowerCase().replaceAll(' ', '_')}' : '@${order.buyerName.toLowerCase().replaceAll(' ', '_')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oct 24, 2023 • 14:32', // Mock date for now
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatKobo(order.amountKobo),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(4),
                    border: order.status == EscrowStatus.delivered 
                        ? Border.all(color: Colors.black12)
                        : null,
                  ),
                  child: Text(
                    getStatusText(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: getStatusTextColor(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
