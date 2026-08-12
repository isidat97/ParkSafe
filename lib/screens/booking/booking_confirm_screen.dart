import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/parking_location.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/parking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'payment_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final ParkingLocation location;

  const BookingConfirmScreen({super.key, required this.location});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen>
    with SingleTickerProviderStateMixin {
  final _vehicleCtrl = TextEditingController();
  String? _vehicleError;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _vehicleCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final vehicleStr = _vehicleCtrl.text.trim().toUpperCase();
    if (vehicleStr.isEmpty || !AppHelpers.isValidVehicleNumber(vehicleStr)) {
      setState(() {
        _vehicleError = 'Invalid Vehicle Number';
      });
      _shakeController.forward(from: 0.0);
      return;
    }

    setState(() {
      _vehicleError = null;
    });

    final booking = context.read<BookingProvider>();
    final parking = context.read<ParkingProvider>();
    booking.setVehicleNumber(vehicleStr);

    final selectedSlot = parking.selectedSlot;
    if (selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No slot selected'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final userId = auth.profile?.id ?? 'guest-user';

    final success = await booking.createBooking(
      userId: userId,
      slot: selectedSlot,
      location: widget.location,
    );

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(location: widget.location),
        ),
      );
    } else if (mounted && booking.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(booking.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final parking = context.watch<ParkingProvider>();
    final slot = parking.selectedSlot;
    final loc = widget.location;
    final totalAmount = booking.calculateAmount(loc.pricePerHour);

    if (slot == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No slot selected',
                  style: TextStyle(color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Slots'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
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
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking details card
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.local_parking_rounded,
                                      color: Colors.white,
                                      size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        loc.address,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                                color: AppColors.border, height: 28),
                            _BookingRow(
                              label: 'Slot Number',
                              value: slot.slotNumber,
                              icon: Icons.directions_car_rounded,
                            ),
                            _BookingRow(
                              label: 'Type',
                              value: AppHelpers.getSlotTypeLabel(slot.slotType),
                              icon: Icons.category_rounded,
                            ),
                            _BookingRow(
                              label: 'Date',
                              value: booking.selectedDate != null
                                  ? AppHelpers.formatDateShort(booking.selectedDate!)
                                  : '-',
                              icon: Icons.calendar_today_rounded,
                            ),
                            _BookingRow(
                              label: 'From',
                              value: booking.startTime != null
                                  ? AppHelpers.formatTimeFromDateTime(
                                      booking.startTime!)
                                  : '-',
                              icon: Icons.access_time_rounded,
                            ),
                            _BookingRow(
                              label: 'To',
                              value: booking.endTime != null
                                  ? AppHelpers.formatTimeFromDateTime(
                                      booking.endTime!)
                                  : '-',
                              icon: Icons.access_time_filled_rounded,
                            ),
                            _BookingRow(
                              label: 'Duration',
                              value:
                                  '${booking.totalHours.toStringAsFixed(1)} hours',
                              icon: Icons.timer_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Vehicle Details Header
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Authentic Indian Number Plate Input Field with Shake Animation
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: VehicleNumberPlateField(
                          controller: _vehicleCtrl,
                          errorText: _vehicleError,
                          onChanged: (val) {
                            if (_vehicleError != null) {
                              setState(() => _vehicleError = null);
                            }
                          },
                        ),
                      ),



                      const SizedBox(height: 24),

                      // Price breakdown
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Breakdown',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PriceRow(
                              label:
                                  'Parking (₹${loc.pricePerHour.toStringAsFixed(0)} × ${booking.totalHours.toStringAsFixed(1)}h)',
                              value: totalAmount,
                            ),
                            const _PriceRow(
                                label: 'Service Fee', value: 0),
                            const Divider(color: AppColors.border, height: 20),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '₹${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      LoadingOverlay(
                        isLoading: booking.isLoading,
                        child: AppButton(
                          label: 'Proceed to Payment',
                          icon: Icons.payment_rounded,
                          isLoading: booking.isLoading,
                          onTap: _proceed,
                        ),
                      ),
                      const SizedBox(height: 20),
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

class _BookingRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BookingRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;

  const _PriceRow({required this.label, required this.value});

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
            value == 0 ? 'Free' : '₹${value.toStringAsFixed(2)}',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class VehicleNumberPlateField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const VehicleNumberPlateField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<VehicleNumberPlateField> createState() =>
      _VehicleNumberPlateFieldState();
}

class _VehicleNumberPlateFieldState extends State<VehicleNumberPlateField> {
  static const String _defaultPlaceholder = 'GJ 21 AQ 9541';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text.toUpperCase();
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Calculate remaining placeholder suffix
    String suffixPlaceholder = '';
    if (text.length < _defaultPlaceholder.length) {
      suffixPlaceholder = _defaultPlaceholder.substring(text.length);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Authentic Indian Number Plate Box Card
        Container(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? AppColors.error : const Color(0xFF1E2838),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? AppColors.error.withOpacity(0.2)
                    : const Color(0x14000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left IND Emblem Section
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0D47A1), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.brightness_7_rounded,
                          size: 10,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'IND',
                      style: TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Middle Editable Number Plate Area with Masked Suffix
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Suffix Mask Overlay
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: text,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                    color: Colors.transparent,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                TextSpan(
                                  text: suffixPlaceholder,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Editable TextField
                    TextField(
                      controller: widget.controller,
                      onChanged: widget.onChanged,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        IndianVehicleNumberFormatter(),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: Color(0xFF1E2838),
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),


        // Inline Error Display directly below input box
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Formats vehicle number input: 2 Alpha + space + 2 Num + space + 2 Alpha + space + 4 Num
class IndianVehicleNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final clean = raw.substring(0, raw.length.clamp(0, 10));

    final sb = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i == 2 || i == 4 || i == 6) {
        sb.write(' ');
      }
      sb.write(clean[i]);
    }

    final formattedText = sb.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

