import '../../../../core/api/api_client.dart';
import '../models/transaction_model.dart';

/// Clean contract for Wallet data layer operations.
abstract class WalletRepository {
  /// Fetches historical credit and debit lists
  Future<List<TransactionModel>> getTransactions();

  /// Simulates card funding of the local account wallet
  Future<TransactionModel> fundWallet(int amountKobo);

  /// Performs secure payouts or external bank transfers
  Future<TransactionModel> transferFunds(int amountKobo, String recipient);
}

/// Simulated implementation of [WalletRepository] keeping local state streams.
class MockWalletRepository implements WalletRepository {
  
  final List<TransactionModel> _mockTransactions = [];

  MockWalletRepository(ApiClient _) {
    // Seed initial historical records to make the presentation screens look alive
    _mockTransactions.addAll([
      TransactionModel(
        id: 'tx_001',
        amountKobo: 50000000, // ₦500,000.00
        description: 'Account Setup Seeding',
        type: TransactionType.credit,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: 'tx_002',
        amountKobo: 25000000, // ₦250,000.00
        description: 'Secured Escrow Collateral',
        type: TransactionType.debit,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.from(_mockTransactions);
  }

  @override
  Future<TransactionModel> fundWallet(int amountKobo) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final tx = TransactionModel(
      id: 'tx_fund_${DateTime.now().millisecondsSinceEpoch}',
      amountKobo: amountKobo,
      description: 'Wallet Funding via Card',
      type: TransactionType.credit,
      timestamp: DateTime.now(),
    );
    _mockTransactions.add(tx);
    return tx;
  }

  @override
  Future<TransactionModel> transferFunds(int amountKobo, String recipient) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final tx = TransactionModel(
      id: 'tx_pay_${DateTime.now().millisecondsSinceEpoch}',
      amountKobo: amountKobo,
      description: 'External Transfer to $recipient',
      type: TransactionType.debit,
      timestamp: DateTime.now(),
    );
    _mockTransactions.add(tx);
    return tx;
  }
}
