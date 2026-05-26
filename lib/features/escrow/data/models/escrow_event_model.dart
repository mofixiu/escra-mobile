/// Model representing milestones/history events in an Escrow's lifecycle.
/// Used directly inside the Timeline Widget to show dynamic, interactive updates.
class EscrowEventModel {
  final String id;
  final String orderId;
  final String title;
  final String message;
  final DateTime timestamp;

  EscrowEventModel({
    required this.id,
    required this.orderId,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory EscrowEventModel.fromJson(Map<String, dynamic> json) {
    return EscrowEventModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
