import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// State-of-the-art visual Store Analytics Dashboard for Sellers.
/// Features high-impact financial cards, custom container-drawn bar charts,
/// and a merchant recent transaction activity feed.
class StoreAnalyticsScreen extends StatelessWidget {
  const StoreAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Analytics monthly sales data mockup
    final List<Map<String, dynamic>> barChartData = [
      {'month': 'Jan', 'value': 2.4, 'heightFactor': 0.4},
      {'month': 'Feb', 'value': 3.8, 'heightFactor': 0.6},
      {'month': 'Mar', 'value': 1.9, 'heightFactor': 0.3},
      {'month': 'Apr', 'value': 5.2, 'heightFactor': 0.8},
      {'month': 'May', 'value': 6.8, 'heightFactor': 1.0}, // Peak
      {'month': 'Jun', 'value': 4.5, 'heightFactor': 0.7},
    ];

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
          'Store Analytics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // SECTION 1: CUMULATIVE SALES PERFORMANCE
            _buildSectionHeader('STORE OVERVIEW & FINANCIAL TERMINAL'),
            const SizedBox(height: 10),
            
            // Premium Large Sales Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUMULATIVE GROSS VOLUME',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₦14,204,500.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        '+18.4% volume increase this month',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics grids
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard(
                    title: 'ACTIVE VAULTS',
                    value: '3 Orders',
                    desc: '₦1,850,000 locked',
                    icon: Icons.lock_clock_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard(
                    title: 'RELEASED FUNDS',
                    value: '₦12.35M',
                    desc: '21 successful settlements',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // SECTION 2: CHARTS & HISTOGRAM TIMELINES
            _buildSectionHeader('MONTHLY SALES VOLUME (₦ IN MILLIONS)'),
            const SizedBox(height: 10),
            
            // Custom Container-Drawn Bar Graph Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // High-fidelity chart header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GROSS REVENUE PATTERNS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'H1 2026',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // The Bars Row
                  SizedBox(
                    height: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: barChartData.map((data) {
                        final double barHeight = 120.0 * (data['heightFactor'] as double);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '₦${data['value']}M',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              width: 24,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: data['month'] == 'May' ? Colors.black : Colors.black26,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['month'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // SECTION 3: RECENT STORE ACCOUNT ACTIVITY
            _buildSectionHeader('RECENT MERCHANDISING ACTIVITIES'),
            const SizedBox(height: 10),
            _buildCardGroup([
              _buildActivityRow(
                customer: 'Alex Chen',
                orderTitle: 'Rolex Daytona Ref. 116500LN',
                amount: '₦8,400,000.00',
                status: 'RELEASED',
                time: '2 hours ago',
                isReleased: true,
              ),
              const Divider(height: 24, color: AppColors.border),
              _buildActivityRow(
                customer: 'Fatima Audu',
                orderTitle: 'MacBook Pro M3 Max 16"',
                amount: '₦2,350,000.00',
                status: 'RELEASED',
                time: 'Yesterday',
                isReleased: true,
              ),
              const Divider(height: 24, color: AppColors.border),
              _buildActivityRow(
                customer: 'Chinedu Eze',
                orderTitle: 'Sony FX3 Cinema Camera',
                amount: '₦1,850,000.00',
                status: 'SHIPPED',
                time: 'May 28, 2026',
                isReleased: false,
              ),
            ]),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: Colors.black54, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required String customer,
    required String orderTitle,
    required String amount,
    required String status,
    required String time,
    required bool isReleased,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              customer.split(' ').map((e) => e[0].toUpperCase()).join(''),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Customer: $customer • $time',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isReleased ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: isReleased ? Colors.green.shade800 : Colors.orange.shade800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
