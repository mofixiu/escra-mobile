import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../data/models/merchant_profile_store.dart';
import 'business_details_screen.dart';
import 'payout_settings_screen.dart';
import 'verification_status_screen.dart';
import '../../../../core/utils/escra_router.dart';
import 'security_pin_screen.dart';
import 'store_analytics_screen.dart';
import 'contact_support_screen.dart';

/// High-fidelity Seller Profile Screen matching the original designs.
class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _profileStore = MerchantProfileStore();

  @override
  void initState() {
    super.initState();
    _profileStore.addListener(_rebuild);
  }

  @override
  void dispose() {
    _profileStore.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = GetIt.I<AuthController>();
    final user = authCtrl.currentUser;
    if (user == null) return const Scaffold(body: SizedBox());

    final initial = _profileStore.businessName.isNotEmpty
        ? _profileStore.businessName[0].toUpperCase()
        : 'M';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Image.asset(
              'assets/logos/escralogonobackground.png',
              height: 20,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          const SizedBox(height: 16),
          // Seller Black Avatar Logo
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Brand Name
          Center(
            child: Text(
              _profileStore.businessName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Verified Merchant Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Colors.black87,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'VERIFIED MERCHANT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Username / Merchant ID
          const Center(
            child: Text(
              '@merchant_id',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sales, Rating, Active Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'SALES',
                  value: '₦14.2M',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'RATING',
                  value: '4.9',
                  suffix: ' /5.0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'ACTIVE',
                  value: '3',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Group 1: Business Operations
          _buildCardGroup([
            _buildTileItem(
              icon: Icons.business_center_outlined,
              title: 'Business Details',
              onTap: () {
                EscraRouter.push(
                  context,
                  const BusinessDetailsScreen(),
                );
              },
            ),
            _buildTileItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payout Settings',
              onTap: () {
                EscraRouter.push(
                  context,
                  const PayoutSettingsScreen(),
                );
              },
            ),
            _buildTileItem(
              icon: Icons.verified_user_outlined,
              title: 'Verification Status',
              onTap: () {
                EscraRouter.push(
                  context,
                  const VerificationStatusScreen(),
                );
              },
            ),
          ]),
          const SizedBox(height: 16),
          // Group 2: Account Security & Analytics
          _buildCardGroup([
            _buildTileItem(
              icon: Icons.lock_outline_rounded,
              title: 'Security & PIN',
              onTap: () {
                EscraRouter.push(context, const SecurityPinScreen());
              },
            ),
            _buildTileItem(
              icon: Icons.analytics_outlined,
              title: 'Store Analytics',
              onTap: () {
                EscraRouter.push(context, const StoreAnalyticsScreen());
              },
            ),
          ]),
          const SizedBox(height: 16),
          // Group 3: Help & Support
          _buildCardGroup([
            _buildTileItem(
              icon: Icons.help_outline_rounded,
              title: 'Support',
              onTap: () {
                EscraRouter.push(context, const ContactSupportScreen());
              },
            ),
            _buildTileItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 36),
          // LOGOUT BUTTON
          Center(
            child: TextButton(
              onPressed: () async {
                await authCtrl.logout();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 120), // Bottom padding to float above bottom navigation bar
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.secondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Montserrat',
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppColors.border),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildTileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
