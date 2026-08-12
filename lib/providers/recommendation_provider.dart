import 'package:flutter/material.dart';
import '../data/repositories/recommendation_repository.dart';
import '../data/models/recommendation_result.dart';
import 'package:geolocator/geolocator.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationRepository _repo = RecommendationRepository();

  List<RecommendationResult> _recommendations = [];
  bool _isLoading = false;
  bool _isLocationLoading = false;
  String? _error;
  String _selectedVehicleType = 'car'; // Default to car

  List<RecommendationResult> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  bool get isLocationLoading => _isLocationLoading;
  String? get error => _error;
  String get selectedVehicleType => _selectedVehicleType;

  void setVehicleType(String type) {
    if (_selectedVehicleType != type) {
      _selectedVehicleType = type;
      notifyListeners();
      // Auto refresh if we already have recommendations (meaning we already got location)
      // For a better UX, we just re-trigger the fetch.
      fetchRecommendations();
    }
  }

  Future<void> fetchRecommendations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Get location
      _isLocationLoading = true;
      notifyListeners();
      
      double lat = 0.0;
      double lng = 0.0;
      
      try {
        final position = await _repo.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      } catch (e) {
        // Fallback to a default location (Surat) if location fails (e.g., timeout on web)
        print('Location fetch failed: $e, falling back to default location.');
        lat = 21.1702;
        lng = 72.8311;
      }
      
      _isLocationLoading = false;
      notifyListeners();

      // Step 2: Fetch recommendations
      _recommendations = await _repo.getRecommendations(
        lat: lat,
        lng: lng,
        vehicleType: _selectedVehicleType,
        radiusKm: 10.0, // Searching within 10 km
        limit: 5,
      );

    } catch (e) {
      _isLocationLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      _recommendations = [];
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
