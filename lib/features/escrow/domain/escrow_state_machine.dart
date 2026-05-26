import '../../auth/data/models/user_model.dart';
import '../data/models/order_model.dart';

/// Pure domain business logic safeguarding Escrow State Transitions.
/// Implements strict checking based on Buyer vs. Seller roles and state gates.
class EscrowStateMachine {
  EscrowStateMachine._();

  /// Buyer must be the actor to fund a pending order
  static bool canFund(OrderModel order, String actorId, UserRole role) {
    return order.status == EscrowStatus.pendingPayment &&
        order.buyerId == actorId &&
        role == UserRole.buyer;
  }

  /// Seller must be the actor to deliver a funded order
  static bool canDeliver(OrderModel order, String actorId, UserRole role) {
    return order.status == EscrowStatus.funded &&
        order.sellerId == actorId &&
        role == UserRole.seller;
  }

  /// Buyer must be the actor to release funds (completing from delivered/disputed states)
  static bool canRelease(OrderModel order, String actorId, UserRole role) {
    return (order.status == EscrowStatus.delivered || order.status == EscrowStatus.disputed) &&
        order.buyerId == actorId &&
        role == UserRole.buyer;
  }

  /// Buyer can dispute when funds are held (funded or delivered states)
  static bool canDispute(OrderModel order, String actorId, UserRole role) {
    return (order.status == EscrowStatus.funded || order.status == EscrowStatus.delivered) &&
        order.buyerId == actorId &&
        role == UserRole.buyer;
  }

  /// Seller must be the actor to voluntarily issue a refund to the buyer
  static bool canRefund(OrderModel order, String actorId, UserRole role) {
    return (order.status == EscrowStatus.funded ||
            order.status == order.status ||
            order.status == EscrowStatus.disputed) &&
        order.sellerId == actorId &&
        role == UserRole.seller;
  }

  /// Validates a proposed state transition.
  /// Returns a fresh copy of [OrderModel] with updated status if valid, or throws.
  static OrderModel transition(
    OrderModel order,
    EscrowStatus nextStatus,
    String actorId,
    UserRole actorRole,
  ) {
    switch (nextStatus) {
      case EscrowStatus.funded:
        if (!canFund(order, actorId, actorRole)) {
          throw Exception('Transition denied: Only the designated Buyer can fund this transaction.');
        }
        break;
      case EscrowStatus.delivered:
        if (!canDeliver(order, actorId, actorRole)) {
          throw Exception('Transition denied: Only the designated Seller can dispatch/deliver this order.');
        }
        break;
      case EscrowStatus.completed:
        if (!canRelease(order, actorId, actorRole)) {
          throw Exception('Transition denied: Only the Buyer can release funds to complete this order.');
        }
        break;
      case EscrowStatus.disputed:
        if (!canDispute(order, actorId, actorRole)) {
          throw Exception('Transition denied: Only the Buyer can open a dispute.');
        }
        break;
      case EscrowStatus.refunded:
        if (!canRefund(order, actorId, actorRole)) {
          throw Exception('Transition denied: Only the Seller can approve a refund back to the Buyer.');
        }
        break;
      case EscrowStatus.pendingPayment:
        throw Exception('Transition denied: Reverting order back to Draft state is not permitted.');
    }

    return order.copyWith(status: nextStatus);
  }
}
