import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart';
import '../../../../core/utils/escra_router.dart';

/// Seller Dashboard & Order List
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final escrowCtrl = GetIt.I<EscrowController>();
    final authCtrl = GetIt.I<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/logos/escralogonobackground.png',
          height: 24,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: authCtrl,
        builder: (context, _) {
          final user = authCtrl.currentUser;
          final userName = user?.name.split(' ').first ?? 'User';
          final balance = user?.balanceKobo ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              await escrowCtrl.fetchOrders();
            },
            color: Colors.white,
            backgroundColor: Colors.black,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Hello, $userName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Top Balance Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5,
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
                            children: [
                              const Text(
                                'AVAILABLE BALANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white54,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                CurrencyFormatter.formatKobo(balance),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  if (user?.role == UserRole.seller) ...[
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                           EscraRouter.push(
                                             context,
                                             const CreateOrderScreen(),
                                           ).then((_) => escrowCtrl.fetchOrders());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text(
                                          'Create Order',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Go to Wallet tab to withdraw')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: const BorderSide(color: Colors.white24, width: 1),
                                        ),
                                      ),
                                      icon: const Icon(Icons.arrow_downward, size: 18),
                                      label: const Text(
                                        'Withdraw',
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Awaiting Shipment (1)',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.black12, height: 1),
                      ],
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: escrowCtrl,
                  builder: (context, _) {
                    if (escrowCtrl.isLoading && escrowCtrl.orders.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: Colors.black)),
                      );
                    }

                    if (escrowCtrl.orders.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 40,
                                    color: Colors.black38,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'No Escrows Found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your secure escrow agreements will appear here. Pull down to refresh or generate a new transaction.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = escrowCtrl.orders[index];
                            final isMyBuyerOrder = order.buyerId == user?.id;
                            return _OrderCard(
                              order: order,
                              isMyBuyerOrder: isMyBuyerOrder,
                              onTap: () {
                                 EscraRouter.push(
                                   context,
                                   OrderDetailScreen(order: order),
                                 ).then((_) => escrowCtrl.fetchOrders());
                              },
                            );
                          },
                          childCount: escrowCtrl.orders.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isMyBuyerOrder;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isMyBuyerOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData getIcon(String title) {
      final t = title.toLowerCase();
      if (t.contains('phone')) return Icons.smartphone;
      if (t.contains('mac') || t.contains('laptop') || t.contains('pc')) return Icons.laptop_mac;
      if (t.contains('ps5') || t.contains('game')) return Icons.sports_esports;
      return Icons.inventory_2_outlined;
    }

    Color getStatusColor() {
      switch (order.status) {
        case EscrowStatus.pendingPayment:
          return Colors.orange.shade100;
        case EscrowStatus.funded:
          return const Color(0xFFF0F0F0); 
        case EscrowStatus.delivered:
          return Colors.black; 
        case EscrowStatus.completed:
          return Colors.grey.shade300;
        case EscrowStatus.disputed:
          return Colors.red.shade100;
        case EscrowStatus.refunded:
          return Colors.grey.shade200;
      }
    }

    Color getStatusTextColor() {
      if (order.status == EscrowStatus.delivered || order.status == EscrowStatus.completed) {
        return Colors.white;
      }
      return Colors.black;
    }

    String getStatusText() {
      switch (order.status) {
        case EscrowStatus.pendingPayment:
          return 'PENDING PAYMENT';
        case EscrowStatus.funded:
          return 'AWAITING SHIPMENT';
        case EscrowStatus.delivered:
          return 'IN ESCROW';
        case EscrowStatus.completed:
          return 'COMPLETED';
        case EscrowStatus.disputed:
          return 'DISPUTED';
        case EscrowStatus.refunded:
          return 'REFUNDED';
      }
    }

    IconData getStatusIcon() {
      if (order.status == EscrowStatus.delivered) return Icons.lock_outline;
      if (order.status == EscrowStatus.completed) return Icons.check;
      if (order.status == EscrowStatus.funded) return Icons.local_shipping_outlined;
      return Icons.info_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         order.title,
                         style: const TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: Colors.black87,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         isMyBuyerOrder ? 'Seller: ${order.sellerName}' : 'Buyer: ${order.buyerName}',
                         style: const TextStyle(
                           fontSize: 14,
                           color: Colors.black54,
                         ),
                       ),
                     ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Icon(
                    getIcon(order.title),
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      CurrencyFormatter.formatKobo(order.amountKobo),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getStatusIcon(),
                        size: 12,
                        color: getStatusTextColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        getStatusText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: getStatusTextColor(),
                          letterSpacing: 0.5,
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
    );
  }
}
