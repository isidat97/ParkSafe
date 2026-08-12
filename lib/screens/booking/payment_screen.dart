import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/parking_location.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'qr_ticket_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ParkingLocation location;

  const PaymentScreen({super.key, required this.location});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // Default: FASTag Auto-Pay
  bool _processing = false;

  final _methods = const [
    _PayMethod(
      icon: Icons.nfc_rounded,
      name: 'NETC FASTag Auto-Scan',
      subtitle: 'Automatic RFID scan at parking boom barrier',
      color: Color(0xFFFF6D00),
      isRecommended: true,
      badge: 'CONTACTLESS ENTRY',
    ),
    _PayMethod(
      icon: Icons.account_balance_wallet_rounded,
      name: 'UPI / Wallet',
      subtitle: 'GPay, PhonePe, Paytm, BHIM',
      color: Color(0xFF1A73E8),
    ),
    _PayMethod(
      icon: Icons.credit_card_rounded,
      name: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, RuPay',
      color: Color(0xFF7C4DFF),
    ),
    _PayMethod(
      icon: Icons.account_balance_rounded,
      name: 'Net Banking',
      subtitle: 'All major Indian banks',
      color: Color(0xFF00BFA5),
    ),
    _PayMethod(
      icon: Icons.money_rounded,
      name: 'Pay at Counter',
      subtitle: 'Pay cash to parking attendant',
      color: Color(0xFFFFD600),
    ),
  ];

  Future<void> _pay() async {
    setState(() => _processing = true);

    // Simulate payment processing / FASTag RFID verification
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final isFastag = _methods[_selectedMethod].name.contains('FASTag');
    final payId = isFastag
        ? 'FT-NETC-${Random().nextInt(899999) + 100000}'
        : 'PS${Random().nextInt(999999).toString().padLeft(6, '0')}';

    final bookingProvider = context.read<BookingProvider>();      final success = await bookingProvider.confirmPayment(paymentId: payId);

    if (!mounted) return;
    setState(() => _processing = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const QrTicketScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Payment failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final amount = booking.calculateAmount(widget.location.pricePerHour);
    final vehicleNo = booking.vehicleNumber.isNotEmpty ? booking.vehicleNumber : 'GJ21AQ9541';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Amount Display Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.payment_rounded,
                                color: Colors.white70, size: 36),
                            const SizedBox(height: 12),
                            const Text(
                              'Total Amount Payable',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Booking #${booking.currentBooking?.id.substring(0, 8).toUpperCase() ?? ''}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Selected Method Highlight (FASTag Card Preview)
                      if (_selectedMethod == 0) ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF6D00).withOpacity(0.2),
                                const Color(0xFFFFAB00).withOpacity(0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFF6D00).withOpacity(0.6),
                                width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6D00),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'NETC FASTag',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.nfc_rounded,
                                            color: Color(0xFFFF6D00), size: 18),
                                        SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'AUTO-SCAN ACTIVE',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(0xFFFF6D00),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car_rounded,
                                      color: AppColors.textPrimary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Vehicle No: $vehicleNo',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.success.withOpacity(0.4)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: AppColors.success, size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Linked',
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '⚡ Drive straight through the parking gate! NETC RFID scanner will automatically scan your windshield FASTag for contactless entry.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Payment methods
                      ...List.generate(
                        _methods.length,
                        (i) => GestureDetector(
                          onTap: () => setState(() => _selectedMethod = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedMethod == i
                                  ? _methods[i].color.withOpacity(0.12)
                                  : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedMethod == i
                                    ? _methods[i].color.withOpacity(0.8)
                                    : AppColors.border,
                                width: _selectedMethod == i ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _methods[i].color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_methods[i].icon,
                                      color: _methods[i].color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            _methods[i].name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (_methods[i].badge != null) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _methods[i].color,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _methods[i].badge!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _methods[i].subtitle,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<int>(
                                  value: i,
                                  groupValue: _selectedMethod,
                                  onChanged: (v) =>
                                      setState(() => _selectedMethod = v!),
                                  activeColor: _methods[i].color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Security note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_rounded,
                                color: AppColors.success, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NETC FASTag & Bank Encrypted Gateway',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_processing) ...[
                        const CircularProgressIndicator(color: Color(0xFFFF6D00)),
                        const SizedBox(height: 12),
                        Text(
                          _selectedMethod == 0
                              ? 'Scanning NETC FASTag at boom barrier...'
                              : 'Processing payment...',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else
                        AppButton(
                          label: _selectedMethod == 0
                              ? 'Authorize FASTag (₹${amount.toStringAsFixed(2)})'
                              : 'Pay ₹${amount.toStringAsFixed(2)}',
                          icon: _selectedMethod == 0
                              ? Icons.nfc_rounded
                              : Icons.lock_rounded,
                          onTap: _pay,
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

class _PayMethod {
  final IconData icon;
  final String name;
  final String subtitle;
  final Color color;
  final bool isRecommended;
  final String? badge;

  const _PayMethod({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.color,
    this.isRecommended = false,
    this.badge,
  });
}
