import 'package:flutter/material.dart';
import '../data/repositories/admin_repository.dart';
import '../data/models/booking.dart';
import '../data/models/parking_location.dart';
import '../data/models/user_profile.dart';
import '../data/models/floor_config.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repo = AdminRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  // Admin Profile & Location Access Context
  UserProfile? _adminProfile;
  String? _assignedLocationName;

  bool _isLoading = false;
  String? _error;

  // Dashboard
  Map<String, dynamic> _dashboardStats = {};

  // Bookings
  List<Booking> _allBookings = [];
  List<Booking> _todaysBookings = [];

  // QR scan result
  Booking? _scannedBooking;
  UserProfile? _scannedUser;
  bool _isScanLoading = false;
  String? _scanError;

  // Customers
  List<UserProfile> _customers = [];
  List<Booking> _customerBookings = [];
  bool _isLoadingCustomerBookings = false;

  // Vehicles
  List<Map<String, dynamic>> _vehicles = [];

  // Slots
  List<Map<String, dynamic>> _slotsWithLocation = [];
  List<ParkingLocation> _locations = [];

  // Revenue
  List<Map<String, dynamic>> _revenueByDate = [];

  // ---------------------------------------------------------------------------
  // Getters & Context Initialization
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProfile? get adminProfile => _adminProfile;
  String? get assignedLocationId => _adminProfile?.assignedLocationId;
  String get assignedLocationName =>
      _assignedLocationName ?? _resolveDefaultLocationName(_adminProfile);

  bool get isSuperAdmin =>
      _adminProfile?.role == 'super_admin' ||
      (_adminProfile?.role == 'admin' &&
          (_adminProfile?.assignedLocationId == null ||
              _adminProfile?.assignedLocationId == 'ALL' ||
              _adminProfile?.assignedLocationId == ''));

  Map<String, dynamic> get dashboardStats => _dashboardStats;

  List<Booking> get allBookings => _allBookings;
  List<Booking> get todaysBookings => _todaysBookings;

  Booking? get scannedBooking => _scannedBooking;
  UserProfile? get scannedUser => _scannedUser;
  bool get isScanLoading => _isScanLoading;
  String? get scanError => _scanError;

  List<UserProfile> get customers => _customers;
  List<Booking> get customerBookings => _customerBookings;
  bool get isLoadingCustomerBookings => _isLoadingCustomerBookings;

  List<Map<String, dynamic>> get vehicles => _vehicles;

  List<Map<String, dynamic>> get slotsWithLocation => _slotsWithLocation;
  List<ParkingLocation> get locations => _locations;

  List<Map<String, dynamic>> get revenueByDate => _revenueByDate;

  void setAdminContext(UserProfile? profile) {
    _adminProfile = profile;
    _assignedLocationName = _resolveDefaultLocationName(profile);
    notifyListeners();
  }

  String _resolveDefaultLocationName(UserProfile? profile) {
    if (profile == null) return 'Main Admin (All Locations)';
    final locId = profile.assignedLocationId;
    if (locId == 'b0000000-0000-0000-0000-000000000034') return 'Surat VR Mall';
    if (locId == 'b0000000-0000-0000-0000-000000000009') return 'Mumbai Airport';
    if (locId == 'b0000000-0000-0000-0000-000000000051') return 'Surat RR Mall';

    if (profile.fullName != null && profile.fullName!.isNotEmpty) {
      if (profile.fullName!.contains('Admin')) {
        return profile.fullName!.replaceAll('Admin', '').trim();
      }
      return profile.fullName!;
    }

    if (profile.role == 'super_admin' || locId == null || locId.isEmpty) {
      return 'All Parking Locations';
    }
    return 'Assigned Location';
  }

  // ---------------------------------------------------------------------------
  // Location Access Control & QR Validation Rules
  // ---------------------------------------------------------------------------

  /// Verifies whether the logged-in Admin is authorized to scan/check-in/check-out this booking.
  /// Rule: Admin Location == Booking Location OR Main Admin.
  bool isQrValid(Booking booking) {
    if (isSuperAdmin) return true;
    final adminLocId = assignedLocationId;
    if (adminLocId == null || adminLocId.isEmpty || adminLocId == 'ALL') {
      return true;
    }

    final bookingLocId = booking.slot?.locationId ?? booking.location?.id;
    if (bookingLocId != null && bookingLocId.isNotEmpty) {
      return bookingLocId == adminLocId;
    }

    // Fallback name matching if IDs are missing or unpopulated
    final adminName = assignedLocationName.toLowerCase().replaceAll('admin', '').trim();
    final bookingName = (booking.location?.name ?? '').toLowerCase().trim();

    if (adminName.isNotEmpty && bookingName.isNotEmpty) {
      return bookingName.contains(adminName) || adminName.contains(bookingName);
    }
    return false;
  }

  Map<String, dynamic> validateBookingLocation(Booking booking) {
    final isValid = isQrValid(booking);
    final bookingLocName = booking.location?.name ?? 'Unknown Location';
    final adminLocName = assignedLocationName;

    if (isValid) {
      return {
        'isValid': true,
        'statusText': 'QR Valid',
        'message':
            'Customer QR booking location ($bookingLocName) matches logged-in admin assigned location.',
        'bookingLocation': bookingLocName,
        'adminLocation': adminLocName,
      };
    } else {
      return {
        'isValid': false,
        'statusText': 'QR Not Valid',
        'message':
            'QR Not Valid: Customer booking is for "$bookingLocName", but you are logged in as "$adminLocName" Admin. Check-In and Check-Out are blocked.',
        'bookingLocation': bookingLocName,
        'adminLocation': adminLocName,
      };
    }
  }

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboardStats = await _repo.getDashboardStats(assignedLocationId: assignedLocationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------------------

  Future<void> loadAllBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allBookings = await _repo.getAllBookings(assignedLocationId: assignedLocationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodaysBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _todaysBookings = await _repo.getTodaysBookings(assignedLocationId: assignedLocationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // QR Scan
  // ---------------------------------------------------------------------------

  void clearScan() {
    _scannedBooking = null;
    _scannedUser = null;
    _scanError = null;
    notifyListeners();
  }

  Future<bool> scanAndFetchBooking(String qrData) async {
    _isScanLoading = true;
    _scanError = null;
    notifyListeners();

    try {
      final result = await _repo.getBookingWithUserByQr(qrData);
      if (result == null) {
        _scanError = 'Booking not found. Invalid QR code.';
        _isScanLoading = false;
        notifyListeners();
        return false;
      }
      _scannedBooking = result['booking'] as Booking?;
      _scannedUser = result['user'] as UserProfile?;
      _isScanLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _scanError = 'Failed to load booking: ${e.toString()}';
      _isScanLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadBookingById(String bookingId) async {
    _isScanLoading = true;
    _scanError = null;
    notifyListeners();

    try {
      final result = await _repo.getBookingWithUserById(bookingId);
      if (result == null) {
        _scanError = 'Booking not found.';
        _isScanLoading = false;
        notifyListeners();
        return false;
      }
      _scannedBooking = result['booking'] as Booking?;
      _scannedUser = result['user'] as UserProfile?;
      _isScanLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _scanError = e.toString();
      _isScanLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> searchByVehicleNumber(String vehicleNumber) async {
    _isScanLoading = true;
    _scanError = null;
    notifyListeners();

    try {
      final result = await _repo.getBookingWithUserById(vehicleNumber);
      if (result == null) {
        _scanError = 'No active booking found for vehicle number "$vehicleNumber".';
        _isScanLoading = false;
        notifyListeners();
        return false;
      }
      _scannedBooking = result['booking'] as Booking?;
      _scannedUser = result['user'] as UserProfile?;
      _isScanLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _scanError = e.toString();
      _isScanLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> processRefund({
    required String bookingId,
    required String refundStatus,
    String? reason,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.processRefund(
        bookingId: bookingId,
        refundStatus: refundStatus,
        reason: reason,
      );
      if (success) {
        _allBookings = _allBookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(
              refundStatus: refundStatus,
              refundReason: reason ?? b.refundReason,
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


  // ---------------------------------------------------------------------------
  // Check In / Check Out
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> checkIn(String bookingId) async {
    if (_scannedBooking != null && _scannedBooking!.id == bookingId) {
      if (!isQrValid(_scannedBooking!)) {
        final val = validateBookingLocation(_scannedBooking!);
        return {
          'success': false,
          'message': val['message'],
          'qrInvalid': true,
        };
      }
    }
    final result = await _repo.checkIn(bookingId);
    if (result['success'] == true) {
      // Update local state
      final now = DateTime.now();
      _scannedBooking = _bookingWithStatus(_scannedBooking, 'checked_in', actualCheckIn: now);
      _refreshBookingInLists(bookingId, 'checked_in', actualCheckIn: now);
      notifyListeners();
    }
    return result;
  }

  Future<bool> checkOut(String bookingId) async {
    if (_scannedBooking != null && _scannedBooking!.id == bookingId) {
      if (!isQrValid(_scannedBooking!)) {
        _scanError = 'QR Not Valid: Location mismatch. Check-Out blocked.';
        notifyListeners();
        return false;
      }
    }
    final success = await _repo.checkOut(bookingId);
    if (success) {
      final now = DateTime.now();
      _scannedBooking = _bookingWithStatus(_scannedBooking, 'completed', actualCheckOut: now);
      _refreshBookingInLists(bookingId, 'completed', actualCheckOut: now);
      // Re-fetch booking from DB to ensure exact overtime fee is synced
      try {
        final result = await _repo.getBookingWithUserById(bookingId);
        if (result != null && result['booking'] != null) {
          _scannedBooking = result['booking'] as Booking;
        }
      } catch (_) {}
      notifyListeners();
    }
    return success;
  }

  Booking? _bookingWithStatus(Booking? b, String status, {DateTime? actualCheckIn, DateTime? actualCheckOut}) {
    if (b == null) return null;
    final updatedOut = actualCheckOut ?? b.actualCheckOut;
    final updatedIn = actualCheckIn ?? b.actualCheckIn;

    double calculatedOvertime = b.overtimeFee;
    if (updatedOut != null && b.scheduledEndDateTime != null) {
      final outLocal = updatedOut.toLocal();
      final schedEndLocal = b.scheduledEndDateTime!.toLocal();
      if (outLocal.isAfter(schedEndLocal)) {
        final mins = outLocal.difference(schedEndLocal).inMinutes;
        if (mins > 0) {
          final rate = (b.location?.pricePerHour != null && b.location!.pricePerHour > 0)
              ? b.location!.pricePerHour
              : (b.totalHours > 0 ? (b.totalAmount / b.totalHours) : 50.0);
          final extraHours = (mins / 60.0).ceil();
          calculatedOvertime = extraHours * rate;
        }
      }
    }

    return Booking(
      id: b.id,
      userId: b.userId,
      slotId: b.slotId,
      bookingDate: b.bookingDate,
      startTime: b.startTime,
      endTime: b.endTime,
      totalHours: b.totalHours,
      totalAmount: b.totalAmount,
      status: status,
      paymentStatus: b.paymentStatus,
      vehicleNumber: b.vehicleNumber,
      paymentId: b.paymentId,
      qrCodeData: b.qrCodeData,
      actualCheckIn: updatedIn,
      actualCheckOut: updatedOut,
      overtimeFee: calculatedOvertime > 0 ? calculatedOvertime : b.overtimeFee,
      createdAt: b.createdAt,
      slot: b.slot,
      location: b.location,
    );
  }

  void _refreshBookingInLists(String bookingId, String newStatus, {DateTime? actualCheckIn, DateTime? actualCheckOut}) {
    _allBookings = _allBookings.map((b) {
      if (b.id == bookingId) {
        return _bookingWithStatus(b, newStatus, actualCheckIn: actualCheckIn, actualCheckOut: actualCheckOut)!;
      }
      return b;
    }).toList();
    _todaysBookings = _todaysBookings.map((b) {
      if (b.id == bookingId) {
        return _bookingWithStatus(b, newStatus, actualCheckIn: actualCheckIn, actualCheckOut: actualCheckOut)!;
      }
      return b;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Customers
  // ---------------------------------------------------------------------------

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _customers = await _repo.getAllCustomers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerBookings(String userId) async {
    _isLoadingCustomerBookings = true;
    notifyListeners();
    try {
      _customerBookings = await _repo.getBookingsForUser(userId);
    } catch (_) {
      _customerBookings = [];
    } finally {
      _isLoadingCustomerBookings = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Vehicles
  // ---------------------------------------------------------------------------

  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _vehicles = await _repo.getAllVehicles(assignedLocationId: assignedLocationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Slots
  // ---------------------------------------------------------------------------

  Future<void> loadSlots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _slotsWithLocation = await _repo.getAllSlotsWithLocation(assignedLocationId: assignedLocationId);
      _locations = await _repo.getAllLocations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Revenue
  // ---------------------------------------------------------------------------

  Future<void> loadRevenue() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _revenueByDate = await _repo.getRevenueByDate(days: 30);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repo.addParkingLocation(
        name: name,
        address: address,
        pricePerHour: pricePerHour,
        totalSlots: totalSlots,
        amenities: amenities,
        imageUrl: imageUrl,
        googleMapsLink: googleMapsLink,
        floor: floor,
        carSlots: carSlots,
        bikeSlots: bikeSlots,
        evSlots: evSlots,
        floorConfigs: floorConfigs,
      );
      if (success) {
        await loadSlots();
        await loadDashboardStats();
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

  Future<bool> updateGoogleMapsLink({
    required String locationId,
    required String googleMapsLink,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repo.updateGoogleMapsLink(
        locationId: locationId,
        googleMapsLink: googleMapsLink,
      );
      if (success) {
        await loadSlots();
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

  Future<bool> updateSlotFloor(String slotId, String floor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repo.updateSlotFloor(slotId, floor);
      if (success) {
        await loadSlots(); // Refresh slot list
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
