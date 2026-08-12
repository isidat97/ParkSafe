import 'package:flutter/material.dart';
import '../data/repositories/booking_repository.dart';
import '../data/models/booking.dart';
import '../data/models/parking_slot.dart';
import '../data/models/parking_location.dart';
import '../core/services/notification_service.dart';

enum BookingStep { initial, selecting, confirming, paying, confirmed }

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repo = BookingRepository();

  List<Booking> _bookings = [];
  Booking? _currentBooking;
  BookingStep _step = BookingStep.initial;
  bool _isLoading = false;
  String? _error;

  // Booking form state
  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  DateTime? _startTime;
  DateTime? _endTime;
  String _vehicleNumber = '';

  List<Booking> get bookings => _bookings;
  Booking? get currentBooking => _currentBooking;
  BookingStep get step => _step;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedEndDate => _selectedEndDate ?? _selectedDate;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  String get vehicleNumber => _vehicleNumber;

  double get totalHours {
    if (_selectedDate == null || _startTime == null || _endTime == null) return 0;
    
    final startDate = _selectedDate!;
    final endDate = _selectedEndDate ?? _selectedDate!;

    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final diffInMinutes = endDateTime.difference(startDateTime).inMinutes;
    if (diffInMinutes <= 0) return 1.0;
    return (diffInMinutes / 60.0);
  }

  double calculateAmount(double pricePerHour) {
    return totalHours * pricePerHour;
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    if (_selectedEndDate != null && _selectedEndDate!.isBefore(date)) {
      _selectedEndDate = date;
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _selectedEndDate = date;
    if (_selectedDate != null && _selectedDate!.isAfter(date)) {
      _selectedDate = date;
    }
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    _selectedDate = start;
    _selectedEndDate = end;
    notifyListeners();
  }

  void setStartTime(DateTime time) {
    _startTime = time;
    if (_endTime != null && _selectedDate != null && (_selectedEndDate == null || _selectedEndDate == _selectedDate)) {
      if (_endTime!.isBefore(_startTime!)) {
        _endTime = _startTime!.add(const Duration(hours: 1));
      }
    }
    notifyListeners();
  }

  void setEndTime(DateTime time) {
    _endTime = time;
    notifyListeners();
  }

  void setVehicleNumber(String value) {
    _vehicleNumber = value;
    notifyListeners();
  }

  Future<bool> createBooking({
    required String userId,
    required ParkingSlot slot,
    required ParkingLocation location,
  }) async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      _error = 'Please select date and time';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final startDateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final endDate = _selectedEndDate ?? _selectedDate!;
      final endDateStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final dateStr = (startDateStr == endDateStr)
          ? startDateStr
          : '$startDateStr to $endDateStr';

      final startStr =
          '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00';
      final endStr =
          '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00';
      final amount = calculateAmount(location.pricePerHour);

      // Fraud / Anomaly Detection Check: Ensure no overlapping bookings for the same vehicle
      final newStart = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _startTime!.hour, _startTime!.minute
      );
      final newEnd = DateTime(
        endDate.year, endDate.month, endDate.day,
        _endTime!.hour, _endTime!.minute
      );

      final hasOverlap = await _repo.hasOverlappingBooking(
        vehicleNumber: _vehicleNumber,
        bookingDate: dateStr,
        newStart: newStart,
        newEnd: newEnd,
      );

      if (hasOverlap) {
        _error = 'Fraud Alert: This vehicle already has an overlapping booking during this time period.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final created = await _repo.createBooking(
        userId: userId,
        slotId: slot.id,
        locationId: location.id,
        slotNumber: slot.slotNumber,
        slotType: slot.slotType,
        bookingDate: dateStr,
        startTime: startStr,
        endTime: endStr,
        totalHours: totalHours,
        totalAmount: amount,
        vehicleNumber: _vehicleNumber,
      );


      _currentBooking = created.copyWith(
        slot: slot,
        location: location,
      );
      _step = BookingStep.confirming;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmPayment({required String paymentId}) async {
    if (_currentBooking == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repo.updatePayment(
        currentBooking: _currentBooking!,
        paymentId: paymentId,
      );

      _currentBooking = updated;

      // Add to local _bookings list immediately so it shows under My Bookings right away
      final existingIndex =
          _bookings.indexWhere((b) => b.id == _currentBooking!.id);
      if (existingIndex != -1) {
        _bookings[existingIndex] = _currentBooking!;
      } else {
        _bookings.insert(0, _currentBooking!);
      }

      _step = BookingStep.confirmed;

      // Requirement 5: Schedule Automated Check-In & Check-Out Push Reminders
      NotificationService().scheduleBookingReminders(_currentBooking!);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dbBookings = await _repo.getUserBookings(userId);

      // Merge DB bookings with local in-memory bookings
      final Map<String, Booking> map = {};
      for (var b in _bookings) {
        map[b.id] = b;
      }
      for (var b in dbBookings) {
        map[b.id] = b;
      }

      _bookings = map.values.toList()
        ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<Booking?> getBookingByQr(String qrData) async {
    return await _repo.getBookingByQrData(qrData);
  }

  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.cancelBooking(bookingId);
      NotificationService().cancelBookingReminders(bookingId);
      _bookings = _bookings.map((b) {
        if (b.id == bookingId) return b.copyWith(status: 'cancelled');
        return b;
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestRefund({
    required String bookingId,
    required double amount,
    required String reason,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.requestRefund(
        bookingId: bookingId,
        amount: amount,
        reason: reason,
      );
      if (success) {
        NotificationService().cancelBookingReminders(bookingId);
        _bookings = _bookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(
              status: 'cancelled',
              refundStatus: 'requested',
              refundAmount: amount,
              refundReason: reason,
            );
          }
          return b;
        }).toList();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> extendBooking({
    required String bookingId,
    required double additionalHours,
    required double pricePerHour,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      final existing = existingIndex != -1 ? _bookings[existingIndex] : null;
      if (existing == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final schedEnd = existing.scheduledEndDateTime ?? DateTime.now();
      final newEndDateTime = schedEnd.add(Duration(minutes: (additionalHours * 60).round()));
      final newEndTimeStr =
          '${newEndDateTime.hour.toString().padLeft(2, '0')}:${newEndDateTime.minute.toString().padLeft(2, '0')}:00';
      final additionalAmount = additionalHours * pricePerHour;

      final updatedBooking = await _repo.extendBooking(
        bookingId: bookingId,
        additionalHours: additionalHours,
        additionalAmount: additionalAmount,
        newEndTime: newEndTimeStr,
      );

      if (updatedBooking != null) {
        if (existingIndex != -1) {
          _bookings[existingIndex] = updatedBooking;
        }
        if (_currentBooking?.id == bookingId) {
          _currentBooking = updatedBooking;
        }
      } else {
        // Fallback update local state if DB update returns null
        final fallback = existing.copyWith(
          endTime: newEndTimeStr,
          totalHours: existing.totalHours + additionalHours,
          totalAmount: existing.totalAmount + additionalAmount,
        );
        if (existingIndex != -1) {
          _bookings[existingIndex] = fallback;
        }
        if (_currentBooking?.id == bookingId) {
          _currentBooking = fallback;
        }
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _currentBooking = null;
    _step = BookingStep.initial;
    _selectedDate = null;
    _startTime = null;
    _endTime = null;
    _vehicleNumber = '';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

