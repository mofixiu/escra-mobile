import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/transaction_model.dart';

/// Clean contract for Wallet data layer operations.
abstract class WalletRepository {
  /// Fetches historical credit and debit lists
  Future<List<TransactionModel>> getTransactions();

  /// Simulates card funding of the local account wallet
  Future<TransactionModel> fundWallet(int amountKobo);

  /// Performs secure payouts or external bank transfers
  Future<TransactionModel> transferFunds(int amountKobo, String recipient, String pin);

  /// Fetches supported banks for Kora Pay
  Future<List<Map<String, String>>> getSupportedBanks();

  /// Resolves bank account details
  Future<Map<String, dynamic>> resolveBankAccount({
    required String bankCode,
    required String accountNumber,
    String currency = 'NGN',
  });

  /// Initiates bank payout via Kora
  Future<Map<String, dynamic>> initiateBankPayout({
    required String bankCode,
    required String accountNumber,
    String? accountName,
    String? customerEmail,
    required int amountKobo,
    String? currency,
    String? narration,
    required String pin,
  });

  /// Initiates crypto withdrawal via Quidax
  Future<Map<String, dynamic>> initiateCryptoWithdrawal({
    required String currency,
    required double amount,
    required String fundUid,
    String? fundUid2,
    String? network,
    String? transactionNote,
    String? narration,
    String? providerUserId,
    required String pin,
  });

  /// Fetches the wallet object
  Future<Map<String, dynamic>> getWallet();

  /// Fetches wallet balance
  Future<Map<String, dynamic>> getWalletBalance();

  /// Fetches daily and monthly limits
  Future<Map<String, dynamic>> getLimits();

  /// Fetches transaction by reference
  Future<TransactionModel> getTransactionByReference(String reference);

  /// Starts wallet funding checkout via Kora API
  Future<String> startWalletFundingCheckout(int amountKobo);
}


/// Real HTTP implementation of [WalletRepository] interacting with the ESCRA backend.
class HttpWalletRepository implements WalletRepository {
  final ApiClient _apiClient;

  HttpWalletRepository(this._apiClient);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/transactions/history');
      final data = response.data!;
      final list = data['transactions'] as List<dynamic>? ?? [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return TransactionModel(
          id: map['id'] as String? ?? map['reference'] as String? ?? 'tx_unknown',
          amountKobo: map['amount_kobo'] as int? ?? 0,
          description: map['narration'] as String? ?? map['description'] as String? ?? 'Transfer',
          type: (map['type'] as String? ?? 'debit').toLowerCase() == 'credit'
              ? TransactionType.credit
              : TransactionType.debit,
          timestamp: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load transaction history.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<TransactionModel> fundWallet(int amountKobo) async {
    // Simulate locally since no public endpoint is defined for direct sandbox wallet funding
    await Future.delayed(const Duration(milliseconds: 600));
    return TransactionModel(
      id: 'tx_fund_${DateTime.now().millisecondsSinceEpoch}',
      amountKobo: amountKobo,
      description: 'Wallet Funding via Card (Simulated)',
      type: TransactionType.credit,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<TransactionModel> transferFunds(int amountKobo, String recipient, String pin) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/transactions/transfer',
        data: {
          'wallet_id': recipient,
          'amount_kobo': amountKobo,
          'pin': pin,
        },
      );

      final data = response.data!;
      final txMap = data['transaction'] as Map<String, dynamic>? ?? {};

      return TransactionModel(
        id: txMap['id'] as String? ?? txMap['reference'] as String? ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amountKobo: txMap['amount_kobo'] as int? ?? amountKobo,
        description: txMap['narration'] as String? ?? 'Transfer to $recipient',
        type: TransactionType.debit,
        timestamp: DateTime.tryParse(txMap['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Transfer failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, String>>> getSupportedBanks() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/providers/kora/banks?countryCode=NG');
      final data = response.data!;
      final list = data['banks'] as List<dynamic>? ?? [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return {
          'name': (map['name'] as String? ?? '').trim(),
          'code': (map['code'] as String? ?? '').trim(),
        };
      }).toList();
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load supported banks.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> resolveBankAccount({
    required String bankCode,
    required String accountNumber,
    String currency = 'NGN',
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/providers/kora/banks/resolve',
        queryParameters: {
          'bank_code': bankCode,
          'account_number': accountNumber,
          'currency': currency,
        },
      );
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to resolve bank account.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> initiateBankPayout({
    required String bankCode,
    required String accountNumber,
    String? accountName,
    String? customerEmail,
    required int amountKobo,
    String? currency,
    String? narration,
    required String pin,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/providers/kora/payouts/bank',
        data: {
          'bank_code': bankCode,
          'account_number': accountNumber,
          if (accountName != null) 'account_name': accountName,
          if (customerEmail != null) 'customer_email': customerEmail,
          'amount_kobo': amountKobo,
          if (currency != null) 'currency': currency,
          if (narration != null) 'narration': narration,
          'pin': pin,
        },
      );
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Bank payout failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> initiateCryptoWithdrawal({
    required String currency,
    required double amount,
    required String fundUid,
    String? fundUid2,
    String? network,
    String? transactionNote,
    String? narration,
    String? providerUserId,
    required String pin,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/providers/quidax/withdrawals',
        data: {
          'currency': currency,
          'amount': amount,
          'fund_uid': fundUid,
          if (fundUid2 != null) 'fund_uid2': fundUid2,
          if (network != null) 'network': network,
          if (transactionNote != null) 'transaction_note': transactionNote,
          if (narration != null) 'narration': narration,
          if (providerUserId != null) 'provider_user_id': providerUserId,
          'pin': pin,
        },
      );
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Crypto withdrawal failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/wallets/');
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load wallet details.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/wallets/balance');
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load wallet balance.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getLimits() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/limits/');
      return response.data!;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load transaction limits.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<TransactionModel> getTransactionByReference(String reference) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/transactions/$reference');
      final map = response.data!;
      return TransactionModel(
        id: map['id'] as String? ?? map['reference'] as String? ?? reference,
        amountKobo: map['amount_kobo'] as int? ?? 0,
        description: map['narration'] as String? ?? map['description'] as String? ?? 'Transfer',
        type: (map['type'] as String? ?? 'debit').toLowerCase() == 'credit'
            ? TransactionType.credit
            : TransactionType.debit,
        timestamp: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load transaction.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<String> startWalletFundingCheckout(int amountKobo) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/wallets/checkout/kora',
        data: {
          'amount_kobo': amountKobo,
          'redirect_url': 'https://escra.app/wallet/callback',
          'notification_url': 'https://escra-payment-backend.onrender.com/api/v1/webhooks/kora',
          'narration': 'Direct wallet deposit',
        },
      );
      final data = response.data!;
      return data['checkout_url'] as String;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Wallet checkout failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }
}

