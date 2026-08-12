import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../core/utils/app_helpers.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanning = true;
  bool _isProcessing = false;
  Booking? _scannedBooking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScanner();
  }

  Future<void> _initScanner() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
    _startScanner();
  }

  Future<void> _startScanner() async {
    try {
      await _controller.start();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndResume();
    }
  }

  Future<void> _checkPermissionAndResume() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _startScanner();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() {
      _scanning = false;
      _isProcessing = true;
    });

    final qrData = barcode!.rawValue!;
    final booking = await context.read<BookingProvider>().getBookingByQr(qrData);

    setState(() {
      _isProcessing = false;
      _scannedBooking = booking;
    });
  }

  void _reset() {
    setState(() {
      _scanning = true;
      _scannedBooking = null;
    });
    _startScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'QR Scanner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (!_scanning)
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          size: 18),
                      label: const Text('Scan Again'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_scannedBooking != null)
              Expanded(child: _ScannedResult(booking: _scannedBooking!))
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              MobileScanner(
                                controller: _controller,
                                onDetect: _onDetect,
                                errorBuilder: (context, error) {
                                  return FutureBuilder<PermissionStatus>(
                                    future: Permission.camera.status,
                                    builder: (context, snapshot) {
                                      final isGranted =
                                          snapshot.data?.isGranted ?? false;

                                      return Container(
                                        color: AppColors.bgCard,
                                        padding: const EdgeInsets.all(16),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isGranted
                                                    ? Icons.camera_alt_rounded
                                                    : Icons.camera_alt_outlined,
                                                size: 38,
                                                color: isGranted
                                                    ? AppColors.primary
                                                    : AppColors.warning,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                isGranted
                                                    ? 'Camera Ready / Tap to Start'
                                                    : 'Camera Permission Needed',
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isGranted
                                                    ? 'Camera permission is allowed. Tap "Start Camera" to initialize scanner.'
                                                    : 'Allow camera access to scan QR ticket.',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () async {
                                                      final req =
                                                          await Permission
                                                              .camera
                                                              .request();
                                                      if (req.isGranted ||
                                                          isGranted) {
                                                        await _startScanner();
                                                      } else {
                                                        await openAppSettings();
                                                      }
                                                    },
                                                    icon: Icon(
                                                      isGranted
                                                          ? Icons
                                                              .play_arrow_rounded
                                                          : Icons
                                                              .check_circle_outline_rounded,
                                                      size: 16,
                                                    ),
                                                    label: Text(isGranted
                                                        ? 'Start Camera'
                                                        : 'Allow Camera'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  OutlinedButton.icon(
                                                    onPressed: () async {
                                                      await openAppSettings();
                                                    },
                                                    icon: const Icon(
                                                        Icons.settings_rounded,
                                                        size: 16),
                                                    label:
                                                        const Text('Settings'),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor: AppColors
                                                          .textSecondary,
                                                      side: const BorderSide(
                                                          color: AppColors
                                                              .border),
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              // Overlay
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              // Corner brackets
                              ...['tl', 'tr', 'bl', 'br']
                                  .map((pos) => _Corner(position: pos)),

                              if (_isProcessing)
                                Container(
                                  color: Colors.black54,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Instructions
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Point the camera at the parking QR ticket to verify a booking',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final String position;

  const _Corner({required this.position});

  @override
  Widget build(BuildContext context) {
    final isTop = position.startsWith('t');
    final isLeft = position.endsWith('l');
    return Positioned(
      top: isTop ? 16 : null,
      bottom: isTop ? null : 16,
      left: isLeft ? 16 : null,
      right: isLeft ? null : 16,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ScannedResult extends StatelessWidget {
  final Booking booking;

  const _ScannedResult({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isValid = booking.status == 'confirmed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isValid ? AppColors.success : AppColors.error)
                  .withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: (isValid ? AppColors.success : AppColors.error)
                    .withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isValid ? AppColors.success : AppColors.error,
              size: 44,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isValid ? 'Valid Ticket ✓' : 'Invalid / Expired',
            style: TextStyle(
              color: isValid ? AppColors.success : AppColors.error,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(label: 'Location',
                    value: booking.location?.name ?? 'Unknown'),
                _Row(label: 'Slot', value: booking.slot?.slotNumber ?? '-'),
                _Row(label: 'Vehicle', value: booking.vehicleNumber),
                _Row(label: 'Date', value: booking.bookingDate),
                _Row(
                  label: 'Time',
                  value:
                      '${AppHelpers.formatTime(booking.startTime)} – ${AppHelpers.formatTime(booking.endTime)}',
                ),
                _Row(
                  label: 'Amount',
                  value: '₹${booking.totalAmount.toStringAsFixed(2)}',
                  valueColor: AppColors.success,
                ),
                _Row(
                  label: 'Status',
                  value: booking.status.toUpperCase(),
                  valueColor:
                      isValid ? AppColors.success : AppColors.error,
                ),
              ],
            ),
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

  const _Row({required this.label, required this.value, this.valueColor});

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
