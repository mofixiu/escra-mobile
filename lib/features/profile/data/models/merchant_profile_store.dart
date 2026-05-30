import 'package:flutter/material.dart';

/// Single-source-of-truth state container for Merchant Profile simulation.
/// Holds reactive variables so edits in Business Details or Payout Settings
/// instantly rebuild the relevant UIs.
class MerchantProfileStore extends ChangeNotifier {
  // Business details
  String businessName = 'Horology House Ltd.';
  String businessType = 'Private Limited Company';
  String rcNumber = 'RC 1782940';
  String supportEmail = 'info@horologyhouse.com';
  String supportPhone = '+234 812 345 6789';
  String website = 'www.horologyhouse.com';
  String address = '12 Marina, Lagos Island';
  String city = 'Lagos';
  String country = 'Nigeria';

  // Payout settings
  String bankName = 'Access Bank';
  String accountNumber = '0123456789';
  String accountName = 'HOROLOGY HOUSE LTD.';
  String payoutFrequency = 'Instant'; // Instant, Daily, Weekly

  // Additional mock banks
  final List<Map<String, String>> mockBanks = [
    {'name': 'Access Bank', 'code': '044'},
    {'name': 'Zenith Bank', 'code': '057'},
    {'name': 'Guaranty Trust Bank', 'code': '058'},
    {'name': 'United Bank for Africa', 'code': '033'},
    {'name': 'First Bank of Nigeria', 'code': '011'},
  ];

  static final MerchantProfileStore _instance = MerchantProfileStore._internal();
  
  factory MerchantProfileStore() => _instance;

  MerchantProfileStore._internal();

  void updateBusinessDetails({
    required String name,
    required String type,
    required String rc,
    required String email,
    required String phone,
    required String web,
    required String addr,
    required String ct,
  }) {
    businessName = name;
    businessType = type;
    rcNumber = rc;
    supportEmail = email;
    supportPhone = phone;
    website = web;
    address = addr;
    city = ct;
    notifyListeners();
  }

  void updatePayoutSettings({
    required String bank,
    required String account,
    required String name,
  }) {
    bankName = bank;
    accountNumber = account;
    accountName = name;
    notifyListeners();
  }

  void updatePayoutFrequency(String freq) {
    payoutFrequency = freq;
    notifyListeners();
  }
}
