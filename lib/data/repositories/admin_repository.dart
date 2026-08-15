import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../supabase/supabase_config.dart';
import '../models/booking.dart';
import '../models/parking_location.dart';
import '../models/user_profile.dart';
import '../models/floor_config.dart';
import 'booking_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_helpers.dart';


class AdminRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  // ---------------------------------------------------------------------------
  // Booking Queries
  // ---------------------------------------------------------------------------

  Future<List<Booking>> getAllBookings({String? assignedLocationId}) async {
    final data = await _client
        .from(AppConstants.tableBookings)
        .select('''
          *,
          parking_slots(
            *,
            parking_locations(*)
          )
        ''')
        .order('created_at', ascending: false);
    var list = (data as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      list = list
          .where((b) =>
              b.slot?.locationId == assignedLocationId ||
              b.location?.id == assignedLocationId)
          .toList();
    }
    return list;
  }

  Future<List<Booking>> getTodaysBookings({String? assignedLocationId}) async {
    final today = _todayStr();
    final data = await _client
        .from(AppConstants.tableBookings)
        .select('''
          *,
          parking_slots(
            *,
            parking_locations(*)
          )
        ''')
        .eq('booking_date', today)
        .order('created_at', ascending: false);
    var list = (data as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      list = list
          .where((b) =>
              b.slot?.locationId == assignedLocationId ||
              b.location?.id == assignedLocationId)
          .toList();
    }
    return list;
  }

  Future<Map<String, dynamic>?> getBookingWithUserByQr(String qrData) async {
    try {
      String? bookingId;
      try {
        final decoded = jsonDecode(qrData) as Map<String, dynamic>;
        bookingId = decoded['booking_id'] as String?;
      } catch (_) {
        bookingId = qrData.trim();
      }

      if (bookingId == null || bookingId.isEmpty) return null;
      return await getBookingWithUserById(bookingId);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBookingWithUserById(
      String input) async {
    try {
      final cleanInput = input.trim();
      Map<String, dynamic>? bookingData;

      try {
        final res = await _client
            .from(AppConstants.tableBookings)
            .select('''
              *,
              parking_slots(
                *,
                parking_locations(*)
              )
            ''')
            .eq('id', cleanInput)
            .maybeSingle();
        bookingData = res;
      } catch (_) {}

      // Fallback: search by vehicle_number if ID lookup produced no result
      if (bookingData == null) {
        try {
          final List list = await _client
              .from(AppConstants.tableBookings)
              .select('''
                *,
                parking_slots(
                  *,
                  parking_locations(*)
                )
              ''')
              .ilike('vehicle_number', '%$cleanInput%')
              .order('created_at', ascending: false)
              .limit(1);
          if (list.isNotEmpty) {
            bookingData = list.first as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      if (bookingData == null) return null;

      final booking = Booking.fromJson(bookingData);

      UserProfile? userProfile;
      try {
        final List profileData = await _client
            .from(AppConstants.tableProfiles)
            .select()
            .eq('id', booking.userId)
            .limit(1);
        if (profileData.isNotEmpty) {
          userProfile = UserProfile.fromJson(profileData.first as Map<String, dynamic>);
        }
      } catch (_) {}


      return {'booking': booking, 'user': userProfile};
    } catch (e) {
      return null;
    }
  }


  Future<Map<String, dynamic>> checkIn(String bookingId) async {
    try {
      // Fetch booking details to verify scheduled start time
      final bData = await _client
          .from(AppConstants.tableBookings)
          .select('''
            *,
            parking_slots(
              *,
              parking_locations(*)
            )
          ''')
          .eq('id', bookingId)
          .maybeSingle();

      if (bData != null) {
        final booking = Booking.fromJson(bData);
        final schedStart = booking.scheduledStartDateTime;
        final now = DateTime.now();

        // Enforce No Early Check-In Rule
        if (schedStart != null && now.isBefore(schedStart)) {
          final minsRemaining = schedStart.difference(now).inMinutes;
          final timeStr = AppHelpers.formatTime(booking.startTime);
          return {
            'success': false,
            'message':
                'Early check-in not allowed. Booking starts at $timeStr ($minsRemaining mins remaining).'
          };
        }
      }

      final nowStr = DateTime.now().toUtc().toIso8601String();
      await _client
          .from(AppConstants.tableBookings)
          .update({
            'status': 'checked_in',
            'actual_check_in': nowStr,
          })
          .eq('id', bookingId);

      return {'success': true, 'message': 'Checked in successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Check-in failed: ${e.toString()}'};
    }
  }

  Future<bool> checkOut(String bookingId) async {
    try {
      final now = DateTime.now();
      final nowStr = now.toUtc().toIso8601String();
      double overtimeFee = 0.0;

      // Fetch existing booking to calculate overtime
      try {
        final bData = await _client
            .from(AppConstants.tableBookings)
            .select('''
              *,
              parking_slots(
                *,
                parking_locations(*)
              )
            ''')
            .eq('id', bookingId)
            .maybeSingle();

        if (bData != null) {
          final booking = Booking.fromJson(bData);
          final schedEnd = booking.scheduledEndDateTime;
          final pricePerHour = (booking.location?.pricePerHour != null && booking.location!.pricePerHour > 0)
              ? booking.location!.pricePerHour
              : (booking.totalHours > 0 ? (booking.totalAmount / booking.totalHours) : 50.0);

          if (schedEnd != null && now.isAfter(schedEnd)) {
            final extraMinutes = now.difference(schedEnd).inMinutes;
            if (extraMinutes > 0) {
              final extraHours = (extraMinutes / 60.0).ceil();
              overtimeFee = extraHours * pricePerHour;
            }
          }
        }
      } catch (_) {}

      await _client.from(AppConstants.tableBookings).update({
        'status': AppConstants.statusCompleted,
        'actual_check_out': nowStr,
        'overtime_fee': overtimeFee,
      }).eq('id', bookingId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final updates = <String, dynamic>{'status': status};
      if (status == 'checked_in') {
        updates['actual_check_in'] = DateTime.now().toUtc().toIso8601String();
      } else if (status == 'completed') {
        final now = DateTime.now();
        updates['actual_check_out'] = now.toUtc().toIso8601String();
        try {
          final bData = await _client
              .from(AppConstants.tableBookings)
              .select('''
                *,
                parking_slots(
                  *,
                  parking_locations(*)
                )
              ''')
              .eq('id', bookingId)
              .maybeSingle();

          if (bData != null) {
            final booking = Booking.fromJson(bData);
            final schedEnd = booking.scheduledEndDateTime;
            final pricePerHour = (booking.location?.pricePerHour != null && booking.location!.pricePerHour > 0)
                ? booking.location!.pricePerHour
                : (booking.totalHours > 0 ? (booking.totalAmount / booking.totalHours) : 50.0);

            if (schedEnd != null && now.isAfter(schedEnd)) {
              final extraMinutes = now.difference(schedEnd).inMinutes;
              if (extraMinutes > 0) {
                final extraHours = (extraMinutes / 60.0).ceil();
                updates['overtime_fee'] = extraHours * pricePerHour;
              }
            }
          }
        } catch (_) {}
      }
      await _client
          .from(AppConstants.tableBookings)
          .update(updates)
          .eq('id', bookingId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> processRefund({
    required String bookingId,
    required String refundStatus, // 'approved', 'rejected', 'refunded'
    String? reason,
  }) async {
    try {
      final updates = <String, dynamic>{'refund_status': refundStatus};
      if (reason != null && reason.isNotEmpty) {
        updates['refund_reason'] = reason;
      }
      await _client
          .from(AppConstants.tableBookings)
          .update(updates)
          .eq('id', bookingId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Parking Slots
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAllSlotsWithLocation({String? assignedLocationId}) async {
    final data = await _client
        .from(AppConstants.tableParkingSlots)
        .select('''
          *,
          parking_locations(id, name, address)
        ''')
        .order('slot_number');
    var list = (data as List).cast<Map<String, dynamic>>();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      list = list
          .where((s) => s['location_id'] == assignedLocationId)
          .toList();
    }
    return list;
  }

  Future<bool> updateSlotFloor(String slotId, String floorName) async {
    try {
      await _client
          .from(AppConstants.tableParkingSlots)
          .update({'floor': floorName.trim()})
          .eq('id', slotId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<ParkingLocation>> getAllLocations() async {
    final data = await _client
        .from(AppConstants.tableParkingLocations)
        .select()
        .order('name');
    return (data as List)
        .map((e) => ParkingLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Customers
  // ---------------------------------------------------------------------------

  Future<List<UserProfile>> getAllCustomers() async {
    try {
      final data = await _client
          .from(AppConstants.tableProfiles)
          .select()
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Booking>> getBookingsForUser(String userId) async {
    final validUserId = BookingRepository.ensureValidUuid(userId);
    final data = await _client
        .from(AppConstants.tableBookings)
        .select('''
          *,
          parking_slots(
            *,
            parking_locations(*)
          )
        ''')
        .or('user_id.eq.$validUserId,user_id.eq.$userId')
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }


  // ---------------------------------------------------------------------------
  // Revenue & Dashboard Stats
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getDashboardStats({String? assignedLocationId}) async {
    final today = _todayStr();

    // Today's bookings count
    final todayBookings = await _client
        .from(AppConstants.tableBookings)
        .select('''
          id, total_amount, status,
          parking_slots(location_id)
        ''')
        .eq('booking_date', today);

    var todayList = (todayBookings as List).cast<Map<String, dynamic>>();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      todayList = todayList.where((b) {
        final ps = b['parking_slots'] as Map<String, dynamic>?;
        return ps != null && ps['location_id'] == assignedLocationId;
      }).toList();
    }

    final todayCount = todayList.length;
    final revenueToday = todayList
        .where((b) => b['status'] != 'cancelled')
        .fold<double>(
            0, (sum, b) => sum + (b['total_amount'] as num).toDouble());

    final checkedInCount = todayList
        .where((b) => b['status'] == 'checked_in')
        .length;

    // All-time revenue
    final allBookings = await _client
        .from(AppConstants.tableBookings)
        .select('''
          total_amount, status,
          parking_slots(location_id)
        ''');
    var allList = (allBookings as List).cast<Map<String, dynamic>>();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      allList = allList.where((b) {
        final ps = b['parking_slots'] as Map<String, dynamic>?;
        return ps != null && ps['location_id'] == assignedLocationId;
      }).toList();
    }

    final totalRevenue = allList
        .where((b) => b['status'] != 'cancelled')
        .fold<double>(
            0, (sum, b) => sum + (b['total_amount'] as num).toDouble());

    // Total slots
    final slotsData = await _client
        .from(AppConstants.tableParkingSlots)
        .select('id, is_active, location_id');
    var slotsList = (slotsData as List).cast<Map<String, dynamic>>();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      slotsList = slotsList
          .where((s) => s['location_id'] == assignedLocationId)
          .toList();
    }

    return {
      'today_count': todayCount,
      'revenue_today': revenueToday,
      'checked_in_count': checkedInCount,
      'total_revenue': totalRevenue,
      'total_slots': slotsList.length,
    };
  }

  Future<List<Map<String, dynamic>>> getRevenueByDate({int days = 30}) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final fromStr =
        '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';

    final data = await _client
        .from(AppConstants.tableBookings)
        .select('booking_date, total_amount, status')
        .gte('booking_date', fromStr)
        .neq('status', 'cancelled')
        .order('booking_date');

    final raw = (data as List).cast<Map<String, dynamic>>();

    // Group by date
    final Map<String, double> grouped = {};
    for (final b in raw) {
      final d = b['booking_date'] as String;
      grouped[d] = (grouped[d] ?? 0) + (b['total_amount'] as num).toDouble();
    }

    final result = grouped.entries
        .map((e) => {'date': e.key, 'revenue': e.value})
        .toList();
    result.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return result;
  }

  // ---------------------------------------------------------------------------
  // Vehicles (derived from bookings)
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAllVehicles({String? assignedLocationId}) async {
    final data = await _client
        .from(AppConstants.tableBookings)
        .select('''
          vehicle_number, booking_date, created_at,
          parking_slots(location_id)
        ''')
        .order('created_at', ascending: false);

    var raw = (data as List).cast<Map<String, dynamic>>();
    if (assignedLocationId != null &&
        assignedLocationId.isNotEmpty &&
        assignedLocationId != 'ALL') {
      raw = raw.where((b) {
        final ps = b['parking_slots'] as Map<String, dynamic>?;
        return ps != null && ps['location_id'] == assignedLocationId;
      }).toList();
    }

    // Group by vehicle_number
    final Map<String, Map<String, dynamic>> vehicles = {};
    for (final b in raw) {
      final vn = b['vehicle_number'] as String? ?? '';
      if (vn.isEmpty) continue;
      if (!vehicles.containsKey(vn)) {
        vehicles[vn] = {
          'vehicle_number': vn,
          'visit_count': 0,
          'last_visit': b['booking_date'],
        };
      }
      vehicles[vn]!['visit_count'] =
          (vehicles[vn]!['visit_count'] as int) + 1;
    }

    return vehicles.values.toList()
      ..sort((a, b) =>
          (b['visit_count'] as int).compareTo(a['visit_count'] as int));
  }

  // ---------------------------------------------------------------------------
  // Add Location & Slots
  // ---------------------------------------------------------------------------

  Future<bool> addParkingLocation({
    required String name,
    required String address,
    required double pricePerHour,
    required int totalSlots,
    required List<String> amenities,
    String? imageUrl,
    String? googleMapsLink,
    String? floor,
    int carSlots = 0,
    int bikeSlots = 0,
    int evSlots = 0,
    List<FloorConfig>? floorConfigs,
  }) async {
    try {
      final locId = const Uuid().v4();

      int finalTotalSlots = totalSlots;
      if (floorConfigs != null && floorConfigs.isNotEmpty) {
        finalTotalSlots = floorConfigs.fold<int>(0, (sum, f) => sum + f.totalSlots);
      }

      final locData = {
        'id': locId,
        'name': name.trim(),
        'address': address.trim(),
        'price_per_hour': pricePerHour,
        'total_slots': finalTotalSlots,
        'amenities': amenities,
        'rating': 4.5,
        if (imageUrl != null && imageUrl.isNotEmpty)
          'image_url': imageUrl.trim(),
        if (googleMapsLink != null && googleMapsLink.isNotEmpty)
          'google_maps_link': googleMapsLink.trim(),
      };

      await _client
          .from(AppConstants.tableParkingLocations)
          .insert(locData);

      final List<Map<String, dynamic>> slotsToInsert = [];

      if (floorConfigs != null && floorConfigs.isNotEmpty) {
        // Multi-floor slot generation
        for (final fc in floorConfigs) {
          final flName = fc.floorName.trim();

          for (int i = 1; i <= fc.carSlots; i++) {
            slotsToInsert.add({
              'id': const Uuid().v4(),
              'location_id': locId,
              'slot_number': 'C-${i.toString().padLeft(2, '0')}',
              'slot_type': 'car',
              'is_active': true,
              'floor': flName,
            });
          }

          for (int i = 1; i <= fc.bikeSlots; i++) {
            slotsToInsert.add({
              'id': const Uuid().v4(),
              'location_id': locId,
              'slot_number': 'B-${i.toString().padLeft(2, '0')}',
              'slot_type': 'bike',
              'is_active': true,
              'floor': flName,
            });
          }

          for (int i = 1; i <= fc.evSlots; i++) {
            slotsToInsert.add({
              'id': const Uuid().v4(),
              'location_id': locId,
              'slot_number': 'E-${i.toString().padLeft(2, '0')}',
              'slot_type': 'ev',
              'is_active': true,
              'floor': flName,
            });
          }
        }
      } else {
        // Single floor / standard slot generation
        int cCount = carSlots;
        int bCount = bikeSlots;
        int eCount = evSlots;
        if (cCount == 0 && bCount == 0 && eCount == 0) {
          cCount = (totalSlots * 0.6).round();
          bCount = (totalSlots * 0.25).round();
          eCount = totalSlots - cCount - bCount;
          if (eCount < 0) eCount = 0;
        }

        for (int i = 1; i <= cCount; i++) {
          slotsToInsert.add({
            'id': const Uuid().v4(),
            'location_id': locId,
            'slot_number': 'C-${i.toString().padLeft(2, '0')}',
            'slot_type': 'car',
            'is_active': true,
            if (floor != null && floor.isNotEmpty) 'floor': floor.trim(),
          });
        }

        for (int i = 1; i <= bCount; i++) {
          slotsToInsert.add({
            'id': const Uuid().v4(),
            'location_id': locId,
            'slot_number': 'B-${i.toString().padLeft(2, '0')}',
            'slot_type': 'bike',
            'is_active': true,
            if (floor != null && floor.isNotEmpty) 'floor': floor.trim(),
          });
        }

        for (int i = 1; i <= eCount; i++) {
          slotsToInsert.add({
            'id': const Uuid().v4(),
            'location_id': locId,
            'slot_number': 'E-${i.toString().padLeft(2, '0')}',
            'slot_type': 'ev',
            'is_active': true,
            if (floor != null && floor.isNotEmpty) 'floor': floor.trim(),
          });
        }
      }

      if (slotsToInsert.isNotEmpty) {
        await _client
            .from(AppConstants.tableParkingSlots)
            .insert(slotsToInsert);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateGoogleMapsLink({
    required String locationId,
    required String googleMapsLink,
  }) async {
    try {
      await _client
          .from(AppConstants.tableParkingLocations)
          .update({'google_maps_link': googleMapsLink.trim()})
          .eq('id', locationId);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
