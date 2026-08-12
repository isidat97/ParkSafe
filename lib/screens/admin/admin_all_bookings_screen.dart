import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/booking.dart';
import '../../providers/admin_provider.dart';
import 'admin_booking_detail_screen.dart';

class AdminAllBookingsScreen extends StatefulWidget {
  const AdminAllBookingsScreen({super.key});

  @override
  State<AdminAllBookingsScreen> createState() => _AdminAllBookingsScreenState();
}

class _AdminAllBookingsScreenState extends State<AdminAllBookingsScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (ctx, admin, _) {
            final all = admin.allBookings;

            // Filter logic
            final filtered = all.where((b) {
              final matchesStatus = _selectedStatus == 'all'
                  ? true
                  : _selectedStatus == 'refund_requested'
                      ? (b.refundStatus == 'requested' || b.refundStatus == 'approved' || b.refundStatus == 'refunded')
                      : b.status.toLowerCase() == _selectedStatus;
              final q = _searchQuery.toLowerCase();
              final matchesSearch = q.isEmpty ||
                  b.vehicleNumber.toLowerCase().contains(q) ||
                  b.id.toLowerCase().contains(q) ||
                  (b.location?.name.toLowerCase().contains(q) ?? false);
              return matchesStatus && matchesSearch;
            }).toList();

            return Column(
              children: [
                // Header & Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('All Bookings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              )),
                          const Spacer(),
                          Text('${filtered.length} of ${all.length}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search by vehicle, location, ID...',
                          hintStyle: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: AppColors.bgCard,
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textMuted, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      'all',
                      'refund_requested',
                      'confirmed',
                      'checked_in',
                      'completed',
                      'cancelled',
                      'pending'
                    ].map((st) {
                      final selected = _selectedStatus == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_statusFilterLabel(st)),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.bgCard,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          onSelected: (_) => setState(() => _selectedStatus = st),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // List
                Expanded(
                  child: admin.isLoading && all.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : filtered.isEmpty
                          ? const Center(
                              child: Text('No matching bookings found',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final b = filtered[i];
                                return _BookingTile(
                                  booking: b,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminBookingDetailScreen(
                                            bookingId: b.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusFilterLabel(String st) {
    switch (st) {
      case 'all':
        return 'All';
      case 'refund_requested':
        return 'Refund Requests';
      case 'checked_in':
        return 'Checked In';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return st;
    }
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                booking.slot?.slotType == 'bike'
                    ? Icons.two_wheeler_rounded
                    : booking.slot?.slotType == 'ev'
                        ? Icons.electric_car_rounded
                        : Icons.directions_car_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(booking.status),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${booking.location?.name ?? "Unknown"} · Slot ${booking.slot?.slotNumber ?? "-"} · ${booking.bookingDate}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppHelpers.formatCurrency(booking.totalAmount),
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 18),
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
