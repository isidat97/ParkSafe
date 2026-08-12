import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/booking.dart';
import '../../providers/admin_provider.dart';
import 'admin_booking_detail_screen.dart';

class AdminRefundsScreen extends StatefulWidget {
  const AdminRefundsScreen({super.key});

  @override
  State<AdminRefundsScreen> createState() => _AdminRefundsScreenState();
}

class _AdminRefundsScreenState extends State<AdminRefundsScreen> {
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
            final allRefundBookings = admin.allBookings
                .where((b) => b.refundStatus != 'none')
                .toList();

            // Filter logic
            final filtered = allRefundBookings.where((b) {
              final matchesStatus = _selectedStatus == 'all'
                  ? true
                  : b.refundStatus == _selectedStatus;
              
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
                          const Text('Refund Requests',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              )),
                          const Spacer(),
                          Text('${filtered.length} of ${allRefundBookings.length}',
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
                      'requested',
                      'approved',
                      'rejected',
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
                  child: admin.isLoading && allRefundBookings.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : filtered.isEmpty
                          ? const Center(
                              child: Text('No refund requests found',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final b = filtered[i];
                                return _RefundAdminTile(
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
      case 'requested':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return st;
    }
  }
}

class _RefundAdminTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _RefundAdminTile({required this.booking, required this.onTap});

  Color _getRefundStatusColor() {
    switch (booking.refundStatus) {
      case 'approved':
      case 'refunded':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'requested':
      default:
        return AppColors.accent;
    }
  }

  String _getRefundStatusLabel() {
    switch (booking.refundStatus) {
      case 'approved':
      case 'refunded':
        return 'APPROVED';
      case 'rejected':
        return 'REJECTED';
      case 'requested':
      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getRefundStatusColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
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
                          _getRefundStatusLabel(),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppHelpers.formatCurrency(booking.refundAmount),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${booking.location?.name ?? "Unknown"} · ${(booking.slot?.floor != null && booking.slot!.floor!.isNotEmpty) ? '${booking.slot!.floor} · ' : ''}Slot ${booking.slot?.slotNumber ?? "-"} · ${booking.bookingDate}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
            if (booking.refundReason != null && booking.refundReason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.refundReason!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
