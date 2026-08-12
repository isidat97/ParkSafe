import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/parking_provider.dart';
import '../../data/models/recommendation_result.dart';
import '../location_detail/location_detail_screen.dart';
import '../../widgets/common_widgets.dart';

class NearestAvailableSlotsScreen extends StatefulWidget {
  const NearestAvailableSlotsScreen({super.key});

  @override
  State<NearestAvailableSlotsScreen> createState() => _NearestAvailableSlotsScreenState();
}

class _NearestAvailableSlotsScreenState extends State<NearestAvailableSlotsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearest Available Parking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _VehicleTypeSelector(),
          Expanded(
            child: Consumer<RecommendationProvider>(
              builder: (ctx, provider, _) {
                if (provider.isLocationLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Getting your current location...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.isLoading) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: 4,
                    itemBuilder: (ctx, i) => const _RecommendationCardSkeleton(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => provider.fetchRecommendations(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Try Again',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.recommendations.isEmpty) {
                  return const EmptyState(
                    icon: Icons.location_off_rounded,
                    title: 'No Available Parking Nearby',
                    subtitle: 'We couldn\'t find an available parking location within 10 km. Try expanding your search area.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: provider.recommendations.length,
                  itemBuilder: (ctx, i) {
                    final rec = provider.recommendations[i];
                    return _RecommendationCard(result: rec);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _VehicleButton(
            icon: Icons.directions_car_rounded,
            label: 'Car',
            isSelected: provider.selectedVehicleType == 'car',
            onTap: () => provider.setVehicleType('car'),
          ),
          _VehicleButton(
            icon: Icons.two_wheeler_rounded,
            label: 'Bike',
            isSelected: provider.selectedVehicleType == 'bike',
            onTap: () => provider.setVehicleType('bike'),
          ),
          _VehicleButton(
            icon: Icons.electric_car_rounded,
            label: 'EV',
            isSelected: provider.selectedVehicleType == 'ev',
            onTap: () => provider.setVehicleType('ev'),
          ),
        ],
      ),
    );
  }
}

class _VehicleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;
    final bgColor = isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.bgSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationResult result;

  const _RecommendationCard({required this.result});

  Color _getAvailabilityColor(int percentage) {
    if (percentage == 0) return AppColors.error; // Full
    if (percentage < 20) return AppColors.error; // Low
    if (percentage < 50) return AppColors.warning; // Moderate
    return AppColors.success; // High
  }

  String _getAvailabilityText(int percentage) {
    if (percentage == 0) return 'Full';
    if (percentage < 20) return 'Low Availability';
    if (percentage < 50) return 'Moderate Availability';
    return 'High Availability';
  }

  Future<void> _openMaps() async {
    if (result.googleMapsLink != null && result.googleMapsLink!.isNotEmpty) {
      final uri = Uri.parse(result.googleMapsLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availColor = _getAvailabilityColor(result.availabilityPercentage);
    final isFull = result.availabilityPercentage == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0F14181B), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  result.address,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '₹${result.pricePerHour.toStringAsFixed(0)}/hr',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  children: [
                    _StatItem(icon: Icons.route_rounded, text: '${result.distanceKm} km'),
                    const SizedBox(width: 12),
                    _StatItem(icon: Icons.timer_outlined, text: '${result.etaMinutes} min'),
                    const SizedBox(width: 12),
                    _StatItem(
                        icon: Icons.local_parking_rounded,
                        text: '${result.freeSlots}/${result.totalSlots} slots'),
                  ],
                ),
                
                const SizedBox(height: 16),

                // Availability Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: availColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: availColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: availColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${result.availabilityPercentage}% - ${_getAvailabilityText(result.availabilityPercentage)}',
                        style: TextStyle(
                          color: availColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Optional Score Explanation
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recommended: ${result.distanceKm} km away and has ${result.availabilityPercentage}% availability.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons Bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (result.googleMapsLink != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: const Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (result.googleMapsLink != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isFull
                        ? null
                        : () {
                            // Find the full ParkingLocation object from ParkingProvider
                            final parkingProvider = context.read<ParkingProvider>();
                            // Ensure locations are loaded, maybe try to match by ID
                            final loc = parkingProvider.locations.firstWhere(
                              (l) => l.id == result.locationId,
                              orElse: () => throw Exception('Location not found in local cache'),
                            );
                            
                            parkingProvider.selectLocation(loc);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LocationDetailScreen(location: loc),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFull ? AppColors.border : AppColors.primary,
                      foregroundColor: isFull ? AppColors.textMuted : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(isFull ? 'Fully Booked' : 'View Parking',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecommendationCardSkeleton extends StatelessWidget {
  const _RecommendationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}
