import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().profile?.id ?? '';
      context.read<BookingProvider>().loadUserBookings(userId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().profile?.id ?? '';
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
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 24,
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
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Past'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
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
                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _BookingList(
                        bookings: booking.bookings
                            .where((b) =>
                                b.status == 'confirmed' ||
                                b.status == 'checked_in' ||
                                b.status == 'pending')
                            .toList(),
                        emptyTitle: 'No active bookings',
                        emptySubtitle: 'Book a parking slot to get started',
                      ),
                      _BookingList(
                        bookings: booking.bookings
                            .where((b) => b.status == 'completed')
                            .toList(),
                        emptyTitle: 'No past bookings',
                        emptySubtitle: 'Your completed bookings will appear here',
                      ),
                      _BookingList(
                        bookings: booking.bookings
                            .where((b) => b.status == 'cancelled')
                            .toList(),
                        emptyTitle: 'No cancelled bookings',
                        emptySubtitle: 'Your cancelled bookings will appear here',
                      ),
                    ],
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

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyTitle;
  final String emptySubtitle;

  const _BookingList({
    required this.bookings,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_rounded,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  IconData _getVehicleIcon(String? slotType) {
    final type = (slotType ?? 'car').toLowerCase();
    if (type.contains('bike') || type.contains('two')) {
      return Icons.two_wheeler_rounded;
    } else if (type.contains('ev') || type.contains('electric')) {
      return Icons.ev_station_rounded;
    }
    return Icons.directions_car_rounded;
  }

  String _getVehicleTypeName(String? slotType) {
    final type = (slotType ?? 'car').toLowerCase();
    if (type.contains('bike') || type.contains('two')) {
      return 'Bike';
    } else if (type.contains('ev') || type.contains('electric')) {
      return 'EV';
    }
    return 'Car';
  }

  @override
  Widget build(BuildContext context) {
    final slotType = booking.slot?.slotType;
    final vehicleIcon = _getVehicleIcon(slotType);
    final vehicleTypeName = _getVehicleTypeName(slotType);

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
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Vehicle Icon & Slot Box
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(vehicleIcon, color: Colors.white, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    booking.slot?.slotNumber ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.location?.name ?? 'Parking',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Vehicle symbol badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(vehicleIcon,
                                size: 11, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              vehicleTypeName,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.bookingDate,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${AppHelpers.formatTime(booking.startTime)} – ${AppHelpers.formatTime(booking.endTime)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${(booking.totalAmount + booking.effectiveOvertimeFee).toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (booking.hasOvertime)
                            Text(
                              '+₹${booking.effectiveOvertimeFee.toStringAsFixed(0)} Overtime',
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
