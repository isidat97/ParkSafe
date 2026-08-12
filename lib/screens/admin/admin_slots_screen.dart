import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../data/models/parking_location.dart';
import '../../providers/admin_provider.dart';
import '../../providers/parking_provider.dart';
import 'admin_add_location_screen.dart';

class AdminSlotsScreen extends StatefulWidget {
  const AdminSlotsScreen({super.key});

  @override
  State<AdminSlotsScreen> createState() => _AdminSlotsScreenState();
}

class _AdminSlotsScreenState extends State<AdminSlotsScreen> {
  String? _selectedLocationId;

  void _showEditMapsLinkDialog(BuildContext context, ParkingLocation loc) {
    final linkCtrl = TextEditingController(text: loc.googleMapsLink ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.map_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Google Maps Link',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.address,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter or paste Google Maps URL (e.g. for VR Mall, Surat):',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: linkCtrl,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'https://maps.google.com/?q=VR+Mall,+Surat',
                filled: true,
                fillColor: AppColors.bgDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newLink = linkCtrl.text.trim();
              Navigator.pop(ctx);
              final success = await context.read<AdminProvider>().updateGoogleMapsLink(
                    locationId: loc.id,
                    googleMapsLink: newLink,
                  );
              if (context.mounted) {
                context.read<ParkingProvider>().loadLocations();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Google Maps link updated successfully!' : 'Failed to update link'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Link'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (ctx, admin, _) {
            final locs = admin.locations;
            final allSlots = admin.slotsWithLocation;

            final filteredSlots = allSlots.where((s) {
              if (_selectedLocationId == null) return true;
              return s['location_id'] == _selectedLocationId;
            }).toList();

            final selectedLocObj = _selectedLocationId == null
                ? null
                : locs.cast<ParkingLocation?>().firstWhere(
                    (l) => l?.id == _selectedLocationId,
                    orElse: () => null,
                  );

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Parking Slots',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              )),
                          Text('All parking slots by location',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminAddLocationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_location_alt_rounded,
                            size: 16),
                        label: const Text('Add Place',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Location Filter Tabs
                if (locs.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Locations'),
                          selected: _selectedLocationId == null,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.bgCard,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedLocationId == null
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: _selectedLocationId == null
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(
                              color: _selectedLocationId == null
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedLocationId = null),
                        ),
                        const SizedBox(width: 8),
                        ...locs.map((loc) {
                          final selected = _selectedLocationId == loc.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(loc.name),
                              selected: selected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.bgCard,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedLocationId = loc.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                // Location Google Maps link banner if selected
                if (selectedLocObj != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLocObj.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                (selectedLocObj.googleMapsLink != null && selectedLocObj.googleMapsLink!.isNotEmpty)
                                    ? 'Google Maps Link Set 📍'
                                    : 'No Google Maps link configured',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (selectedLocObj.googleMapsLink != null && selectedLocObj.googleMapsLink!.isNotEmpty)
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showEditMapsLinkDialog(context, selectedLocObj),
                          icon: const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Edit Maps Link',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Slot Grid
                Expanded(
                  child: admin.isLoading && allSlots.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : filteredSlots.isEmpty
                          ? const Center(
                              child: Text('No parking slots found',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14)),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: filteredSlots.length,
                              itemBuilder: (ctx, i) {
                                final slot = filteredSlots[i];
                                final numStr =
                                    slot['slot_number'] as String? ?? '-';
                                final type =
                                    slot['slot_type'] as String? ?? 'car';
                                final isActive =
                                    slot['is_active'] as bool? ?? true;
                                final locMap = slot['parking_locations']
                                    as Map<String, dynamic>?;
                                final locName =
                                    locMap?['name'] as String? ?? '';

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.primary.withOpacity(0.3)
                                          : AppColors.border,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x0F14181B),
                                          blurRadius: 4,
                                          offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            type == 'bike'
                                                ? Icons.two_wheeler_rounded
                                                : type == 'ev'
                                                    ? Icons.electric_car_rounded
                                                    : Icons
                                                        .directions_car_rounded,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            numStr,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgSurface2,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          AppHelpers.getSlotTypeLabel(type),
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      if (locName.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          locName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 9),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
