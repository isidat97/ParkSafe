import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'booking_detail_screen.dart';

class CustomerRefundsScreen extends StatefulWidget {
  const CustomerRefundsScreen({super.key});

  @override
  State<CustomerRefundsScreen> createState() => _CustomerRefundsScreenState();
}

class _CustomerRefundsScreenState extends State<CustomerRefundsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().profile?.id ?? '';
      context.read<BookingProvider>().loadUserBookings(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().profile?.id ?? '';
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'My Refunds',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        context.read<BookingProvider>().loadUserBookings(userId),
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Consumer<BookingProvider>(
                builder: (ctx, booking, _) {
                  if (booking.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  
                  final refundBookings = booking.bookings
                      .where((b) => b.refundStatus != 'none')
                      .toList();

                  if (refundBookings.isEmpty) {
                    return const EmptyState(
                      icon: Icons.currency_rupee_rounded,
                      title: 'No Refunds',
                      subtitle: 'You have not requested any refunds yet',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: refundBookings.length,
                    itemBuilder: (ctx, i) => _RefundCard(booking: refundBookings[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefundCard extends StatelessWidget {
  final Booking booking;

  const _RefundCard({required this.booking});

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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.location?.name ?? 'Parking',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    _getRefundStatusLabel(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.currency_rupee_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Refund Amount: ₹${booking.refundAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (booking.refundStatus == 'requested' && booking.refundReason != null && booking.refundReason!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Your Reason: ${booking.refundReason}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (booking.refundStatus == 'rejected') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Rejected by Admin: ${booking.refundReason ?? "No reason provided"}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ] else if (booking.refundStatus == 'approved' || booking.refundStatus == 'refunded') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Approved by Admin',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
