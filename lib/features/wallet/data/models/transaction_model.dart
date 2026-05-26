/// Type of Wallet Transaction
enum TransactionType { credit, debit }

/// Model capturing money transfers, deposits, or escrow payouts in ESCRA.
/// Uses integer minor units [amountKobo] for financial integrity.
class TransactionModel {
  final String id;
  final int amountKobo;
  final String description;
  final TransactionType type;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.amountKobo,
    required this.description,
    required this.type,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amountKobo: json['amount_kobo'] as int,
      description: json['description'] as String,
      type: json['type'] as String == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount_kobo': amountKobo,
      'description': description,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
