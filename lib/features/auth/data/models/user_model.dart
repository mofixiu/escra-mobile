/// User Roles for ESCRA app logic checks.
enum UserRole { buyer, seller }

/// High-fidelity UserModel for ESCRA.
/// Traffic balances strictly in integer [balanceKobo] to prevent precision loss.
class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int balanceKobo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.balanceKobo,
  });

  /// Factory constructor to parse user data JSON from the repository/api layer
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: (json['role'] as String).toLowerCase() == 'buyer'
          ? UserRole.buyer
          : UserRole.seller,
      balanceKobo: json['balance_kobo'] as int? ?? 0,
    );
  }

  /// Serializes UserModel data back into JSON for secure local storage persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.buyer ? 'buyer' : 'seller',
      'balance_kobo': balanceKobo,
    };
  }

  /// Facilitates state updates in controllers without mutating prior configurations
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    int? balanceKobo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      balanceKobo: balanceKobo ?? this.balanceKobo,
    );
  }
}
