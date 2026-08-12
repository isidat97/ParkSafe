import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/parking_location.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import '../slot_selection/slot_selection_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final ParkingLocation location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = TimeOfDay(hour: now.hour, minute: 0);
    _endTime = TimeOfDay(hour: (now.hour + 2).clamp(0, 23), minute: 0);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            surface: AppColors.bgCard,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_selectedEndDate.isBefore(_selectedDate)) {
          _selectedEndDate = _selectedDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate.isBefore(_selectedDate)
          ? _selectedDate
          : _selectedEndDate,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            surface: AppColors.bgCard,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            surface: AppColors.bgCard,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime _toStartDateTime(TimeOfDay t) {
    return DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, t.hour, t.minute);
  }

  DateTime _toEndDateTime(TimeOfDay t) {
    return DateTime(
        _selectedEndDate.year, _selectedEndDate.month, _selectedEndDate.day, t.hour, t.minute);
  }

  double get _totalHours {
    final start = _toStartDateTime(_startTime);
    final end = _toEndDateTime(_endTime);
    final diffMinutes = end.difference(start).inMinutes;
    return diffMinutes > 0 ? (diffMinutes / 60.0) : 0;
  }

  void _findSlots() {
    if (_totalHours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date & time must be after start date & time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final booking = context.read<BookingProvider>();
    booking.setDateRange(_selectedDate, _selectedEndDate);
    booking.setStartTime(_toStartDateTime(_startTime));
    booking.setEndTime(_toEndDateTime(_endTime));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SlotSelectionScreen(location: widget.location),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final loc = widget.location;
    return Scaffold(
      body: Container(
        color: AppColors.bgDark,
        child: CustomScrollView(
          slivers: [
            // App bar with image
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.bgDark,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary.withOpacity(0.08),
                  child: Image.network(
                    loc.imageUrl ??
                        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.local_parking_rounded,
                        color: AppColors.primary.withOpacity(0.3),
                        size: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -22 * 0.02,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      loc.address,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '₹${loc.pricePerHour.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'per hour',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AppHelpers.openGoogleMaps(
                            googleMapsLink: loc.googleMapsLink,
                            locationName: loc.name,
                            locationAddress: loc.address,
                            lat: loc.lat,
                            lng: loc.lng,
                          );
                        },
                        icon: const Icon(Icons.directions_rounded,
                            color: AppColors.primary, size: 18),
                        label: const Text('Get Directions in Google Maps',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Features / Amenities
                    const Text(
                      'Facility Features',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Requirement 9 Feature 1: Number of Parking Slots
                        _Feature(
                            icon: Icons.local_parking_rounded,
                            label: '${loc.totalSlots} Parking Slots',
                            color: AppColors.info),
                        // Requirement 9 Feature 2: 24/7 CCTV
                        if (loc.amenities == null ||
                            loc.amenities!.any((a) => a.toUpperCase().contains('CCTV')))
                          const _Feature(
                              icon: Icons.videocam_outlined,
                              label: '24/7 CCTV Surveillance',
                              color: AppColors.info),
                        // Requirement 9 Feature 3: EV Charging
                        if (loc.amenities == null ||
                            loc.amenities!.any((a) => a.toUpperCase().contains('EV')))
                          const _Feature(
                              icon: Icons.electric_car_rounded,
                              label: 'EV Charging',
                              color: AppColors.info),
                        // Requirement 9 Feature 4: Car Wash
                        if (loc.amenities == null ||
                            loc.amenities!.any((a) => a.toUpperCase().contains('WASH')))
                          const _Feature(
                              icon: Icons.local_car_wash_rounded,
                              label: 'Car Wash',
                              color: AppColors.info),
                        // Requirement 9 Feature 5: Security Guard
                        if (loc.amenities == null ||
                            loc.amenities!.any((a) => a.toUpperCase().contains('SECURITY') || a.toUpperCase().contains('GUARD')))
                          const _Feature(
                              icon: Icons.shield_outlined,
                              label: 'Security Guard',
                              color: AppColors.info),
                        // Any additional amenities from database
                        if (loc.amenities != null)
                          ...loc.amenities!
                              .where((a) {
                                final u = a.toUpperCase();
                                return !u.contains('CCTV') &&
                                    !u.contains('EV') &&
                                    !u.contains('WASH') &&
                                    !u.contains('SECURITY') &&
                                    !u.contains('GUARD');
                              })
                              .map((a) => _Feature(
                                    icon: Icons.check_circle_outline_rounded,
                                    label: a,
                                    color: AppColors.textSecondary,
                                  )),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 20),

                    // Booking section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Date & Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -18 * 0.02,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Hourly & Multi-Day Rentals',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Duration / Multi-Day Presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          {'label': '1 Day', 'days': 0},
                          {'label': '2 Days', 'days': 1},
                          {'label': '3 Days', 'days': 2},
                          {'label': '5 Days', 'days': 4},
                          {'label': '7 Days', 'days': 6},
                        ].map((preset) {
                          final daysOffset = preset['days'] as int;
                          final targetEnd =
                              _selectedDate.add(Duration(days: daysOffset));
                          final isSelected =
                              _isSameDate(_selectedEndDate, targetEnd);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEndDate = targetEnd;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.bgCard,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                preset['label'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Start Date & End Date Row
                    Row(
                      children: [
                        // Start Date Card
                        Expanded(
                          child: GlassCard(
                            onTap: _pickStartDate,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        color: AppColors.primary, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Start Date',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // End Date Card
                        Expanded(
                          child: GlassCard(
                            onTap: _pickEndDate,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.event_available_rounded,
                                        color: AppColors.accent, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'End Date',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Time pickers
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            onTap: () => _pickTime(true),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        color: AppColors.accent, size: 16),
                                    SizedBox(width: 6),
                                    Text('Check-In Time',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _startTime.format(context),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassCard(
                            onTap: () => _pickTime(false),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded,
                                        color: AppColors.primary, size: 16),
                                    SizedBox(width: 6),
                                    Text('Check-Out Time',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _endTime.format(context),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_totalHours > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Duration',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  _totalHours >= 24
                                      ? '${(_totalHours / 24).floor()} Day${(_totalHours / 24).floor() > 1 ? 's' : ''} (${_totalHours.toStringAsFixed(0)} hrs)'
                                      : '${_totalHours.toStringAsFixed(1)} hours',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Estimated Total',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${(_totalHours * loc.pricePerHour).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'Find Available Slots',
                      icon: Icons.search_rounded,
                      onTap: _findSlots,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Feature({
    required this.icon,
    required this.label,
    this.color = AppColors.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSurface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
