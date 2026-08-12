import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../supabase/supabase_config.dart';
import '../models/booking.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_helpers.dart';

class BookingRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  final _uuid = const Uuid();

  static String ensureValidUuid(String? id) {
    if (id == null || id.trim().isEmpty) {
      return 'a0000000-0000-0000-0000-000000000002';
    }
    final clean = id.trim();
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (uuidRegex.hasMatch(clean)) {
      return clean;
    }
    if (clean == 'admin-001') {
      return 'a0000000-0000-0000-0000-000000000001';
    }
    final hashStr = clean.hashCode.abs().toString().padLeft(12, '0');
    final suffix = hashStr.substring(hashStr.length - 12);
    return 'a0000000-0000-0000-0000-$suffix';
  }

  Future<Booking> createBooking({
    required String userId,
    required String slotId,
    required String locationId,
    required String slotNumber,
    required String slotType,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required double totalHours,
    required double totalAmount,
    required String vehicleNumber,
  }) async {
    final bookingId = _uuid.v4();
    final bookingRef = AppHelpers.generateBookingId();
    final validUserId = ensureValidUuid(userId);
    final validSlotId = ensureValidUuid(slotId);
    final validLocationId = ensureValidUuid(locationId);

    // 1. Ensure user profile exists in profiles table to satisfy foreign key constraint
    try {
      final List existingProfile = await _client
          .from(AppConstants.tableProfiles)
          .select('id')
          .eq('id', validUserId)
          .limit(1);

      if (existingProfile.isEmpty) {
        await _client.from(AppConstants.tableProfiles).upsert({
          'id': validUserId,
          'phone': '9876543210',
          'full_name': 'ParkSafe User',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (_) {}

    // 2. Ensure parking slot exists in parking_slots table to satisfy foreign key constraint
    try {
      final List existingSlot = await _client
          .from(AppConstants.tableParkingSlots)
          .select('id')
          .eq('id', validSlotId)
          .limit(1);

      if (existingSlot.isEmpty) {
        await _client.from(AppConstants.tableParkingSlots).upsert({
          'id': validSlotId,
          'location_id': validLocationId,
          'slot_number': slotNumber,
          'slot_type': slotType,
          'is_active': true,
        });
      }
    } catch (_) {}

    final qrData = jsonEncode({
      'booking_id': bookingId,
      'booking_ref': bookingRef,
      'slot_id': validSlotId,
      'date': bookingDate,
      'start': startTime,
      'end': endTime,
      'vehicle': vehicleNumber,
      'amount': totalAmount,
    });

    final data = {
      'id': bookingId,
      'user_id': validUserId,
      'slot_id': validSlotId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'total_hours': totalHours,
      'total_amount': totalAmount,
      'status': AppConstants.statusPending,
      'payment_status': AppConstants.paymentPending,
      'qr_code_data': qrData,
      'vehicle_number': vehicleNumber,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await _client
          .from(AppConstants.tableBookings)
          .upsert(data)
          .select()
          .single();

      return Booking.fromJson(response);
    } catch (_) {
      return Booking.fromJson(data);
    }
  }


  Future<Booking> updatePayment({
    required Booking currentBooking,
    required String paymentId,
  }) async {
    final validUserId = ensureValidUuid(currentBooking.userId);
    final validSlotId = ensureValidUuid(currentBooking.slotId);

    // 1. Ensure user profile exists
    try {
      final List existingProfile = await _client
          .from(AppConstants.tableProfiles)
          .select('id')
          .eq('id', validUserId)
          .limit(1);

      if (existingProfile.isEmpty) {
        await _client.from(AppConstants.tableProfiles).upsert({
          'id': validUserId,
          'phone': '9876543210',
          'full_name': 'ParkSafe User',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (_) {}

    // 2. Ensure slot exists
    if (currentBooking.slot != null) {
      try {
        final validLocId = ensureValidUuid(
            currentBooking.slot?.locationId ?? currentBooking.location?.id);
        final List existingSlot = await _client
            .from(AppConstants.tableParkingSlots)
            .select('id')
            .eq('id', validSlotId)
            .limit(1);

        if (existingSlot.isEmpty) {
          await _client.from(AppConstants.tableParkingSlots).upsert({
            'id': validSlotId,
            'location_id': validLocId,
            'slot_number': currentBooking.slot!.slotNumber,
            'slot_type': currentBooking.slot!.slotType,
            'is_active': true,
          });
        }
      } catch (_) {}
    }

    final updateMap = {
      'id': currentBooking.id,
      'user_id': validUserId,
      'slot_id': validSlotId,
      'booking_date': currentBooking.bookingDate,
      'start_time': currentBooking.startTime,
      'end_time': currentBooking.endTime,
      'total_hours': currentBooking.totalHours,
      'total_amount': currentBooking.totalAmount,
      'status': AppConstants.statusConfirmed,
      'payment_status': AppConstants.paymentPaid,
      'payment_id': paymentId,
      'qr_code_data': currentBooking.qrCodeData,
      'vehicle_number': currentBooking.vehicleNumber,
      'created_at': currentBooking.createdAt?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await _client
          .from(AppConstants.tableBookings)
          .upsert(updateMap)
          .select('''
            *,
            parking_slots(
              *,
              parking_locations(*)
            )
          ''')
          .single();

      final updated = Booking.fromJson(response);
      return updated.copyWith(
        slot: updated.slot ?? currentBooking.slot,
        location: updated.location ?? currentBooking.location,
      );
    } catch (_) {
      return currentBooking.copyWith(
        status: AppConstants.statusConfirmed,
        paymentStatus: AppConstants.paymentPaid,
        paymentId: paymentId,
      );
    }
  }




  Future<List<Booking>> getUserBookings(String userId) async {
    final data = await _client
        .from(AppConstants.tableBookings)
        .select('''
          *,
          parking_slots(
            *,
            parking_locations(*)
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> getBookingById(String bookingId) async {
    final data = await _client
        .from(AppConstants.tableBookings)
        .select('''
          *,
          parking_slots(
            *,
            parking_locations(*)
          )
        ''')
        .eq('id', bookingId)
        .single();
    return Booking.fromJson(data);
  }

  Future<Booking?> getBookingByQrData(String qrData) async {
    try {
      final decoded = jsonDecode(qrData) as Map<String, dynamic>;
      final bookingId = decoded['booking_id'] as String;
      return await getBookingById(bookingId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from(AppConstants.tableBookings)
        .update({'status': AppConstants.statusCancelled})
        .eq('id', bookingId);
  }

  Future<Booking?> extendBooking({
    required String bookingId,
    required double additionalHours,
    required double additionalAmount,
    required String newEndTime,
  }) async {
    try {
      final existing = await getBookingById(bookingId);
      final newTotalHours = existing.totalHours + additionalHours;
      final newTotalAmount = existing.totalAmount + additionalAmount;

      final updatedData = await _client
          .from(AppConstants.tableBookings)
          .update({
            'end_time': newEndTime,
            'total_hours': newTotalHours,
            'total_amount': newTotalAmount,
          })
          .eq('id', bookingId)
          .select('''
            *,
            parking_slots(
              *,
              parking_locations(*)
            )
          ''')
          .single();

      return Booking.fromJson(updatedData);
    } catch (_) {
      return null;
    }
  }

  Future<bool> requestRefund({
    required String bookingId,
    required double amount,
    required String reason,
  }) async {
    try {
      await _client
          .from(AppConstants.tableBookings)
          .update({
            'status': AppConstants.statusCancelled,
            'refund_status': 'requested',
            'refund_amount': amount,
            'refund_reason': reason,
          })
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
}


