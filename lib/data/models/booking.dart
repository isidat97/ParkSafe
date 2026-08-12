import 'parking_slot.dart';
import 'parking_location.dart';

class Booking {
  final String id;
  final String userId;
  final String slotId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final double totalHours;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? paymentId;
  final String? qrCodeData;
  final String vehicleNumber;
  final DateTime? actualCheckIn;
  final DateTime? actualCheckOut;
  final double overtimeFee;
  final String refundStatus;
  final double refundAmount;
  final String? refundReason;
  final DateTime? createdAt;
  final ParkingSlot? slot;
  final ParkingLocation? location;

  Booking({
    required this.id,
    required this.userId,
    required this.slotId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.vehicleNumber,
    this.paymentId,
    this.qrCodeData,
    this.actualCheckIn,
    this.actualCheckOut,
    this.overtimeFee = 0.0,
    this.refundStatus = 'none',
    this.refundAmount = 0.0,
    this.refundReason,
    this.createdAt,
    this.slot,
    this.location,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final bookingDate = json['booking_date'] as String;
    final startTime = json['start_time'] as String;

    DateTime? parseTimestampField(String? isoString) {
      if (isoString == null || isoString.isEmpty) return null;
      final parsed = DateTime.parse(isoString);
      final local = parsed.toLocal();

      // Scheduled start dateTime to test for legacy timezone offset shift
      final schedStart = parseBookingDateTime(
        bookingDate.contains(' to ')
            ? bookingDate.split(' to ')[0].trim()
            : bookingDate.trim(),
        startTime,
      );

      if (schedStart != null && parsed.isUtc) {
        final diffLocal = local.difference(schedStart).inMinutes;
        final unshifted = DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
        );
        final diffUnshifted = unshifted.difference(schedStart).inMinutes;

        // If local is shifted by timezone offset (~5h30m = 330 mins) making diffLocal huge compared to diffUnshifted
        if ((diffLocal - diffUnshifted).abs() >= 300 &&
            diffUnshifted.abs() < diffLocal.abs()) {
          return unshifted;
        }
      }
      return local;
    }

    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      slotId: json['slot_id'] as String,
      bookingDate: bookingDate,
      startTime: startTime,
      endTime: json['end_time'] as String,
      totalHours: (json['total_hours'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      paymentId: json['payment_id'] as String?,
      qrCodeData: json['qr_code_data'] as String?,
      vehicleNumber: json['vehicle_number'] as String? ?? '',
      actualCheckIn: parseTimestampField(json['actual_check_in'] as String?),
      actualCheckOut: parseTimestampField(json['actual_check_out'] as String?),
      overtimeFee: json['overtime_fee'] != null
          ? (json['overtime_fee'] as num).toDouble()
          : 0.0,
      refundStatus: json['refund_status'] as String? ?? 'none',
      refundAmount: json['refund_amount'] != null
          ? (json['refund_amount'] as num).toDouble()
          : 0.0,
      refundReason: json['refund_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      slot: json['parking_slots'] != null
          ? ParkingSlot.fromJson(json['parking_slots'] as Map<String, dynamic>)
          : null,
      location: json['parking_slots']?['parking_locations'] != null
          ? ParkingLocation.fromJson(
              json['parking_slots']['parking_locations'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'slot_id': slotId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'total_hours': totalHours,
      'total_amount': totalAmount,
      'status': status,
      'payment_status': paymentStatus,
      'payment_id': paymentId,
      'qr_code_data': qrCodeData,
      'vehicle_number': vehicleNumber,
      'actual_check_in': actualCheckIn?.toUtc().toIso8601String(),
      'actual_check_out': actualCheckOut?.toUtc().toIso8601String(),
      'overtime_fee': overtimeFee,
      'refund_status': refundStatus,
      'refund_amount': refundAmount,
      'refund_reason': refundReason,
    };
  }

  /// Helper method to robustly parse Date and Time strings (supports 12-hour AM/PM and 24-hour)
  static DateTime? parseBookingDateTime(String rawDateStr, String rawTimeStr) {
    try {
      final dateClean = rawDateStr.trim();
      final dateParts = dateClean.split(RegExp(r'[-/\.]'));
      if (dateParts.length != 3) return null;

      int year, month, day;
      if (dateParts[0].length == 4) {
        year = int.parse(dateParts[0]);
        month = int.parse(dateParts[1]);
        day = int.parse(dateParts[2]);
      } else if (dateParts[2].length == 4) {
        year = int.parse(dateParts[2]);
        month = int.parse(dateParts[1]);
        day = int.parse(dateParts[0]);
      } else {
        return null;
      }

      final timeClean = rawTimeStr.trim().toUpperCase();
      final isPM = timeClean.contains('PM');
      final isAM = timeClean.contains('AM');

      final timeDigits = timeClean.replaceAll(RegExp(r'[^0-9:]'), '');
      final timeParts = timeDigits.split(':');
      if (timeParts.length < 2) return null;

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Calculates scheduled end DateTime
  DateTime? get scheduledEndDateTime {
    final rawDate = bookingDate.contains(' to ')
        ? bookingDate.split(' to ')[1].trim()
        : bookingDate.trim();
    return parseBookingDateTime(rawDate, endTime);
  }

  /// Calculates scheduled start DateTime
  DateTime? get scheduledStartDateTime {
    final rawDate = bookingDate.contains(' to ')
        ? bookingDate.split(' to ')[0].trim()
        : bookingDate.trim();
    return parseBookingDateTime(rawDate, startTime);
  }

  /// Returns overtime duration in minutes (only after scheduled checkout time has passed)
  int get overtimeMinutes {
    final schedEnd = scheduledEndDateTime;
    if (schedEnd == null) return 0;

    if (actualCheckOut != null) {
      final checkOut = actualCheckOut!.toLocal();
      if (checkOut.isAfter(schedEnd)) {
        return checkOut.difference(schedEnd).inMinutes;
      }
    } else if (status != 'cancelled' && status != 'completed') {
      final now = DateTime.now();
      if (now.isAfter(schedEnd)) {
        return now.difference(schedEnd).inMinutes;
      }
    }
    return 0;
  }

  /// Dynamic effective overtime fee (minimum 1 hour charge rate for any overdue minutes past end time)
  double get effectiveOvertimeFee {
    if (overtimeFee > 0) return overtimeFee;
    final mins = overtimeMinutes;
    if (mins <= 0) return 0.0;

    final rate = (location?.pricePerHour != null && location!.pricePerHour > 0)
        ? location!.pricePerHour
        : (totalHours > 0 ? (totalAmount / totalHours) : 50.0);

    final extraHours = (mins / 60.0).ceil();
    return extraHours * rate;
  }

  /// Checks if overtime applies
  bool get hasOvertime => overtimeFee > 0 || effectiveOvertimeFee > 0 || overtimeMinutes > 0;

  Booking copyWith({
    String? status,
    String? paymentStatus,
    String? paymentId,
    String? qrCodeData,
    DateTime? actualCheckIn,
    DateTime? actualCheckOut,
    double? overtimeFee,
    String? refundStatus,
    double? refundAmount,
    String? refundReason,
    String? endTime,
    double? totalHours,
    double? totalAmount,
    ParkingSlot? slot,
    ParkingLocation? location,
  }) {
    return Booking(
      id: id,
      userId: userId,
      slotId: slotId,
      bookingDate: bookingDate,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      vehicleNumber: vehicleNumber,
      paymentId: paymentId ?? this.paymentId,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      actualCheckIn: actualCheckIn ?? this.actualCheckIn,
      actualCheckOut: actualCheckOut ?? this.actualCheckOut,
      overtimeFee: overtimeFee ?? this.overtimeFee,
      refundStatus: refundStatus ?? this.refundStatus,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      createdAt: createdAt,
      slot: slot ?? this.slot,
      location: location ?? this.location,
    );
  }

}

