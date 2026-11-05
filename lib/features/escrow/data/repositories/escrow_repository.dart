import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../auth/data/models/user_model.dart';
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
    String buyerName, {
    String? salesChannel,
    String? deliveryMode,
  });

  /// Fetches chronological timeline updates for specific order agreements
  Future<List<EscrowEventModel>> getEvents(String orderId);

  /// Updates status gate on escrow agreement by processing state machine checks
  Future<OrderModel> updateOrderStatus(
    String orderId,
    EscrowStatus status,
    String actorId,
    UserRole actorRole, {
    String? pin,
    String? deliveryCode,
    String? disputeReason,
  });

  /// Marks order as shipped
  Future<OrderModel> shipOrder(
    String orderId, {
    String? trackingReference,
    String? deliveryProofUrl,
    String? note,
  });

  /// Marks order as delivered
  Future<OrderModel> markOrderDelivered(
    String orderId, {
    String? deliveryProofUrl,
    String? note,
  });

  /// Releases escrow funds to seller
  Future<OrderModel> releaseEscrow(String orderId);

  /// Cancels an unfunded order
  Future<OrderModel> cancelOrder(String orderId, {String? reason});

  /// Refunds escrow back to buyer
  Future<OrderModel> refundOrder(String orderId, {String? reason});

  /// Starts checkout via Kora
  Future<Map<String, dynamic>> startKoraCheckout(
    String orderId, {
    bool merchantBearsCost = false,
  });

  /// Fetches public escrow order preview
  Future<Map<String, dynamic>> getPublicEscrowOrderPreview(String reference);

  /// Fetches full order details
  Future<OrderModel> getOrderDetails(String reference);

  /// Admin resolve escrow dispute
  Future<OrderModel> adminResolveDispute(
    String orderId, {
    required String action,
    String? resolutionNote,
  });
}

/// Real HTTP implementation of [EscrowRepository] interacting with the ESCRA backend.
class HttpEscrowRepository implements EscrowRepository {
  final ApiClient _apiClient;

  HttpEscrowRepository(this._apiClient);

  EscrowStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return EscrowStatus.pendingPayment;
      case 'FUNDED':
      case 'SHIPPED':
        return EscrowStatus.funded;
      case 'DELIVERY_PENDING_CONFIRMATION':
      case 'DELIVERED':
        return EscrowStatus.delivered;
      case 'RELEASED':
      case 'COMPLETED':
        return EscrowStatus.completed;
      case 'DISPUTED':
        return EscrowStatus.disputed;
      case 'REFUNDED':
      case 'CANCELLED':
        return EscrowStatus.refunded;
      default:
        return EscrowStatus.pendingPayment;
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/escrows/orders');
      final data = response.data!;
      final list = data['orders'] as List<dynamic>? ?? [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return OrderModel(
          id: map['reference'] as String? ?? map['id'] as String? ?? 'esc_unknown',
          title: map['title'] as String? ?? 'Escrow Order',
          amountKobo: map['amount_kobo'] as int? ?? 0,
          status: _parseStatus(map['status'] as String? ?? 'CREATED'),
          buyerId: map['buyer_id'] as String? ?? '',
          sellerId: map['seller_id'] as String? ?? '',
          buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
          sellerName: map['seller_name'] as String? ?? 'Seller',
          description: map['description'] as String? ?? '',
          createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load escrow orders.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> createOrder(
    String title,
    int amountKobo,
    String sellerEmail, // This is the buyer identifier (email/phone/ID)
    String description,
    String buyerId,
    String buyerName, {
    String? salesChannel,
    String? deliveryMode,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
        'description': description,
        'amount_kobo': amountKobo,
        'currency': 'NGN',
        'cross_border': false,
      };

      if (salesChannel != null) {
        body['sales_channel'] = salesChannel;
      }
      if (deliveryMode != null) {
        body['delivery_mode'] = deliveryMode;
      }

      final identifier = sellerEmail.trim();
      if (identifier.contains('@')) {
        body['buyer_email'] = identifier;
      } else if (RegExp(r'^[0-9+\-\s]+$').hasMatch(identifier)) {
        body['buyer_phone'] = identifier;
      } else {
        body['buyer_id'] = identifier;
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders',
        data: body,
      );

      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? 'esc_unknown',
        title: map['title'] as String? ?? title,
        amountKobo: map['amount_kobo'] as int? ?? amountKobo,
        status: _parseStatus(map['status'] as String? ?? 'CREATED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? description,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to create escrow order.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<List<EscrowEventModel>> getEvents(String orderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/escrows/orders/$orderId');
      final map = response.data!;
      final list = map['events'] as List<dynamic>? ?? [];
      return list.map((item) {
        final eMap = item as Map<String, dynamic>;
        final action = eMap['action'] as String? ?? 'Update';
        final note = eMap['note'] as String? ?? '';
        return EscrowEventModel(
          id: eMap['created_at'] as String? ?? DateTime.now().toIso8601String(),
          orderId: orderId,
          title: action,
          message: note.isNotEmpty ? note : action,
          timestamp: DateTime.tryParse(eMap['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load order milestones.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    EscrowStatus status,
    String actorId,
    UserRole actorRole, {
    String? pin,
    String? deliveryCode,
    String? disputeReason,
  }) async {
    try {
      Response<Map<String, dynamic>> response;
      if (status == EscrowStatus.funded) {
        response = await _apiClient.post<Map<String, dynamic>>(
          '/escrows/orders/$orderId/fund',
          data: {
            'pin': pin ?? '1234',
          },
        );
      } else if (status == EscrowStatus.completed) {
        response = await _apiClient.post<Map<String, dynamic>>(
          '/escrows/orders/$orderId/confirm-delivery',
          data: {
            if (deliveryCode != null && deliveryCode.isNotEmpty) 'delivery_code': deliveryCode,
            if (pin != null && pin.isNotEmpty) 'pin': pin,
          },
        );
      } else if (status == EscrowStatus.disputed) {
        response = await _apiClient.post<Map<String, dynamic>>(
          '/escrows/orders/$orderId/dispute',
          data: {
            'reason': disputeReason ?? 'Dispute opened from app',
          },
        );
      } else {
        throw Exception('Unsupported manual status transition.');
      }

      final map = response.data!;
      final orderMap = (map['order'] as Map<String, dynamic>?) ?? map;

      return OrderModel(
        id: orderMap['reference'] as String? ?? orderMap['id'] as String? ?? orderId,
        title: orderMap['title'] as String? ?? 'Escrow Order',
        amountKobo: orderMap['amount_kobo'] as int? ?? 0,
        status: _parseStatus(orderMap['status'] as String? ?? 'CREATED'),
        buyerId: orderMap['buyer_id'] as String? ?? '',
        sellerId: orderMap['seller_id'] as String? ?? '',
        buyerName: orderMap['buyer_name'] as String? ?? orderMap['buyer_email'] as String? ?? orderMap['buyer_phone'] as String? ?? 'Buyer',
        sellerName: orderMap['seller_name'] as String? ?? 'Seller',
        description: orderMap['description'] as String? ?? '',
        createdAt: DateTime.tryParse(orderMap['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Status update failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> shipOrder(
    String orderId, {
    String? trackingReference,
    String? deliveryProofUrl,
    String? note,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders/$orderId/ship',
        data: {
          if (trackingReference != null) 'tracking_reference': trackingReference,
          if (deliveryProofUrl != null) 'delivery_proof_url': deliveryProofUrl,
          if (note != null) 'note': note,
        },
      );
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? orderId,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'SHIPPED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Mark ship failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> markOrderDelivered(
    String orderId, {
    String? deliveryProofUrl,
    String? note,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders/$orderId/mark-delivered',
        data: {
          if (deliveryProofUrl != null) 'delivery_proof_url': deliveryProofUrl,
          if (note != null) 'note': note,
        },
      );
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? orderId,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'DELIVERED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Mark delivered failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> releaseEscrow(String orderId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders/$orderId/release',
        data: {},
      );
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? orderId,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'RELEASED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Release escrow failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders/$orderId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? orderId,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'CANCELLED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Cancel order failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> refundOrder(String orderId, {String? reason}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders/$orderId/refund',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? orderId,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'REFUNDED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Refund order failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> startKoraCheckout(
    String orderId, {
    bool merchantBearsCost = false,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/escrows/orders/$orderId/checkout/kora',
        data: {
          'merchant_bears_cost': merchantBearsCost,
        },
      );
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Kora checkout failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPublicEscrowOrderPreview(String reference) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/public/escrows/orders/$reference');
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Public preview failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String reference) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/escrows/orders/$reference');
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? reference,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'CREATED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load order details.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> adminResolveDispute(
    String orderId, {
    required String action,
    String? resolutionNote,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/admin/escrows/orders/$orderId/resolve-dispute',
        data: {
          'action': action,
          if (resolutionNote != null) 'resolution_note': resolutionNote,
        },
        options: Options(headers: {'X-Admin-Key': 'admin_key_goes_here'}),
      );
      final map = response.data!;
      return OrderModel(
        id: map['reference'] as String? ?? map['id'] as String? ?? orderId,
        title: map['title'] as String? ?? 'Escrow Order',
        amountKobo: map['amount_kobo'] as int? ?? 0,
        status: _parseStatus(map['status'] as String? ?? 'RELEASED'),
        buyerId: map['buyer_id'] as String? ?? '',
        sellerId: map['seller_id'] as String? ?? '',
        buyerName: map['buyer_name'] as String? ?? map['buyer_email'] as String? ?? map['buyer_phone'] as String? ?? 'Buyer',
        sellerName: map['seller_name'] as String? ?? 'Seller',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Dispute resolution failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }
}
