import 'package:flutter_test/flutter_test.dart';
import 'package:parksafe/data/models/booking.dart';

void main() {
  group('Booking Timezone & Timestamp Tests', () {
    test('Correctly parses legacy double-converted IST check-in timestamp', () {
      // Legacy DB record: check-in at 09:25 AM IST was saved as "2026-08-12T09:25:00+00:00"
      final json = {
        'id': 'test-1',
        'user_id': 'user-1',
        'slot_id': 'slot-1',
        'booking_date': '2026-08-12',
        'start_time': '09:00 AM',
        'end_time': '11:00 AM',
        'total_hours': 2.0,
        'total_amount': 100.0,
        'status': 'checked_in',
        'payment_status': 'paid',
        'vehicle_number': 'MH12AB1234',
        'actual_check_in': '2026-08-12T09:25:00+00:00',
        'actual_check_out': null,
        'overtime_fee': 0.0,
      };

      final booking = Booking.fromJson(json);

      expect(booking.actualCheckIn, isNotNull);
      final actualIn = booking.actualCheckIn!;
      expect(actualIn.hour, 9);
      expect(actualIn.minute, 25);

      final schedStart = booking.scheduledStartDateTime!;
      final diff = actualIn.difference(schedStart).inMinutes;
      expect(diff, 25); // 25 mins late, NOT 355/356 mins late!
    });

    test('Correctly parses UTC formatted check-in timestamp from new code', () {
      // New DB record: device checked in at 09:25 AM IST (03:55 AM UTC), saved as "2026-08-12T03:55:00.000Z"
      final json = {
        'id': 'test-2',
        'user_id': 'user-1',
        'slot_id': 'slot-1',
        'booking_date': '2026-08-12',
        'start_time': '09:00 AM',
        'end_time': '11:00 AM',
        'total_hours': 2.0,
        'total_amount': 100.0,
        'status': 'checked_in',
        'payment_status': 'paid',
        'vehicle_number': 'MH12AB1234',
        'actual_check_in': '2026-08-12T03:55:00.000Z',
        'actual_check_out': null,
        'overtime_fee': 0.0,
      };

      final booking = Booking.fromJson(json);

      expect(booking.actualCheckIn, isNotNull);
      final actualIn = booking.actualCheckIn!.toLocal();
      expect(actualIn.hour, 9);
      expect(actualIn.minute, 25);

      final schedStart = booking.scheduledStartDateTime!.toLocal();
      final diff = actualIn.difference(schedStart).inMinutes;
      expect(diff, 25);
    });
  });
}
