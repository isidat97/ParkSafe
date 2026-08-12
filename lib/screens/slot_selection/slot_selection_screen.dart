import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/parking_location.dart';
import '../../data/models/parking_slot.dart';
import '../../providers/parking_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common_widgets.dart';
import '../booking/booking_confirm_screen.dart';

class SlotSelectionScreen extends StatefulWidget {
  final ParkingLocation location;

  const SlotSelectionScreen({super.key, required this.location});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlots();
    });
  }

  Future<void> _loadSlots() async {
    final booking = context.read<BookingProvider>();
    final parking = context.read<ParkingProvider>();

    if (booking.selectedDate == null ||
        booking.startTime == null ||
        booking.endTime == null) {
      return;
    }

    final startDateTime = DateTime(
      booking.selectedDate!.year,
      booking.selectedDate!.month,
      booking.selectedDate!.day,
      booking.startTime!.hour,
      booking.startTime!.minute,
    );

    final endDateTime = DateTime(
      booking.selectedEndDate!.year,
      booking.selectedEndDate!.month,
      booking.selectedEndDate!.day,
      booking.endTime!.hour,
      booking.endTime!.minute,
    );

    await parking.loadSlots(
      locationId: widget.location.id,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
    );
  }

  void _onSlotTap(ParkingSlot slot) {
    if (!slot.isAvailable) return;
    final parking = context.read<ParkingProvider>();
    parking.selectSlot(slot.isSelected ? null : slot);
  }

  void _proceed() {
    final parking = context.read<ParkingProvider>();
    if (parking.selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a parking slot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmScreen(location: widget.location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final parking = context.watch<ParkingProvider>();

    final allSlots = parking.slots;
    final filtered = _filterType == 'all'
        ? allSlots
        : allSlots
            .where((s) => s.slotType.toLowerCase() == _filterType.toLowerCase())
            .toList();

    final available = filtered.where((s) => s.isAvailable).length;
    final booked = filtered.length - available;

    // Group filtered slots by floor
    final Map<String, List<ParkingSlot>> slotsByFloor = {};
    for (var slot in filtered) {
      final fl = (slot.floor != null && slot.floor!.trim().isNotEmpty)
          ? slot.floor!.trim()
          : 'Ground Floor';
      slotsByFloor.putIfAbsent(fl, () => []).add(slot);
    }

    return Scaffold(
      body: Container(
        color: AppColors.bgDark,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Slot',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -18 * 0.02,
                            ),
                          ),
                          Text(
                            widget.location.name,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadSlots,
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Booking summary strip
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F14181B),
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: booking.selectedDate != null
                          ? '${booking.selectedDate!.day}/${booking.selectedDate!.month}'
                          : '-',
                    ),
                    _SummaryItem(
                      icon: Icons.access_time_rounded,
                      label: 'From',
                      value: booking.startTime != null
                          ? AppHelpers.formatTimeFromDateTime(booking.startTime!)
                          : '-',
                    ),
                    _SummaryItem(
                      icon: Icons.access_time_filled_rounded,
                      label: 'To',
                      value: booking.endTime != null
                          ? AppHelpers.formatTimeFromDateTime(booking.endTime!)
                          : '-',
                    ),
                    _SummaryItem(
                      icon: Icons.timer_outlined,
                      label: 'Hours',
                      value: booking.totalHours > 0
                          ? '${booking.totalHours.toStringAsFixed(1)}h'
                          : '-',
                    ),
                  ],
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Legend(color: AppColors.success, label: 'Available ($available)'),
                    const SizedBox(width: 16),
                    _Legend(color: AppColors.textMuted, label: 'Booked ($booked)'),
                    const SizedBox(width: 16),
                    const _Legend(color: AppColors.primary, label: 'Selected'),
                  ],
                ),
              ),

              // Type filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: ['all', 'car', 'bike', 'ev'].map((type) {
                    final isSelected = _filterType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _filterType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.bgSurface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : AppColors.border,
                          ),
                        ),
                        child: Text(
                          type == 'all' ? 'All' : AppHelpers.getSlotTypeLabel(type),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Floor-wise Slot list
              Expanded(
                child: parking.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : filtered.isEmpty
                        ? const EmptyState(
                            icon: Icons.local_parking_rounded,
                            title: 'No slots found',
                            subtitle: 'Try a different filter or time',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: slotsByFloor.keys.length,
                            itemBuilder: (ctx, idx) {
                              final floorName = slotsByFloor.keys.elementAt(idx);
                              final floorSlots = slotsByFloor[floorName]!;
                              final availCount =
                                  floorSlots.where((s) => s.isAvailable).length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Floor Heading
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 16, 20, 10),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.layers_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          floorName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '$availCount available',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Floor Slot Grid
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.1,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: floorSlots.length,
                                    itemBuilder: (ctx, i) => _SlotTile(
                                      slot: floorSlots[i],
                                      onTap: _onSlotTap,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ),

              // Bottom bar
              if (parking.selectedSlot != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.bgCard,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            parking.selectedSlot?.floor != null &&
                                    parking.selectedSlot!.floor!.isNotEmpty
                                ? '${parking.selectedSlot!.floor} → Slot ${parking.selectedSlot!.slotNumber}'
                                : 'Slot ${parking.selectedSlot!.slotNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${booking.calculateAmount(widget.location.pricePerHour).toStringAsFixed(0)} total',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          label: 'Confirm Slot',
                          onTap: _proceed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final ParkingSlot slot;
  final void Function(ParkingSlot) onTap;

  const _SlotTile({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color content;
    double borderWidth = 1.0;

    if (slot.isSelected) {
      bg = AppColors.primary.withOpacity(0.12);
      border = AppColors.primary;
      content = AppColors.primary;
      borderWidth = 2.0;
    } else if (!slot.isAvailable) {
      bg = AppColors.bgSurface2; // Alt surface
      border = AppColors.border;
      content = AppColors.textMuted;
    } else {
      bg = AppColors.success.withOpacity(0.08);
      border = AppColors.success.withOpacity(0.3);
      content = AppColors.success;
    }

    return GestureDetector(
      onTap: () => onTap(slot),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: border,
            width: borderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slot.slotType == 'bike'
                  ? Icons.two_wheeler_rounded
                  : slot.slotType == 'ev'
                      ? Icons.electric_car_rounded
                      : Icons.directions_car_rounded,
              color: content,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              slot.slotNumber,
              style: TextStyle(
                color: content,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (slot.floor != null && slot.floor!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                slot.floor!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: content.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
