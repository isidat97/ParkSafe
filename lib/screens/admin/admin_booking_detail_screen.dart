import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/booking.dart';
import '../../data/repositories/notification_repository.dart';
import '../../providers/admin_provider.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const AdminBookingDetailScreen({super.key, required this.bookingId});

  @override
  State<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadBookingById(widget.bookingId);
    });
  }

  Future<void> _checkIn(AdminProvider admin) async {
    final booking = admin.scannedBooking;
    if (booking == null) return;

    final confirm = await _confirm('Check In',
        'Mark vehicle ${booking.vehicleNumber} as checked in?', AppColors.accent);
    if (!confirm) return;

    final result = await admin.checkIn(booking.id);
    final isSuccess = result['success'] == true;
    final msg = result['message'] as String? ?? (isSuccess ? 'Checked in successfully!' : 'Check-in failed');

    if (mounted) {
      _toast(msg, isSuccess ? AppColors.success : AppColors.error);
    }
  }

  Future<void> _checkOut(AdminProvider admin) async {
    final booking = admin.scannedBooking;
    if (booking == null) return;

    final confirm = await _confirm('Check Out',
        'Mark vehicle ${booking.vehicleNumber} as checked out (completed)?',
        AppColors.primary);
    if (!confirm) return;

    final success = await admin.checkOut(booking.id);
    if (mounted) {
      _toast(success ? 'Checked out successfully!' : 'Check-out failed',
          success ? AppColors.success : AppColors.error);
    }
  }

  Future<void> _acceptRefund(AdminProvider admin) async {
    final booking = admin.scannedBooking;
    if (booking == null) return;

    final confirm = await _confirm(
      'Accept Refund',
      'Approve and refund ₹${booking.totalAmount.toStringAsFixed(2)} to customer?',
      AppColors.success,
    );
    if (!confirm) return;

    final success = await admin.processRefund(
      bookingId: booking.id,
      refundStatus: 'approved',
      reason: 'Refund approved by admin.',
    );

    if (success) {
      // Create notification for customer
      try {
        await NotificationRepository().createNotification(
          userId: booking.userId,
          title: 'Refund Approved! 💰',
          body:
              'Your refund request of ₹${booking.totalAmount.toStringAsFixed(2)} for ${booking.location?.name ?? "booking"} has been approved.',
          type: 'refund',
        );
      } catch (_) {}
    }

    if (mounted) {
      _toast(
        success ? 'Refund request approved successfully!' : 'Refund approval failed',
        success ? AppColors.success : AppColors.error,
      );
    }
  }

  Future<void> _rejectRefund(AdminProvider admin) async {
    final booking = admin.scannedBooking;
    if (booking == null) return;

    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Refund Request',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify reason for rejecting this refund request:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Reason for rejection...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.bgDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Reject Refund',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final reason = reasonCtrl.text.trim().isEmpty
        ? 'Refund request does not meet eligibility criteria.'
        : reasonCtrl.text.trim();

    final success = await admin.processRefund(
      bookingId: booking.id,
      refundStatus: 'rejected',
      reason: reason,
    );

    if (success) {
      // Create notification for customer
      try {
        await NotificationRepository().createNotification(
          userId: booking.userId,
          title: 'Refund Request Declined ❌',
          body:
              'Your refund request for ${booking.location?.name ?? "booking"} was rejected. Reason: $reason',
          type: 'refund',
        );
      } catch (_) {}
    }

    if (mounted) {
      _toast(
        success ? 'Refund request rejected.' : 'Operation failed',
        success ? AppColors.warning : AppColors.error,
      );
    }
  }

  Future<bool> _confirm(String title, String message, Color color) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(message,
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _toast(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (ctx, admin, _) {
            if (admin.isScanLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final booking = admin.scannedBooking;
            final user = admin.scannedUser;

            if (booking == null) {
              return const Center(
                child: Text('Booking not found',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }

            return Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary),
                      ),
                      const Expanded(
                        child: Text('Booking Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            )),
                      ),
                      _StatusChip(status: booking.status),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        // Booking status banner
                        _StatusBanner(status: booking.status),
                        const SizedBox(height: 16),

                        // Customer details
                        _Section(
                          icon: Icons.person_rounded,
                          title: 'Customer Details',
                          iconColor: AppColors.info,
                          children: [
                            _Row('Name', user?.fullName ?? 'Unknown'),
                            _Row('Phone', user?.phone ?? 'N/A'),
                            _Row('Customer ID', '${booking.userId.substring(0, 8)}...'),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Vehicle details
                        _Section(
                          icon: Icons.directions_car_rounded,
                          title: 'Vehicle Details',
                          iconColor: AppColors.accent,
                          children: [
                            _Row('Vehicle Number', booking.vehicleNumber),
                            _Row('Slot Type',
                                AppHelpers.getSlotTypeLabel(
                                    booking.slot?.slotType ?? 'car')),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Scheduled Booking details
                        _Section(
                          icon: Icons.receipt_long_rounded,
                          title: 'Scheduled Booking Details',
                          iconColor: AppColors.primary,
                          children: [
                            _Row('Booking ID', booking.id),
                            _Row('Booking Date', booking.bookingDate),
                            _Row('Scheduled Check-In',
                                AppHelpers.formatTime(booking.startTime)),
                            _Row('Scheduled Check-Out',
                                AppHelpers.formatTime(booking.endTime)),
                            _Row('Scheduled Duration',
                                '${booking.totalHours.toStringAsFixed(1)} hours'),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Actual Check-In / Check-Out & Overtime Section
                        _Section(
                          icon: Icons.access_time_filled_rounded,
                          title: 'Actual Timestamps & Overtime',
                          iconColor: AppColors.accent,
                          children: [
                            _Row(
                              'Actual Check-In',
                              booking.actualCheckIn != null
                                  ? AppHelpers.formatTimeFromDateTime(
                                      booking.actualCheckIn!.toLocal())
                                  : 'Not Checked In Yet',
                              valueColor: booking.actualCheckIn != null
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                            ),
                            if (booking.actualCheckIn != null &&
                                booking.scheduledStartDateTime != null) ...[
                              Builder(builder: (_) {
                                final actualIn = booking.actualCheckIn!.toLocal();
                                final schedStart =
                                    booking.scheduledStartDateTime!.toLocal();
                                final diff =
                                    actualIn.difference(schedStart).inMinutes;
                                String statusText;
                                Color statusColor;
                                if (diff < 0) {
                                  statusText =
                                      'Checked in ${diff.abs()} mins early';
                                  statusColor = AppColors.success;
                                } else if (diff > 0) {
                                  statusText = 'Checked in $diff mins late';
                                  statusColor = AppColors.warning;
                                } else {
                                  statusText = 'On Time';
                                  statusColor = AppColors.success;
                                }
                                return _Row(
                                    'Check-In Status', statusText,
                                    valueColor: statusColor);
                              }),
                            ],
                            const SizedBox(height: 6),
                            _Row(
                              'Actual Check-Out',
                              booking.actualCheckOut != null
                                  ? AppHelpers.formatTimeFromDateTime(
                                      booking.actualCheckOut!.toLocal())
                                  : 'Not Checked Out Yet',
                              valueColor: booking.actualCheckOut != null
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                            if (booking.actualCheckOut != null &&
                                booking.scheduledEndDateTime != null) ...[
                              Builder(builder: (_) {
                                final actualOut =
                                    booking.actualCheckOut!.toLocal();
                                final schedEnd =
                                    booking.scheduledEndDateTime!.toLocal();
                                final diff =
                                    actualOut.difference(schedEnd).inMinutes;
                                String statusText;
                                Color statusColor;
                                if (diff > 0) {
                                  statusText = 'Overtime ($diff mins late)';
                                  statusColor = AppColors.error;
                                } else if (diff < 0) {
                                  statusText =
                                      'Checked out ${diff.abs()} mins early';
                                  statusColor = AppColors.success;
                                } else {
                                  statusText = 'On Time';
                                  statusColor = AppColors.success;
                                }
                                return _Row(
                                    'Check-Out Status', statusText,
                                    valueColor: statusColor);
                              }),
                            ] else if (booking.actualCheckOut == null &&
                                booking.scheduledEndDateTime != null) ...[
                              Builder(builder: (_) {
                                final now = DateTime.now();
                                final schedEnd =
                                    booking.scheduledEndDateTime!.toLocal();
                                if (now.isAfter(schedEnd)) {
                                  final diff =
                                      now.difference(schedEnd).inMinutes;
                                  return _Row(
                                    'Check-Out Status',
                                    'Overtime ($diff mins late)',
                                    valueColor: AppColors.error,
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                            if (booking.actualCheckIn != null &&
                                booking.actualCheckOut != null) ...[
                              const SizedBox(height: 6),
                              Builder(builder: (_) {
                                final stayMins = booking.actualCheckOut!
                                    .toLocal()
                                    .difference(booking.actualCheckIn!.toLocal())
                                    .inMinutes;
                                String stayText;
                                if (stayMins < 60) {
                                  stayText =
                                      '$stayMins minute${stayMins == 1 ? '' : 's'}';
                                } else {
                                  final h = stayMins ~/ 60;
                                  final m = stayMins % 60;
                                  stayText =
                                      m > 0 ? '$h hr $m mins' : '$h hours';
                                }
                                return _Row('Actual Duration', stayText,
                                    valueColor: AppColors.textPrimary);
                              }),
                            ],
                            const Divider(color: AppColors.border, height: 20),
                            _Row(
                              'Overtime Penalty',
                              booking.hasOvertime
                                  ? '₹${booking.effectiveOvertimeFee.toStringAsFixed(2)} (${booking.overtimeMinutes} mins late · 1-hr rate)'
                                  : '₹0.00 (On Time)',
                              valueColor: booking.hasOvertime
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ],
                        ),


                        const SizedBox(height: 12),

                        // Parking details
                        _Section(
                          icon: Icons.local_parking_rounded,
                          title: 'Parking Details',
                          iconColor: AppColors.success,
                          children: [
                            _Row('Location',
                                booking.location?.name ?? 'Unknown'),
                            _Row('Address',
                                booking.location?.address ?? 'N/A'),
                            _Row('Slot Number',
                                (booking.slot?.floor != null && booking.slot!.floor!.isNotEmpty)
                                    ? '${booking.slot!.floor} · Slot ${booking.slot?.slotNumber ?? '-'}'
                                    : (booking.slot?.slotNumber ?? '-')),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Payment details
                        _Section(
                          icon: Icons.payment_rounded,
                          title: 'Payment Details',
                          iconColor: AppColors.warning,
                          children: [
                            _Row(
                              'Base Amount',
                              AppHelpers.formatCurrency(booking.totalAmount),
                              valueColor: AppColors.textPrimary,
                            ),
                            if (booking.hasOvertime)
                              _Row(
                                'Overtime Penalty',
                                '₹${booking.effectiveOvertimeFee.toStringAsFixed(2)}',
                                valueColor: AppColors.error,
                              ),
                            _Row(
                              'Grand Total',
                              AppHelpers.formatCurrency(
                                  booking.totalAmount + booking.effectiveOvertimeFee),
                              valueColor: AppColors.success,
                            ),
                            _Row('Payment Status',
                                booking.paymentStatus.toUpperCase(),
                                valueColor: booking.paymentStatus == 'paid'
                                    ? AppColors.success
                                    : AppColors.warning),
                            if (booking.paymentId != null)
                              _Row('Payment ID', booking.paymentId!),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),

                // Action bar
                _ActionBar(
                  booking: booking,
                  onCheckIn: () => _checkIn(admin),
                  onCheckOut: () => _checkOut(admin),
                  onAcceptRefund: () => _acceptRefund(admin),
                  onRejectRefund: () => _rejectRefund(admin),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'checked_in':
        color = AppColors.accent;
        icon = Icons.login_rounded;
        label = 'Vehicle is currently checked in';
        break;
      case 'completed':
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = 'Booking completed successfully';
        break;
      case 'confirmed':
        color = AppColors.info;
        icon = Icons.verified_rounded;
        label = 'Booking confirmed — ready for check-in';
        break;
      case 'cancelled':
        color = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'This booking has been cancelled';
        break;
      default:
        color = AppColors.warning;
        icon = Icons.pending_rounded;
        label = 'Booking is pending payment';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'checked_in':
        color = AppColors.accent;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'confirmed':
        color = AppColors.info;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status == 'checked_in' ? 'CHECKED IN' : status.toUpperCase(),
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onAcceptRefund;
  final VoidCallback onRejectRefund;

  const _ActionBar({
    required this.booking,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onAcceptRefund,
    required this.onRejectRefund,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final isRefundRequested = booking.refundStatus == 'requested';
    final canCheckIn = status == 'confirmed' || status == 'pending';
    final canCheckOut = status == 'checked_in';
    final isDone = status == 'completed' || status == 'cancelled';

    if (isRefundRequested) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer requested refund: ₹${booking.refundAmount.toStringAsFixed(2)}${booking.refundReason != null ? " (${booking.refundReason})" : ""}',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRejectRefund,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject Refund',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAcceptRefund,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Accept Refund',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (isDone) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == 'completed'
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: status == 'completed'
                    ? AppColors.success
                    : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                status == 'completed'
                    ? 'Booking Completed'
                    : 'Booking Cancelled',
                style: TextStyle(
                  color: status == 'completed'
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (canCheckIn)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCheckIn,
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Check In',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          if (canCheckOut)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCheckOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Check Out',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
