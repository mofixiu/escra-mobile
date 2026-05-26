import '../../../../core/api/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/escrow_state_machine.dart';
import '../models/escrow_event_model.dart';
import '../models/order_model.dart';

/// Escrow agreement data manipulation contract.
abstract class EscrowRepository {
  /// Fetches all active escrow agreements involving this user
  Future<List<OrderModel>> getOrders();

  /// Registers a brand new escrow agreement
  Future<OrderModel> createOrder(
    String title,
    int amountKobo,
    String sellerEmail,
    String description,
    String buyerId,
    String buyerName,
  );

  /// Fetches chronological timeline updates for specific order agreements
  Future<List<EscrowEventModel>> getEvents(String orderId);

  /// Updates status gate on escrow agreement by processing state machine checks
  Future<OrderModel> updateOrderStatus(
    String orderId,
    EscrowStatus status,
    String actorId,
    UserRole actorRole,
  );
}

/// Simulated implementation of [EscrowRepository] holding data streams.
class MockEscrowRepository implements EscrowRepository {
  
  final List<OrderModel> _mockOrders = [];
  final List<EscrowEventModel> _mockEvents = [];

  MockEscrowRepository(ApiClient _) {
    // Seed high-fidelity sample agreements to make the app alive instantly
    _mockOrders.addAll([
      OrderModel(
        id: 'esc_macbook_992',
        title: 'M3 MacBook Pro Max 16GB',
        amountKobo: 235000000, // ₦2,350,000.00
        status: EscrowStatus.pendingPayment,
        buyerId: 'usr_89x201', // Matching active demo Buyer ID
        sellerId: 'usr_mac_shop_09',
        buyerName: 'Buyer',
        sellerName: 'MacBook Store NG',
        description: 'Brand new space black Apple M3 MacBook Pro. Original box. Escrow held securely until buyer validates package.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrderModel(
        id: 'esc_jacket_712',
        title: 'Premium Leather Designer Jacket',
        amountKobo: 12000000, // ₦120,000.00
        status: EscrowStatus.funded,
        buyerId: 'usr_buyer_obinna',
        sellerId: 'usr_89x201', // Matching active demo Seller ID
        buyerName: 'Obinna Okafor',
        sellerName: 'Seller',
        description: 'Custom brown leather jacket, size XL. Escrow funded, shipping from Lagos.',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ]);

    // Seed corresponding milestones
    _mockEvents.addAll([
      EscrowEventModel(
        id: 'ev_001',
        orderId: 'esc_macbook_992',
        title: 'Escrow Initiated',
        message: 'Contract draft created for M3 MacBook Pro Max. Agreed amount: ₦2,350,000.00. Awaiting buyer funding.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EscrowEventModel(
        id: 'ev_002',
        orderId: 'esc_jacket_712',
        title: 'Escrow Initiated',
        message: 'Contract draft created for Premium Leather Jacket. Agreed amount: ₦120,000.00.',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
      EscrowEventModel(
        id: 'ev_003',
        orderId: 'esc_jacket_712',
        title: 'Funds Secured in Escrow',
        message: 'Buyer Obinna Okafor successfully deposited ₦120,000.00. Funds held in neutral collateral. Seller can ship.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _mockOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.from(_mockOrders);
  }

  @override
  Future<OrderModel> createOrder(
    String title,
    int amountKobo,
    String sellerEmail,
    String description,
    String buyerId,
    String buyerName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final order = OrderModel(
      id: 'esc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amountKobo: amountKobo,
      status: EscrowStatus.pendingPayment,
      buyerId: buyerId,
      sellerId: 'usr_seller_${DateTime.now().millisecondsSinceEpoch}',
      buyerName: buyerName,
      sellerName: sellerEmail.split('@').first.toUpperCase(),
      description: description,
      createdAt: DateTime.now(),
    );

    _mockOrders.add(order);

    // Initial event
    _mockEvents.add(EscrowEventModel(
      id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      title: 'Escrow Initiated',
      message: 'Agreement established. Buyer: $buyerName, Seller: ${order.sellerName}. Amount: ${order.amountKobo}',
      timestamp: DateTime.now(),
    ));

    return order;
  }

  @override
  Future<List<EscrowEventModel>> getEvents(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final matching = _mockEvents.where((e) => e.orderId == orderId).toList();
    matching.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return matching;
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    EscrowStatus status,
    String actorId,
    UserRole actorRole,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final idx = _mockOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) throw Exception('Escrow agreement details not found.');

    final oldOrder = _mockOrders[idx];

    // Enforce business state machine
    final newOrder = EscrowStateMachine.transition(oldOrder, status, actorId, actorRole);
    _mockOrders[idx] = newOrder;

    // Dynamically compose customized event logs
    String evTitle = 'Escrow Updated';
    String evMsg = 'Agreement transitioned to ${status.name}';

    if (status == EscrowStatus.funded) {
      evTitle = 'Funds Secured in Escrow';
      evMsg = 'Buyer successfully deposited funds into neutral lock. Waiting for shipment.';
    } else if (status == EscrowStatus.delivered) {
      evTitle = 'Consignment Dispatched';
      evMsg = 'Seller marked items as dispatched and delivered. Buyer verification countdown active.';
    } else if (status == EscrowStatus.completed) {
      evTitle = 'Funds Released to Seller';
      evMsg = 'Buyer verified receipt and approved payout release. Agreement successfully closed.';
    } else if (status == EscrowStatus.disputed) {
      evTitle = 'Dispute Raised';
      evMsg = 'Arbitration requested. Funds locked pending neutral settlement.';
    } else if (status == EscrowStatus.refunded) {
      evTitle = 'Escrow Refunded';
      evMsg = 'Seller authorized return. Money returned to Buyer account wallet.';
    }

    _mockEvents.add(EscrowEventModel(
      id: 'ev_update_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      title: evTitle,
      message: evMsg,
      timestamp: DateTime.now(),
    ));

    return newOrder;
  }
}
