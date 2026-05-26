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
    fetchOrders();
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
  Future<bool> updateStatus(String orderId, EscrowStatus nextStatus) async {
    if (_authController.currentUser == null) return false;
    final user = _authController.currentUser!;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final oldIdx = _orders.indexWhere((o) => o.id == orderId);
      if (oldIdx == -1) throw Exception('Order agreement details not found.');
      final oldOrder = _orders[oldIdx];

      // Safe financial balance adjustments during state alterations
      if (nextStatus == EscrowStatus.funded) {
        if (user.balanceKobo < oldOrder.amountKobo) {
          throw Exception('Insufficient balance. Fund your wallet before committing to this escrow.');
        }
        // Deduct from buyer's active balance
        _authController.updateBalance(user.balanceKobo - oldOrder.amountKobo);
      } else if (nextStatus == EscrowStatus.completed) {
        // If the active logged-in user is the Seller, credit their balance
        if (oldOrder.sellerId == user.id) {
          _authController.updateBalance(user.balanceKobo + oldOrder.amountKobo);
        }
      } else if (nextStatus == EscrowStatus.refunded) {
        // If the active logged-in user is the Buyer, return funds
        if (oldOrder.buyerId == user.id) {
          _authController.updateBalance(user.balanceKobo + oldOrder.amountKobo);
        }
      }

      await _escrowRepository.updateOrderStatus(orderId, nextStatus, user.id, user.role);
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
}
