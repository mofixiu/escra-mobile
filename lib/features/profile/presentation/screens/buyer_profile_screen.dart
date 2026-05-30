import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/auth_controller.dart';
import 'account_settings_screen.dart';
import 'security_pin_screen.dart';
import 'payment_methods_screen.dart';
import '../../../../core/utils/escra_router.dart';

/// High-fidelity Buyer Profile Screen matching the original designs.
class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = GetIt.I<AuthController>();
    final user = authCtrl.currentUser;
    if (user == null) return const Scaffold(body: SizedBox());

    final username = '@${user.name.toLowerCase().replaceAll(' ', '_')}_secure';

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
          // Profile Avatar Frame
          Center(
            child: Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    // A sleek high-end dark steel/obsidian gradient to represent a premium profile picture
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name.split(' ').map((e) => e[0].toUpperCase()).join(''),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BUYER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // User Name & Handle
          Center(
            child: Column(
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'COMPLETED ORDERS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '24',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: Colors.black12,
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'TRUST SCORE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '98%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          // PREFERENCES GROUP
          _buildCategoryHeader('PREFERENCES'),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildTileItem(
              icon: Icons.settings_outlined,
              title: 'Account Settings',
              onTap: () {
                EscraRouter.push(context, const AccountSettingsScreen());
              },
            ),
            _buildTileItem(
              icon: Icons.lock_outline_rounded,
              title: 'Security & PIN',
              onTap: () {
                EscraRouter.push(context, const SecurityPinScreen());
              },
            ),
            _buildTileItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {
                EscraRouter.push(context, const PaymentMethodsScreen());
              },
            ),
          ]),
          const SizedBox(height: 24),
          // SUPPORT GROUP
          _buildCategoryHeader('SUPPORT'),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildTileItem(
              icon: Icons.support_agent_rounded,
              title: 'Support',
              onTap: () {},
            ),
            _buildTileItem(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              onTap: () {},
            ),
            _buildTileItem(
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
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
          const SizedBox(height: 120), // Bottom padding to float above safe area nav bar
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.secondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: children,
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
