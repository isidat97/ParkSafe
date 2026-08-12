import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../providers/admin_provider.dart';
import '../../data/models/booking.dart';
import 'admin_booking_detail_screen.dart';
import 'admin_add_location_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>()
        ..loadDashboardStats()
        ..loadTodaysBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            final adminProvider = context.read<AdminProvider>();
            await adminProvider.loadDashboardStats();
            await adminProvider.loadTodaysBookings();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Consumer<AdminProvider>(
              builder: (ctx, admin, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Admin Dashboard',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.4,
                                  )),
                              Text('ParkSafe Control Panel',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminAddLocationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_location_alt_rounded,
                              size: 16),
                          label: const Text('Add Place',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats Grid
                    if (admin.isLoading && admin.dashboardStats.isEmpty)
                      const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                    else
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: [
                          _StatCard(
                            icon: Icons.today_rounded,
                            iconColor: AppColors.info,
                            label: "Today's Bookings",
                            value: '${admin.dashboardStats['today_count'] ?? 0}',
                          ),
                          _StatCard(
                            icon: Icons.currency_rupee_rounded,
                            iconColor: AppColors.success,
                            label: 'Revenue Today',
                            value: AppHelpers.formatCurrency(
                                (admin.dashboardStats['revenue_today'] as num?)
                                        ?.toDouble() ??
                                    0),
                          ),
                          _StatCard(
                            icon: Icons.directions_car_rounded,
                            iconColor: AppColors.accent,
                            label: 'Checked In',
                            value:
                                '${admin.dashboardStats['checked_in_count'] ?? 0}',
                          ),
                          _StatCard(
                            icon: Icons.local_parking_rounded,
                            iconColor: AppColors.primary,
                            label: 'Total Slots',
                            value:
                                '${admin.dashboardStats['total_slots'] ?? 0}',
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Total revenue card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Revenue (All Time)',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            AppHelpers.formatCurrency(
                                (admin.dashboardStats['total_revenue'] as num?)
                                        ?.toDouble() ??
                                    0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('From all confirmed bookings',
                              style:
                                  TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Today's bookings section
                    Row(
                      children: [
                        const Text("Today's Bookings",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            )),
                        const Spacer(),
                        Text('${admin.todaysBookings.length} total',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (admin.todaysBookings.isEmpty)
                      _EmptyToday()
                    else
                      ...admin.todaysBookings.take(5).map((b) => _BookingRow(
                            booking: b,
                            onTap: () => _openDetail(b),
                          )),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(Booking b) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AdminBookingDetailScreen(bookingId: b.id)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F14181B), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingRow({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.vehicleNumber.isNotEmpty
                        ? booking.vehicleNumber
                        : 'N/A',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Text(
                    '${booking.location?.name ?? "Unknown"} · Slot ${booking.slot?.slotNumber ?? "-"}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppHelpers.formatCurrency(booking.totalAmount),
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.info;
      case 'checked_in':
        return AppColors.accent;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'checked_in':
        return 'CHECKED IN';
      case 'completed':
        return 'COMPLETED';
      case 'confirmed':
        return 'CONFIRMED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }
}

class _EmptyToday extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text('No bookings for today',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
      ),
    );
  }
}
