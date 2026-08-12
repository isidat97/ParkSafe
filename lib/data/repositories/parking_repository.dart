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
    required String bookingDate,
    required String startTime,
    required String endTime,
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

    // Get booked slots for this date & overlapping time
    // Interval overlap condition: start_time < endTime AND end_time > startTime
    final bookedData = await _client
        .from(AppConstants.tableBookings)
        .select('slot_id')
        .eq('booking_date', bookingDate)
        .inFilter('status', ['confirmed', 'pending', 'checked_in'])
        .lt('start_time', endTime)
        .gt('end_time', startTime);

    final bookedSlotIds = (bookedData as List)
        .map((e) => e['slot_id'] as String)
        .toSet();

    // Mark availability
    return slots.map((slot) {
      return slot.copyWith(isAvailable: !bookedSlotIds.contains(slot.id));
    }).toList();
  }
}
