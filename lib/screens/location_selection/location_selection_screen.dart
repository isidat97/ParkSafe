import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/parking_location.dart';
import '../../providers/parking_provider.dart';
import '../home/home_screen.dart';


class LocationSelectionScreen extends StatefulWidget {
  final bool isChangingLocation;

  const LocationSelectionScreen({
    super.key,
    this.isChangingLocation = false,
  });

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParkingProvider>().loadLocations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectCity(String cityName) {
    context.read<ParkingProvider>().selectCity(cityName);
    if (widget.isChangingLocation && Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// Dynamically extracts unique City and State strictly from Database Locations
  List<Map<String, String>> _extractCitiesFromDatabase(
      List<ParkingLocation> locations) {
    final Map<String, String> cityToStateMap = {};

    for (var loc in locations) {
      final address = loc.address;
      final parts = address.split(',').map((e) => e.trim()).toList();

      String cityName = '';
      String stateName = 'India';

      if (parts.length >= 2) {
        // e.g. "LBS Marg, Ghatkopar West, Mumbai, MH 400086"
        final cityPart =
            parts[parts.length - 2].replaceAll(RegExp(r'\d+'), '').trim();
        final statePart = parts.last.replaceAll(RegExp(r'\d+'), '').trim();

        if (cityPart.isNotEmpty) {
          cityName = cityPart;
          stateName = _mapStateAbbreviation(statePart, loc.name);
        }
      }

      if (cityName.isEmpty && loc.name.isNotEmpty) {
        cityName = loc.name;
      }

      if (cityName.isNotEmpty) {
        cityToStateMap[cityName] = stateName;
      }
    }

    final List<Map<String, String>> result = [];
    cityToStateMap.forEach((city, state) {
      result.add({'name': city, 'state': state});
    });

    return result;
  }

  String _mapStateAbbreviation(String statePart, String locationName) {
    final s = statePart.toUpperCase();
    if (s.contains('MH') || s.contains('MAHARASHTRA')) return 'Maharashtra';
    if (s.contains('WB') || s.contains('BENGAL')) return 'West Bengal';
    if (s.contains('DL') || s.contains('DELHI')) return 'Delhi';
    if (s.contains('KA') || s.contains('KARNATAKA')) return 'Karnataka';
    if (s.contains('TN') || s.contains('TAMIL')) return 'Tamil Nadu';
    if (s.contains('GJ') || s.contains('GUJARAT')) return 'Gujarat';
    if (s.contains('TS') || s.contains('TG') || s.contains('TELANGANA')) return 'Telangana';
    if (s.contains('RJ') || s.contains('RAJASTHAN')) return 'Rajasthan';
    if (s.contains('UP') || s.contains('UTTAR')) return 'Uttar Pradesh';
    if (s.contains('KL') || s.contains('KERALA')) return 'Kerala';
    if (s.contains('MP') || s.contains('MADHYA')) return 'Madhya Pradesh';
    if (statePart.isNotEmpty) return statePart;
    return 'India';
  }

  @override
  Widget build(BuildContext context) {
    final parking = context.watch<ParkingProvider>();

    // Extract all cities strictly from Database locations
    final dbCities = _extractCitiesFromDatabase(parking.locations);

    // Only filter and show cities when user types in the search box (empty initially)
    final filteredCities = _filterQuery.trim().isEmpty
        ? <Map<String, String>>[]
        : dbCities.where((c) {
            final name = c['name']!.toLowerCase();
            final state = c['state']!.toLowerCase();
            final q = _filterQuery.trim().toLowerCase();
            return name.contains(q) || state.contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Underlying Home Page rendered in background when initial launch
          if (!widget.isChangingLocation)
            const IgnorePointer(
              child: HomeScreen(),
            ),

          // Subtle White Glass Overlay Filter (18% White Overlay, 82% Home Visibility)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.white.withOpacity(0.18), // 18% white opacity for maximum background visibility
              ),
            ),
          ),




          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: "Select The City" Title at top-left
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF0F172A),
                            size: 18,
                          ),
                        ),
                      ),
                      const Text(
                        'Select The City',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // White Search Box with Search Icon and Placeholder "Search City"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _filterQuery = v),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      autofocus: widget.isChangingLocation,
                      decoration: InputDecoration(
                        hintText: 'Search City',
                        hintStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF1B4D3E),
                            size: 22,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 46, minHeight: 46),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() => _filterQuery = '');
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Dynamic Character-by-Character Database Search Results (Shown only when typing)
                if (_filterQuery.trim().isNotEmpty)
                  Expanded(
                    child: filteredCities.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                'No cities found',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            itemCount: filteredCities.length,
                            itemBuilder: (ctx, index) {
                              final city = filteredCities[index];

                              return GestureDetector(
                                onTap: () => _selectCity(city['name']!),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF1B4D3E),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          '${city['name']}, ${city['state']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




