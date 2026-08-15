import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/vehicle_number_plate_field.dart';
import 'admin_booking_detail_screen.dart';

class AdminScanScreen extends StatefulWidget {
  const AdminScanScreen({super.key});

  @override
  State<AdminScanScreen> createState() => _AdminScanScreenState();
}

class _AdminScanScreenState extends State<AdminScanScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanning = true;
  bool _hasNavigated = false;
  final TextEditingController _manualCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScanner();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetScan();
    });
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

  String? _lastScannedData;
  DateTime? _lastScanTime;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _resetScan() {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() {
        _scanning = true;
        _hasNavigated = false;
      });
      context.read<AdminProvider>().clearScan();
      _startScanner();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _hasNavigated) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final qrData = barcode!.rawValue!.trim();
    final now = DateTime.now();

    // Prevent duplicate processing of the exact same QR code within 3 seconds
    if (_lastScannedData == qrData &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inSeconds < 3) {
      return;
    }

    _lastScannedData = qrData;
    _lastScanTime = now;

    setState(() {
      _scanning = false;
      _hasNavigated = true;
    });

    final admin = context.read<AdminProvider>();
    final success = await admin.scanAndFetchBooking(qrData);

    if (!mounted) return;

    if (success && admin.scannedBooking != null) {
      final validation = admin.validateBookingLocation(admin.scannedBooking!);
      final isValid = validation['isValid'] == true;

      if (!isValid) {
        final bookingLoc = validation['bookingLocation'] ?? 'another location';
        final adminLoc = validation['adminLocation'] ?? 'your location';
        await _showInvalidQrDialog(
          'QR Code Not Valid\n\n'
          'This booking does not belong to your assigned parking location.\n\n'
          '• Customer Booking: $bookingLoc\n'
          '• Your Location: $adminLoc',
        );
        _resetScan();
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminBookingDetailScreen(
            bookingId: admin.scannedBooking!.id,
          ),
        ),
      );
      _resetScan();
    } else {
      _showError(admin.scanError ?? 'Invalid QR code');
      // 3-second cooldown before re-enabling scanning to prevent continuous SnackBar loop!
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _scanning = true;
            _hasNavigated = false;
          });
        }
      });
    }
  }

  Future<void> _showInvalidQrDialog(String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 10),
            Text(
              'QR Code Not Valid',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    // Clear any existing queued SnackBars first so notifications NEVER stack up!
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _manualLookup() async {
    final input = _manualCtrl.text.trim();
    if (input.isEmpty) return;
    final admin = context.read<AdminProvider>();

    bool success = false;
    if (input.startsWith('{')) {
      success = await admin.scanAndFetchBooking(input);
    } else {
      // First attempt lookup as exact or vehicle number search
      success = await admin.searchByVehicleNumber(input);
      if (!success) {
        success = await admin.loadBookingById(input);
      }
    }

    if (!mounted) return;
    if (success && admin.scannedBooking != null) {
      final validation = admin.validateBookingLocation(admin.scannedBooking!);
      final isValid = validation['isValid'] == true;

      if (!isValid) {
        final bookingLoc = validation['bookingLocation'] ?? 'another location';
        final adminLoc = validation['adminLocation'] ?? 'your location';
        await _showInvalidQrDialog(
          'QR Code Not Valid\n\n'
          'This booking does not belong to your assigned parking location.\n\n'
          '• Customer Booking: $bookingLoc\n'
          '• Your Location: $adminLoc',
        );
        _resetScan();
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminBookingDetailScreen(bookingId: admin.scannedBooking!.id),
        ),
      );
      _resetScan();
    } else {
      _showError(admin.scanError ?? 'No booking found for "$input"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text('Scan QR Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      )),
                  const Spacer(),
                  if (!_scanning)
                    TextButton.icon(
                      onPressed: _resetScan,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 16, color: AppColors.primary),
                      label: const Text('Scan Again',
                          style: TextStyle(color: AppColors.primary)),
                    ),
                ],
              ),
            ),

            // Scanner viewport & controls
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
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
                                                  ? 'Camera permission is allowed. Tap "Start Camera" to initialize scanner view.'
                                                  : 'Tap below to allow camera access or use manual Booking ID entry.',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final req =
                                                        await Permission.camera
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
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
                                                  label: const Text('Settings'),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.textSecondary,
                                                    side: const BorderSide(
                                                        color: AppColors
                                                            .border),
                                                    padding: const EdgeInsets
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
                            // Dark overlay corners
                            ..._corners(),
                            // Scanning animation line
                            if (_scanning) _ScanLine(),
                            // Processing overlay
                            Consumer<AdminProvider>(
                              builder: (_, admin, __) {
                                if (!admin.isScanLoading) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  color: Colors.black54,
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                            color: AppColors.primary),
                                        SizedBox(height: 12),
                                        Text('Looking up booking...',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Point camera at the customer\'s QR ticket to check booking details, check in, or check out.',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Manual vehicle plate entry
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manual Vehicle Lookup',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        VehicleNumberPlateField(
                          controller: _manualCtrl,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _manualLookup,
                            icon: const Icon(Icons.search_rounded, size: 18),
                            label: const Text(
                              'Search Booking by Vehicle No. / ID',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    return ['tl', 'tr', 'bl', 'br'].map((pos) {
      final isTop = pos.startsWith('t');
      final isLeft = pos.endsWith('l');
      return Positioned(
        top: isTop ? 16 : null,
        bottom: isTop ? null : 16,
        left: isLeft ? 16 : null,
        right: isLeft ? null : 16,
        child: Container(
          width: 32,
          height: 32,
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
    }).toList();
  }
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pos;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pos = Tween(begin: 0.1, end: 0.9).animate(
        CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pos,
      builder: (_, __) => Positioned(
        left: 16,
        right: 16,
        top: null,
        bottom: null,
        child: Align(
          alignment: Alignment(0, (_pos.value * 2) - 1),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withOpacity(0),
                AppColors.primary,
                AppColors.primary.withOpacity(0),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
