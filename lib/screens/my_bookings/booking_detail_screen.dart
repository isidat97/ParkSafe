import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/feedback_dialog.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final GlobalKey _detailTicketKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _downloadTicketToGallery() async {
    setState(() => _isDownloading = true);
    try {
      final boundary = _detailTicketKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to capture ticket image');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception('Failed to generate image bytes');
      }

      await Gal.putImageBytes(pngBytes, album: 'ParkSafe Tickets');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Ticket saved to Gallery!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save ticket: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    Map<String, dynamic>? qrData;
    try {
      qrData = jsonDecode(booking.qrCodeData ?? '{}') as Map<String, dynamic>;
    } catch (_) {}
    final bookingRef = qrData?['booking_ref'] as String? ??
        booking.id.substring(0, 8).toUpperCase();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                    ),
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: booking.status),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Location & Ticket info wrapped in RepaintBoundary for download
                      RepaintBoundary(
                        key: _detailTicketKey,
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              // Location info
                              GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                              Icons.local_parking_rounded,
                                              color: Colors.white,
                                              size: 26),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                booking.location?.name ??
                                                    'Parking Location',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                booking.location?.address ?? '',
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (booking.location != null) ...[
                                      const SizedBox(height: 12),
                                      const Divider(color: AppColors.border),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            AppHelpers.openGoogleMaps(
                                              googleMapsLink: booking
                                                  .location!.googleMapsLink,
                                              locationName:
                                                  booking.location!.name,
                                              locationAddress:
                                                  booking.location!.address,
                                              lat: booking.location!.lat,
                                              lng: booking.location!.lng,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.directions_rounded,
                                              size: 18),
                                          label: const Text('Open Directions',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(
                                                color: AppColors.primary),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (booking.hasOvertime) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: AppColors.error.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          color: AppColors.error, size: 26),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Overtime Penalty Applicable ⚠️',
                                              style: TextStyle(
                                                color: AppColors.error,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Booked until ${AppHelpers.formatTime(booking.endTime)}. Late by ${booking.overtimeMinutes} mins. Penalty of ₹${booking.effectiveOvertimeFee.toStringAsFixed(2)} charged.',
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Booking details
                              GlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Booking Info',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _DetailRow(
                                        label: 'Ref No', value: bookingRef),
                                    _DetailRow(
                                        label: 'Slot',
                                        value: (booking.slot?.floor != null && booking.slot!.floor!.isNotEmpty)
                                            ? '${booking.slot!.floor} · Slot ${booking.slot?.slotNumber ?? '-'}'
                                            : (booking.slot?.slotNumber ?? '-')),
                                    _DetailRow(
                                        label: 'Vehicle',
                                        value: booking.vehicleNumber),
                                    _DetailRow(
                                        label: 'Date',
                                        value: booking.bookingDate),
                                    _DetailRow(
                                        label: 'Scheduled From',
                                        value: AppHelpers.formatTime(
                                            booking.startTime)),
                                    _DetailRow(
                                        label: 'Scheduled To',
                                        value: AppHelpers.formatTime(
                                            booking.endTime)),
                                    _DetailRow(
                                        label: 'Booked Duration',
                                        value:
                                            '${booking.totalHours.toStringAsFixed(1)} hours'),

                                    // Actual Check-In / Check-Out
                                    if (booking.actualCheckIn != null ||
                                        booking.actualCheckOut != null ||
                                        booking.hasOvertime) ...[
                                      const Divider(
                                          color: AppColors.border, height: 20),
                                      const Text(
                                        'Actual Activity',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (booking.actualCheckIn != null) ...[
                                        _DetailRow(
                                          label: 'Actual Check-In',
                                          value: AppHelpers
                                              .formatTimeFromDateTime(booking
                                                  .actualCheckIn!
                                                  .toLocal()),
                                          valueColor: AppColors.accent,
                                        ),
                                      ],
                                      if (booking.actualCheckOut != null) ...[
                                        const SizedBox(height: 4),
                                        _DetailRow(
                                          label: 'Actual Check-Out',
                                          value: AppHelpers
                                              .formatTimeFromDateTime(booking
                                                  .actualCheckOut!
                                                  .toLocal()),
                                          valueColor: AppColors.success,
                                        ),
                                      ],
                                    ],

                                    const Divider(
                                        color: AppColors.border, height: 20),
                                    _DetailRow(
                                        label: 'Base Amount',
                                        value:
                                            '₹${booking.totalAmount.toStringAsFixed(2)}',
                                        valueColor: AppColors.textPrimary),
                                    if (booking.hasOvertime) ...[
                                      _DetailRow(
                                          label: 'Overtime Penalty ⚠️',
                                          value:
                                              '₹${booking.effectiveOvertimeFee.toStringAsFixed(2)}',
                                          valueColor: AppColors.error),
                                      _DetailRow(
                                          label: 'Total Amount',
                                          value:
                                              '₹${(booking.totalAmount + booking.effectiveOvertimeFee).toStringAsFixed(2)}',
                                          valueColor: AppColors.success),
                                    ] else ...[
                                      _DetailRow(
                                          label: 'Payment Status',
                                          value: booking.paymentStatus
                                              .toUpperCase(),
                                          valueColor:
                                              booking.paymentStatus == 'paid'
                                                  ? AppColors.success
                                                  : AppColors.warning),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // QR Code (if confirmed or checked_in)
                              if ((booking.status == 'confirmed' ||
                                      booking.status == 'checked_in') &&
                                  booking.qrCodeData != null) ...[
                                GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Your Entry QR Code',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Show this at the parking gate',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: QrImageView(
                                          data: booking.qrCodeData!,
                                          version: QrVersions.auto,
                                          size: 180,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Time Extension Button
                      if (booking.status == 'confirmed' ||
                          booking.status == 'checked_in') ...[
                        AppButton(
                          label: 'Extend Booking Duration',
                          isOutlined: true,
                          color: AppColors.primary,
                          onTap: () => _showExtensionModal(context, booking),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Refund Status Card
                      if (booking.refundStatus != 'none') ...[
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (booking.refundStatus == 'approved' ||
                                          booking.refundStatus == 'refunded')
                                      ? AppColors.success.withOpacity(0.15)
                                      : AppColors.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.currency_rupee_rounded,
                                  color: (booking.refundStatus == 'approved' ||
                                          booking.refundStatus == 'refunded')
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Refund Status: ${booking.refundStatus.toUpperCase()}',
                                      style: TextStyle(
                                        color: (booking.refundStatus ==
                                                    'approved' ||
                                                booking.refundStatus ==
                                                    'refunded')
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Refund Amount: ₹${booking.refundAmount.toStringAsFixed(2)}${booking.refundReason != null ? " · Reason: ${booking.refundReason}" : ""}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Download Ticket Button
                      AppButton(
                        label: _isDownloading
                            ? 'Downloading Ticket...'
                            : 'Download Ticket to Gallery 📥',
                        color: AppColors.primary,
                        icon: Icons.download_rounded,
                        onTap: _isDownloading ? null : _downloadTicketToGallery,
                      ),
                      const SizedBox(height: 16),

                      // Leave Feedback Button (if booking status is completed)
                      if (booking.status == 'completed') ...[
                        AppButton(
                          label: 'Submit Customer Feedback ⭐',
                          isOutlined: true,
                          color: AppColors.accent,
                          icon: Icons.rate_review_rounded,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => CustomerFeedbackDialog(
                                userId: booking.userId,
                                bookingId: booking.id,
                                locationId: booking.location?.id,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Cancel & Refund button
                      if (booking.status == 'confirmed' ||
                          booking.status == 'pending')
                        AppButton(
                          label: 'Cancel Booking & Request Refund',
                          isOutlined: true,
                          color: AppColors.error,
                          onTap: () async {
                            final reasonCtrl = TextEditingController();
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.bgCard,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('Cancel & Request Refund',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cancelling will request a 100% refund of ₹${booking.totalAmount.toStringAsFixed(2)} to your account.',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 14),
                                    TextField(
                                      controller: reasonCtrl,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Reason for cancellation...',
                                        hintStyle: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12),
                                        filled: true,
                                        fillColor: AppColors.bgDark,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.border),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Keep Booking'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: Colors.white),
                                    child: const Text('Cancel & Refund',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              final reason = reasonCtrl.text.trim().isEmpty
                                  ? 'Customer requested cancellation'
                                  : reasonCtrl.text.trim();

                              final success = await context
                                  .read<BookingProvider>()
                                  .requestRefund(
                                    bookingId: booking.id,
                                    amount: booking.totalAmount,
                                    reason: reason,
                                  );

                              if (context.mounted) {
                                if (success) {
                                  context
                                      .read<NotificationProvider>()
                                      .addNotification(
                                        userId: booking.userId,
                                        title: 'Refund Request Submitted',
                                        body:
                                            'Your refund request of ₹${booking.totalAmount.toStringAsFixed(2)} for ${booking.location?.name ?? "booking"} has been submitted.',
                                        type: 'refund',
                                      );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Booking cancelled. Refund request of 100% amount submitted successfully!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to cancel booking. Please try again.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExtensionModal(BuildContext context, Booking booking) {
    double selectedHours = 1.0;
    final pricePerHour = booking.location?.pricePerHour ?? 50.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final additionalAmount = selectedHours * pricePerHour;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_time_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Extend Booking Duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select additional hours to extend your parking slot reservation:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: [1.0, 2.0, 3.0, 4.0, 5.0].map((h) {
                    final isSel = selectedHours == h;
                    return ChoiceChip(
                      label: Text('+${h.toInt()} Hour${h > 1 ? 's' : ''}'),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.bgSurface2,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => selectedHours = h);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Extension Fee',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 11)),
                          Text('₹${pricePerHour.toStringAsFixed(0)}/hr rate',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                      Text(
                        '₹${additionalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Confirm & Pay Extension',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final success = await context
                        .read<BookingProvider>()
                        .extendBooking(
                          bookingId: booking.id,
                          additionalHours: selectedHours,
                          pricePerHour: pricePerHour,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Booking extended by ${selectedHours.toInt()} hr(s) successfully!'
                              : 'Failed to extend booking'),
                          backgroundColor:
                              success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
