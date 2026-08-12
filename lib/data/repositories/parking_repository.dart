import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/parking_location.dart';
import '../models/parking_slot.dart';
import '../../core/constants/app_constants.dart';

class ParkingRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<ParkingLocation>> getLocations({String? query}) async {
    var request = _client
        .from(AppConstants.tableParkingLocations)
        .select('*, parking_slots(count)');

    if (query != null && query.isNotEmpty) {
      request = request.ilike('name', '%$query%');
    }

    final data = await request.order('name');
    return (data as List)
        .map((e) => ParkingLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ParkingLocation> getLocationById(String locationId) async {
    final data = await _client
        .from(AppConstants.tableParkingLocations)
        .select()
        .eq('id', locationId)
        .single();
    return ParkingLocation.fromJson(data);
  }

  Future<List<ParkingSlot>> getSlotsForLocation({
    required String locationId,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    // Get all slots for this location
    final slotsData = await _client
        .from(AppConstants.tableParkingSlots)
        .select()
        .eq('location_id', locationId)
        .eq('is_active', true)
        .order('slot_number');

    final slots = (slotsData as List)
        .map((e) => ParkingSlot.fromJson(e as Map<String, dynamic>))
        .toList();

    if (slots.isEmpty) return slots;
    
    final slotIds = slots.map((s) => s.id).toList();

    // Get non-cancelled bookings for this location's slots
    final bookedData = await _client
        .from(AppConstants.tableBookings)
        .select('slot_id, booking_date, start_time, end_time')
        .neq('status', 'cancelled')
        .inFilter('slot_id', slotIds);

    final Set<String> bookedSlotIds = {};

    for (var row in bookedData as List) {
      final existingDateStr = row['booking_date'] as String;
      final existStart = _parseBookingDateTime(
          existingDateStr.contains(' to ') ? existingDateStr.split(' to ')[0] : existingDateStr,
          row['start_time'] as String);
      final existEnd = _parseBookingDateTime(
          existingDateStr.contains(' to ') ? existingDateStr.split(' to ')[1] : existingDateStr,
          row['end_time'] as String);

      if (existStart != null && existEnd != null) {
        // Precise Overlap Check
        if (startDateTime.isBefore(existEnd) && endDateTime.isAfter(existStart)) {
          bookedSlotIds.add(row['slot_id'] as String);
        }
      }
    }

    // Mark availability
    return slots.map((slot) {
      return slot.copyWith(isAvailable: !bookedSlotIds.contains(slot.id));
    }).toList();
  }

  static DateTime? _parseBookingDateTime(String dateStr, String timeStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) return null;
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

}
