import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/recommendation_result.dart';

class RecommendationRepository {
  final Dio _dio = Dio();

  String get _backendUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<List<RecommendationResult>> getRecommendations({
    required double lat,
    required double lng,
    required String vehicleType,
    double radiusKm = 5.0,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.post(
        '$_backendUrl/recommend',
        data: {
          'user_lat': lat,
          'user_lng': lng,
          'vehicle_type': vehicleType,
          'radius_km': radiusKm,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => RecommendationResult.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      throw Exception('Error communicating with recommendation service: $e');
    }
  }
}
