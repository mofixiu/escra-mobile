import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/controllers/escrow_controller.dart';
import 'order_detail_screen.dart';
import 'buyer_order_details_screen.dart';
import 'create_order_screen.dart';
import '../../../../core/utils/escra_router.dart';

/// Seller/Buyer Dashboard & Order List (Stateful for Reference Lookup)
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _trackOrderPreview(BuildContext context, String reference, EscrowController escrowCtrl) async {
    // Show a loading indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      final preview = await escrowCtrl.getPublicPreview(reference);
      if (context.mounted) Navigator.pop(context); // Dismiss loading dialog

      if (preview == null || preview.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order reference not found.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show bottom sheet with public order preview details
      if (context.mounted) {
        _showPublicPreviewBottomSheet(context, preview, escrowCtrl);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPublicPreviewBottomSheet(BuildContext context, Map<String, dynamic> preview, EscrowController escrowCtrl) {
    final ref = preview['reference'] as String? ?? 'esc_unknown';
    final title = preview['title'] as String? ?? 'Escrow Order';
    final desc = preview['description'] as String? ?? '';
    final amountKobo = preview['amount_kobo'] as int? ?? 0;
    final seller = preview['seller_name'] as String? ?? 'Seller';
    final status = preview['status'] as String? ?? 'CREATED';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                    'Order Preview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 16),
              
              Text(
                'Reference: #${ref.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seller:', style: TextStyle(color: Colors.black54)),
                  Text(seller, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount:', style: TextStyle(color: Colors.black54)),
                  Text(
                    CurrencyFormatter.formatKobo(amountKobo),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:', style: TextStyle(color: Colors.black54)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.toUpperCase() == 'CREATED' ? Colors.orange.shade100 : Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase() == 'CREATED' ? 'AWAITING PAYMENT' : status,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              if (status.toUpperCase() == 'CREATED') ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // close bottom sheet
                    
                    // Show loading overlay
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.black)),
                    );

                    debugPrint('[OrderListScreen] Starting checkout from preview for order: $ref');
                    try {
                      final checkoutUrl = await escrowCtrl.startCheckout(ref);
                      if (context.mounted) Navigator.pop(context); // dismiss loading dialog
                      
                      if (checkoutUrl != null) {
                        final uri = Uri.parse(checkoutUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                        } else {
                          throw 'Could not launch payment URL';
                        }
                      } else {
                        throw Exception(escrowCtrl.errorMessage ?? 'Checkout failed.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        if (Navigator.canPop(context)) Navigator.pop(context); // safety dismiss
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('PAY WITH CARD/BANK (KORA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black12,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final escrowCtrl = GetIt.I<EscrowController>();
    final authCtrl = GetIt.I<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
              debugPrint('[OrderListScreen] Pull-to-refresh triggered. Fetching orders...');
              try {
                await escrowCtrl.fetchOrders();
                debugPrint('[OrderListScreen] Orders fetched successfully. Count: ${escrowCtrl.orders.length}');
              } catch (e) {
                debugPrint('[OrderListScreen] Error fetching orders on refresh: $e');
              }
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
                        const SizedBox(height: 16),
                        
                        // Search / Track Reference Input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.black38),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    hintText: 'Track Order Reference (e.g. ESC-...)',
                                    hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final ref = _searchCtrl.text.trim();
                                  if (ref.isNotEmpty) {
                                    _trackOrderPreview(context, ref, escrowCtrl);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('TRACK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
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
                                           ).then((_) {
                                              debugPrint('[OrderListScreen] Returned from CreateOrderScreen. Refreshing orders...');
                                              escrowCtrl.fetchOrders();
                                            });
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
                                    isMyBuyerOrder
                                        ? BuyerOrderDetailsScreen(order: order)
                                        : OrderDetailScreen(order: order),
                                  ).then((_) {
                                    debugPrint('[OrderListScreen] Returned from order details. Refreshing orders...');
                                    escrowCtrl.fetchOrders();
                                  });
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
