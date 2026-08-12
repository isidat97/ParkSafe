import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../providers/admin_provider.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadRevenue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (ctx, admin, _) {
            final revenueList = admin.revenueByDate;

            final total30Days = revenueList.fold<double>(
                0, (sum, item) => sum + (item['revenue'] as double? ?? 0));

            final maxRevenue = revenueList.fold<double>(
                0,
                (max, item) =>
                    (item['revenue'] as double) > max ? item['revenue'] : max);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => admin.loadRevenue(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text('Revenue Analytics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        )),
                    const Text('Revenue trends and earnings overview',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),

                    const SizedBox(height: 20),

                    // Total 30-day Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('30-Day Total Revenue',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            AppHelpers.formatCurrency(total30Days),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on ${revenueList.length} days with bookings',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Simple Custom Bar Chart
                    const Text('Daily Revenue Trend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 12),

                    if (admin.isLoading && revenueList.isEmpty)
                      const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                    else if (revenueList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text('No revenue data available yet',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13)),
                        ),
                      )
                    else Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: SizedBox(
                                height: 160,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: revenueList.take(15).map((item) {
                                    final rev = item['revenue'] as double;
                                    final pct = maxRevenue > 0
                                        ? (rev / maxRevenue).clamp(0.05, 1.0)
                                        : 0.05;
                                    final dateStr = item['date'] as String;
                                    final dayLabel = dateStr.length >= 10
                                        ? dateStr.substring(8)
                                        : dateStr;

                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${rev.toInt()}',
                                          style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          width: 14,
                                          height: 110 * pct,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          dayLabel,
                                          style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.textMuted),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                    const SizedBox(height: 24),

                    // Daily Breakdown Table
                    const Text('Daily Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 12),

                    ...revenueList.reversed.map((item) {
                      final dateStr = item['date'] as String;
                      final rev = item['revenue'] as double;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppHelpers.formatCurrency(rev),
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
