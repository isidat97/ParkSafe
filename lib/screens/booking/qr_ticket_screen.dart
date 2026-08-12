import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';

class QrTicketScreen extends StatelessWidget {
  const QrTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final b = booking.currentBooking;
    if (b == null) {
      return const Scaffold(
        body: Center(child: Text('No booking found')),
      );
    }

    Map<String, dynamic>? qrDecoded;
    try {
      qrDecoded = jsonDecode(b.qrCodeData ?? '{}') as Map<String, dynamic>;
    } catch (_) {}

    final bookingRef = qrDecoded?['booking_ref'] as String? ?? b.id.substring(0, 8).toUpperCase();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Booking Confirmed! 🎉',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        booking.reset();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (r) => false);
                      },
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Success animation
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.5),
                              width: 2),
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 40),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Payment Successful',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ticket card
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Ticket header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_parking_rounded,
                                      color: Colors.white, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ParkSafe',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'Parking Ticket',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Ref No.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        bookingRef,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Dashed separator
                            _DashedDivider(),

                            // QR code
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: QrImageView(
                                      data: b.qrCodeData ?? b.id,
                                      version: QrVersions.auto,
                                      size: 200,
                                      backgroundColor: Colors.white,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: Color(0xFF0A0E1A),
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.square,
                                        color: Color(0xFF0A0E1A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (b.paymentId?.startsWith('FT-') ?? false) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6D00).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFFF6D00).withOpacity(0.5)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.nfc_rounded,
                                              color: Color(0xFFFF6D00), size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            'NETC FASTag Auto-Scan Enabled',
                                            style: TextStyle(
                                              color: Color(0xFFFF6D00),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Windshield FASTag will auto-scan at parking gate barrier',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ] else
                                    const Text(
                                      'Scan QR code at parking gate',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Dashed separator
                            _DashedDivider(),

                            // Details
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _TicketRow(
                                    label: 'Slot',
                                    value: b.slot?.slotNumber ?? '-',
                                  ),
                                  _TicketRow(
                                    label: 'Vehicle',
                                    value: b.vehicleNumber,
                                  ),
                                  _TicketRow(
                                    label: 'Date',
                                    value: b.bookingDate,
                                  ),
                                  _TicketRow(
                                    label: 'Time',
                                    value:
                                        '${AppHelpers.formatTime(b.startTime)} – ${AppHelpers.formatTime(b.endTime)}',
                                  ),
                                  _TicketRow(
                                    label: 'Duration',
                                    value:
                                        '${b.totalHours.toStringAsFixed(1)} hours',
                                  ),
                                  _TicketRow(
                                    label: 'Payment Method',
                                    value: (b.paymentId?.startsWith('FT-') ?? false)
                                        ? 'NETC FASTag (RFID)'
                                        : 'Online Payment',
                                    valueColor: (b.paymentId?.startsWith('FT-') ?? false)
                                        ? const Color(0xFFFF6D00)
                                        : AppColors.textPrimary,
                                  ),
                                  const Divider(color: AppColors.border),
                                  _TicketRow(
                                    label: 'Amount Paid',
                                    value:
                                        '₹${b.totalAmount.toStringAsFixed(2)}',
                                    valueColor: AppColors.success,
                                    bold: true,
                                  ),
                                  const _TicketRow(
                                    label: 'Status',
                                    value: 'Confirmed',
                                    valueColor: AppColors.success,
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Get Directions Button
                      if (b.location != null) ...[
                        AppButton(
                          label: 'Get Directions in Google Maps',
                          icon: Icons.directions_rounded,
                          color: AppColors.primary,
                          onTap: () {
                            AppHelpers.openGoogleMaps(
                              googleMapsLink: b.location!.googleMapsLink,
                              locationName: b.location!.name,
                              locationAddress: b.location!.address,
                              lat: b.location!.lat,
                              lng: b.location!.lng,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Share',
                              isOutlined: true,
                              icon: Icons.share_rounded,
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: 'Booking Ref: $bookingRef'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Booking ref copied!')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Done',
                              onTap: () {
                                booking.reset();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (r) => false);
                              },
                            ),
                          ),
                        ],
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
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashPainter(),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TicketRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _TicketRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
