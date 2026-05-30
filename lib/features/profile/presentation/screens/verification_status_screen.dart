import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';

/// Premium visual Verification Status / KYC Screen for Sellers.
class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification Status',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 12),
          // Verified Status Icon/Header with subtle glowing visual design
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                      width: 4,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verified Merchant',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Your business is fully authenticated and cleared for high-tier financial transactions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Card 1: Compliance Auditing Gateways
          _buildSectionHeader('COMPLIANCE GATEWAYS'),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildGateItem(
              title: 'Corporate CAC Registration',
              subtitle: 'Certificate of Incorporation verified',
              isVerified: true,
            ),
            _buildGateItem(
              title: 'Proof of Business Address',
              subtitle: 'Utility bill & physical site checked',
              isVerified: true,
            ),
            _buildGateItem(
              title: 'Director Identity & KYC',
              subtitle: 'Government ID & face matches approved',
              isVerified: true,
            ),
            _buildGateItem(
              title: 'AML & PEP Sanction Screening',
              subtitle: 'Zero matches found in global list check',
              isVerified: true,
            ),
          ]),
          const SizedBox(height: 28),

          // Card 2: Transaction Capabilities & Limits
          _buildSectionHeader('MERCHANT CAPABILITIES'),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildCapabilityRow('Merchant Status Level', 'Tier 2 (Pro)'),
            _buildCapabilityRow('Daily Transaction Limit', '₦10,000,000 NGN'),
            _buildCapabilityRow('Monthly Cumulative Cap', '₦150,000,000 NGN'),
            _buildCapabilityRow('Standard Settlement Speed', 'Instant Payouts'),
          ]),
          const SizedBox(height: 36),

          // Dynamic Upgrade Request Trigger
          HighContrastButton(
            text: 'REQUEST HIGHER TIER LIMITS',
            onPressed: () => _showUpgradeDialog(context),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upgrade to Tier 3',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'To lift limits to Unlimited processing capabilities, our compliance team requires additional verification.',
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              _buildUpgradeRequirementRow(
                icon: Icons.receipt_long_rounded,
                title: '3-Month Business Bank Statements',
                description: 'Requires official PDF downloads from primary account.',
              ),
              const SizedBox(height: 16),
              _buildUpgradeRequirementRow(
                icon: Icons.history_edu_rounded,
                title: 'Corporate Tax Clearance Certificate',
                description: 'Valid TCC matching your CAC registration detail.',
              ),
              const SizedBox(height: 28),
              HighContrastButton(
                text: 'PROCEED TO UPLOAD DOCUMENTS',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Document uploader service ready. Preparing forms...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradeRequirementRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildGateItem({
    required String title,
    required String subtitle,
    required bool isVerified,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified_user : Icons.hourglass_empty_rounded,
            color: isVerified ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'APPROVED',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: AppColors.success,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
