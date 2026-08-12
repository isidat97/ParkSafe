import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';

class QrTicketScreen extends StatefulWidget {
  const QrTicketScreen({super.key});

  @override
  State<QrTicketScreen> createState() => _QrTicketScreenState();
}

class _QrTicketScreenState extends State<QrTicketScreen> {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _downloadTicketToGallery() async {
    setState(() => _isDownloading = true);
    try {
      final boundary =
          _ticketKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to capture ticket image');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception('Failed to generate image bytes');
      }

      // Save directly to native device photo gallery using gal
      await Gal.putImageBytes(pngBytes, album: 'ParkSafe Tickets');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Ticket downloaded & saved to Gallery!'),
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

    final bookingRef = qrDecoded?['booking_ref'] as String? ??
        b.id.substring(0, 8).toUpperCase();

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

                      // Ticket card wrapped in RepaintBoundary for Gallery Download
                      RepaintBoundary(
                        key: _ticketKey,
                        child: Container(
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
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'REF',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          bookingRef,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Ticket body
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // QR Code Container
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border:
                                            Border.all(color: AppColors.border),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x0A000000),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          QrImageView(
                                            data: b.qrCodeData ?? b.id,
                                            version: QrVersions.auto,
                                            size: 180,
                                            backgroundColor: Colors.white,
                                            eyeStyle: const QrEyeStyle(
                                              eyeShape: QrEyeShape.square,
                                              color: Color(0xFF0F172A),
                                            ),
                                            dataModuleStyle:
                                                const QrDataModuleStyle(
                                              dataModuleShape:
                                                  QrDataModuleShape.square,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Scan at entrance/exit gate',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Dashed separator
                                    _DashedDivider(),
                                    const SizedBox(height: 24),

                                    // Details list
                                    _TicketRow(
                                      label: 'Vehicle Number',
                                      value: b.vehicleNumber,
                                      bold: true,
                                    ),
                                    _TicketRow(
                                      label: 'Slot Assigned',
                                      value: (b.slot?.floor != null && b.slot!.floor!.isNotEmpty)
                                          ? '${b.slot!.floor} → Slot ${b.slot?.slotNumber ?? "-"}'
                                          : 'Slot ${b.slot?.slotNumber ?? "-"}',
                                      bold: true,
                                      valueColor: AppColors.primary,
                                    ),
                                    _TicketRow(
                                      label: 'Location',
                                      value: b.location?.name ?? 'Unknown',
                                    ),
                                    _TicketRow(
                                      label: 'Booking Date',
                                      value: b.bookingDate,
                                    ),
                                    _TicketRow(
                                      label: 'Scheduled Time',
                                      value:
                                          '${AppHelpers.formatTime(b.startTime)} – ${AppHelpers.formatTime(b.endTime)}',
                                    ),
                                    _TicketRow(
                                      label: 'Duration',
                                      value:
                                          '${b.totalHours.toStringAsFixed(1)} hours',
                                    ),
                                    const Divider(
                                        color: AppColors.border, height: 20),
                                    _TicketRow(
                                      label: 'Amount Paid',
                                      value: AppHelpers.formatCurrency(
                                          b.totalAmount),
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
                      ),
                      const SizedBox(height: 16),

                      // Download Ticket to Device Gallery Button
                      AppButton(
                        label: _isDownloading
                            ? 'Downloading Ticket...'
                            : 'Download Ticket to Gallery 📥',
                        color: AppColors.success,
                        icon: Icons.download_rounded,
                        onTap: _isDownloading ? null : _downloadTicketToGallery,
                      ),
                      const SizedBox(height: 16),

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
                              label: 'Share Ref',
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
