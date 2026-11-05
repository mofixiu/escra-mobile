import 'package:flutter/material.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/models/escrow_event_model.dart';
import '../../data/repositories/escrow_repository.dart';

/// Presentation-Controller for the Escrow Feature.
/// Bridges UI widgets directly to domain repository rules and updates active balances.
class EscrowController extends ChangeNotifier {
  final EscrowRepository _escrowRepository;
  final AuthController _authController;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  EscrowController(this._escrowRepository, this._authController) {
    _authController.addListener(_onAuthChanged);
    if (_authController.isAuthenticated) {
      fetchOrders();
    }
  }

  void _onAuthChanged() {
    if (!_authController.isAuthenticated) {
      // Clear cached orders list on logout to prevent state leakage
      _orders = [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } else {
      // Fetch orders immediately when a new user logs in
      fetchOrders();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Refreshes all active agreements involving the active user session
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _escrowRepository.getOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialises an agreement contract
  Future<bool> createAgreement({
    required String title,
    required int amountKobo,
    required String sellerEmail,
    required String description,
    String? salesChannel,
    String? deliveryMode,
  }) async {
    if (_authController.currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authController.currentUser!;
      await _escrowRepository.createOrder(
        title,
        amountKobo,
        sellerEmail,
        description,
        user.id,
        user.name,
        salesChannel: salesChannel,
        deliveryMode: deliveryMode,
      );
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Processes state transitions and manages accompanying wallet offsets
  Future<bool> updateStatus(
    String orderId,
    EscrowStatus nextStatus, {
    String? pin,
    String? deliveryCode,
    String? disputeReason,
  }) async {
    if (_authController.currentUser == null) return false;
    final user = _authController.currentUser!;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final oldIdx = _orders.indexWhere((o) => o.id == orderId);
      if (oldIdx == -1) throw Exception('Order agreement details not found.');
      final oldOrder = _orders[oldIdx];

      if (nextStatus == EscrowStatus.funded && user.balanceKobo < oldOrder.amountKobo) {
        throw Exception('Insufficient balance. Fund your wallet before committing to this escrow.');
      }

      // Call the server first; only move the local balance once it succeeds,
      // so a failed payment never leaves the balance short.
      await _escrowRepository.updateOrderStatus(
        orderId,
        nextStatus,
        user.id,
        user.role,
        pin: pin,
        deliveryCode: deliveryCode,
        disputeReason: disputeReason,
      );

      final balanceKobo = _authController.currentUser?.balanceKobo ?? user.balanceKobo;
      if (nextStatus == EscrowStatus.funded) {
        // Deduct from buyer's active balance
        _authController.updateBalance(balanceKobo - oldOrder.amountKobo);
      } else if (nextStatus == EscrowStatus.completed && oldOrder.sellerId == user.id) {
        // The active user is the seller: credit their balance
        _authController.updateBalance(balanceKobo + oldOrder.amountKobo);
      } else if (nextStatus == EscrowStatus.refunded && oldOrder.buyerId == user.id) {
        // The active user is the buyer: return funds
        _authController.updateBalance(balanceKobo + oldOrder.amountKobo);
      }

      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> shipOrder(
    String orderId, {
    String? trackingReference,
    String? deliveryProofUrl,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _escrowRepository.shipOrder(
        orderId,
        trackingReference: trackingReference,
        deliveryProofUrl: deliveryProofUrl,
        note: note,
      );
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markOrderDelivered(
    String orderId, {
    String? deliveryProofUrl,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _escrowRepository.markOrderDelivered(
        orderId,
        deliveryProofUrl: deliveryProofUrl,
        note: note,
      );
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> releaseEscrow(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _escrowRepository.releaseEscrow(orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _escrowRepository.cancelOrder(orderId, reason: reason);
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refundOrder(String orderId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _escrowRepository.refundOrder(orderId, reason: reason);
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Chronological fetch of order milestones
  Future<List<EscrowEventModel>> fetchEvents(String orderId) async {
    return await _escrowRepository.getEvents(orderId);
  }

  /// Fetch up-to-date details for a specific order reference
  Future<OrderModel> fetchOrderDetails(String reference) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _escrowRepository.getOrderDetails(reference);
      final idx = _orders.indexWhere((o) => o.id == order.id);
      if (idx != -1) {
        _orders[idx] = order;
      } else {
        _orders.add(order);
      }
      return order;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start Kora checkout for escrow order
  Future<String?> startCheckout(String orderId, {bool merchantBearsCost = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _escrowRepository.startKoraCheckout(orderId, merchantBearsCost: merchantBearsCost);
      final checkoutUrl = res['checkout_url'] as String?;
      return checkoutUrl;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches public escrow order preview by reference
  Future<Map<String, dynamic>?> getPublicPreview(String reference) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _escrowRepository.getPublicEscrowOrderPreview(reference);
      return res;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

