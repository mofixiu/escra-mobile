/// Valid statuses inside the Escrow State Machine
enum EscrowStatus {
  pendingPayment, // Created, waiting for Buyer to fund
  funded,         // Funded by Buyer, waiting for Seller to deliver
  delivered,      // Delivered by Seller, waiting for Buyer to release/dispute
  completed,      // Released by Buyer, funds credited to Seller
  disputed,       // Disputed by either party, held in lock
  refunded        // Discretionary refund back to Buyer
}

/// Standard OrderModel for the ESCRA app.
class OrderModel {
  final String id;
  final String title;
  final int amountKobo;
  final EscrowStatus status;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String description;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.title,
    required this.amountKobo,
    required this.status,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    required this.description,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amountKobo: json['amount_kobo'] as int,
      status: EscrowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EscrowStatus.pendingPayment,
      ),
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      buyerName: json['buyer_name'] as String,
      sellerName: json['seller_name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount_kobo': amountKobo,
      'status': status.name,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'buyer_name': buyerName,
      'seller_name': sellerName,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? title,
    int? amountKobo,
    EscrowStatus? status,
    String? buyerId,
    String? sellerId,
    String? buyerName,
    String? sellerName,
    String? description,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amountKobo: amountKobo ?? this.amountKobo,
      status: status ?? this.status,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
