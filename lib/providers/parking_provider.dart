import 'package:flutter/material.dart';
import '../data/repositories/parking_repository.dart';
import '../data/models/parking_location.dart';
import '../data/models/parking_slot.dart';

class ParkingProvider extends ChangeNotifier {
  final ParkingRepository _repo = ParkingRepository();

  List<ParkingLocation> _locations = [];
  List<ParkingSlot> _slots = [];
  ParkingLocation? _selectedLocation;
  ParkingSlot? _selectedSlot;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  String? _selectedCity;

  List<ParkingLocation> get locations => _locations;
  List<ParkingSlot> get slots => _slots;
  ParkingLocation? get selectedLocation => _selectedLocation;
  ParkingSlot? get selectedSlot => _selectedSlot;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;

  List<ParkingLocation> get filteredLocations {
    var result = _locations;

    if (_selectedCity != null && _selectedCity != 'All Cities') {
      final cityLower = _selectedCity!.toLowerCase();
      result = result.where((l) =>
          l.address.toLowerCase().contains(cityLower) ||
          l.name.toLowerCase().contains(cityLower)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      result = result.where((l) =>
          l.name.toLowerCase().contains(queryLower) ||
          l.address.toLowerCase().contains(queryLower)).toList();
    }

    return result;
  }

  void selectCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }


  Future<void> loadLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _locations = await _repo.getLocations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSlots({
    required String locationId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    _isLoading = true;
    _selectedSlot = null;
    _error = null;
    notifyListeners();

    try {
      _slots = await _repo.getSlotsForLocation(
        locationId: locationId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLocation(ParkingLocation location) {
    _selectedLocation = location;
    _slots = [];
    _selectedSlot = null;
    notifyListeners();
  }

  void selectSlot(ParkingSlot? slot) {
    // Deselect all
    for (var s in _slots) {
      s.isSelected = false;
    }
    if (slot != null) {
      slot.isSelected = true;
    }
    _selectedSlot = slot;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSlot = null;
    _selectedLocation = null;
    for (var s in _slots) {
      s.isSelected = false;
    }
    notifyListeners();
  }
}
