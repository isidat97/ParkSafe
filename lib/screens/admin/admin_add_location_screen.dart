import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/floor_config.dart';
import '../../providers/admin_provider.dart';
import '../../providers/parking_provider.dart';

class AdminAddLocationScreen extends StatefulWidget {
  const AdminAddLocationScreen({super.key});

  @override
  State<AdminAddLocationScreen> createState() => _AdminAddLocationScreenState();
}

class _AdminAddLocationScreenState extends State<AdminAddLocationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _totalSlotsCtrl = TextEditingController(text: '20');
  final _carSlotsCtrl = TextEditingController(text: '12');
  final _bikeSlotsCtrl = TextEditingController(text: '5');
  final _evSlotsCtrl = TextEditingController(text: '3');
  final _imageCtrl = TextEditingController();
  final _gmapsLinkCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();

  // Multi-floor setup state
  bool _hasMultipleFloors = false;
  final _numFloorsCtrl = TextEditingController(text: '3');
  final List<TextEditingController> _floorNameCtrls = [];
  final List<TextEditingController> _floorTotalCtrls = [];
  final List<TextEditingController> _floorCarCtrls = [];
  final List<TextEditingController> _floorBikeCtrls = [];
  final List<TextEditingController> _floorEvCtrls = [];

  final List<String> _allAmenities = [
    '24/7 CCTV Surveillance',
    'EV Charging',
    'Car Wash',
    'Security Guard',
    '24/7 Access',
    'Covered Parking',
    'Valet Parking',
    'Free WiFi',
    'FASTag'
  ];
  final Set<String> _selectedAmenities = {
    '24/7 CCTV Surveillance',
    'EV Charging',
    'Car Wash',
    'Security Guard',
  };

  @override
  void initState() {
    super.initState();
    _updateFloorControllers(3);
  }

  void _updateFloorControllers(int count) {
    if (count < 1) count = 1;
    if (count > 10) count = 10;

    while (_floorNameCtrls.length < count) {
      final index = _floorNameCtrls.length + 1;
      _floorNameCtrls.add(TextEditingController(text: 'Floor $index'));
      _floorTotalCtrls.add(TextEditingController(text: '20'));
      _floorCarCtrls.add(TextEditingController(text: '10'));
      _floorBikeCtrls.add(TextEditingController(text: '5'));
      _floorEvCtrls.add(TextEditingController(text: '5'));
    }
    while (_floorNameCtrls.length > count) {
      _floorNameCtrls.removeLast().dispose();
      _floorTotalCtrls.removeLast().dispose();
      _floorCarCtrls.removeLast().dispose();
      _floorBikeCtrls.removeLast().dispose();
      _floorEvCtrls.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _totalSlotsCtrl.dispose();
    _carSlotsCtrl.dispose();
    _bikeSlotsCtrl.dispose();
    _evSlotsCtrl.dispose();
    _imageCtrl.dispose();
    _gmapsLinkCtrl.dispose();
    _floorCtrl.dispose();
    _numFloorsCtrl.dispose();
    for (var c in _floorNameCtrls) {
      c.dispose();
    }
    for (var c in _floorTotalCtrls) {
      c.dispose();
    }
    for (var c in _floorCarCtrls) {
      c.dispose();
    }
    for (var c in _floorBikeCtrls) {
      c.dispose();
    }
    for (var c in _floorEvCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final imageUrl = _imageCtrl.text.trim();
    final googleMapsLink = _gmapsLinkCtrl.text.trim();

    List<FloorConfig>? floorConfigs;
    int totalSlots = 0;
    int carSlots = 0;
    int bikeSlots = 0;
    int evSlots = 0;

    if (_hasMultipleFloors) {
      floorConfigs = [];
      for (int i = 0; i < _floorNameCtrls.length; i++) {
        final flName = _floorNameCtrls[i].text.trim().isNotEmpty
            ? _floorNameCtrls[i].text.trim()
            : 'Floor ${i + 1}';
        final flTotal = int.tryParse(_floorTotalCtrls[i].text.trim()) ?? 0;
        final flCar = int.tryParse(_floorCarCtrls[i].text.trim()) ?? 0;
        final flBike = int.tryParse(_floorBikeCtrls[i].text.trim()) ?? 0;
        final flEv = int.tryParse(_floorEvCtrls[i].text.trim()) ?? 0;

        final sum = flCar + flBike + flEv;
        if (sum != flTotal) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Validation Error for "$flName": Car ($flCar) + Bike ($flBike) + EV ($flEv) = $sum slots, but Total Slots is set to $flTotal.',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        floorConfigs.add(FloorConfig(
          floorName: flName,
          carSlots: flCar,
          bikeSlots: flBike,
          evSlots: flEv,
        ));
      }

      totalSlots = floorConfigs.fold<int>(0, (sum, f) => sum + f.totalSlots);
    } else {
      totalSlots = int.tryParse(_totalSlotsCtrl.text.trim()) ?? 10;
      carSlots = int.tryParse(_carSlotsCtrl.text.trim()) ?? 0;
      bikeSlots = int.tryParse(_bikeSlotsCtrl.text.trim()) ?? 0;
      evSlots = int.tryParse(_evSlotsCtrl.text.trim()) ?? 0;
    }

    final admin = context.read<AdminProvider>();
    final success = await admin.addParkingLocation(
      name: name,
      address: address,
      pricePerHour: price,
      totalSlots: totalSlots,
      amenities: _selectedAmenities.toList(),
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      googleMapsLink: googleMapsLink.isNotEmpty ? googleMapsLink : null,
      floor: _floorCtrl.text.trim().isNotEmpty ? _floorCtrl.text.trim() : null,
      carSlots: carSlots,
      bikeSlots: bikeSlots,
      evSlots: evSlots,
      floorConfigs: floorConfigs,
    );

    if (!mounted) return;

    if (success) {
      context.read<ParkingProvider>().loadLocations();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "$name" with $totalSlots slots successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      final errStr = admin.error ?? 'Failed to add location';
      if (errStr.contains('row-level security') ||
          errStr.contains('PGRST301') ||
          errStr.contains('42501')) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Database RLS Notice',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ],
            ),
            content: const Text(
              'Supabase Row Level Security (RLS) is blocking location inserts.\n\nPlease run the updated `supabase_migration.sql` in Supabase SQL Editor to allow location inserts.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errStr),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Parking Place',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_location_alt_rounded,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Create a new parking location. Parking slots will be generated automatically in the database.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section 1: Basic Info
                _buildSectionHeader('Basic Information', Icons.info_outline),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _nameCtrl,
                  label: 'Parking Place Name *',
                  hint: 'e.g. Metro Mall Parking Garage',
                  icon: Icons.local_parking_rounded,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _addressCtrl,
                  label: 'Address / Location *',
                  hint: 'e.g. Block 4, Tech Park Road, Sector 18',
                  icon: Icons.location_on_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Address is required'
                      : null,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _priceCtrl,
                  label: 'Price Per Hour (₹) *',
                  hint: 'e.g. 50',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Price is required';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _imageCtrl,
                  label: 'Cover Image URL (Optional)',
                  hint: 'https://images.unsplash.com/...',
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _gmapsLinkCtrl,
                  label: 'Google Maps Location Link',
                  hint: 'e.g. https://maps.google.com/?q=VR+Mall,+Surat',
                  icon: Icons.map_outlined,
                ),

                const SizedBox(height: 24),

                // Multi-Floor Toggle Section
                _buildSectionHeader('Floor & Capacity Setup', Icons.layers_rounded),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.domain_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Does this location have multiple floors?',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Enable to configure floor-wise slot distribution',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _hasMultipleFloors,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _hasMultipleFloors = val;
                            if (val && _floorNameCtrls.isEmpty) {
                              _updateFloorControllers(
                                  int.tryParse(_numFloorsCtrl.text.trim()) ?? 3);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (!_hasMultipleFloors) ...[
                  // Section 2: Single-Floor Capacity
                  _buildTextField(
                    controller: _floorCtrl,
                    label: 'Floor Level (Optional)',
                    hint: 'e.g. Ground Floor, Basement 1',
                    icon: Icons.layers_rounded,
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _totalSlotsCtrl,
                    label: 'Total Capacity (Total Slots) *',
                    hint: '20',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Must be greater than 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _carSlotsCtrl,
                          label: 'Car Slots',
                          hint: '12',
                          icon: Icons.directions_car_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _bikeSlotsCtrl,
                          label: 'Bike Slots',
                          hint: '5',
                          icon: Icons.two_wheeler_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _evSlotsCtrl,
                          label: 'EV Slots',
                          hint: '3',
                          icon: Icons.electric_car_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Multi-Floor Configuration Block
                  _buildTextField(
                    controller: _numFloorsCtrl,
                    label: 'Number of Floors *',
                    hint: '3',
                    icon: Icons.format_list_numbered_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Min 1 floor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final n = int.tryParse(_numFloorsCtrl.text.trim()) ?? 1;
                        setState(() => _updateFloorControllers(n));
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Generate Floor Forms'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _floorNameCtrls.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, index) {
                      final nameCtrl = _floorNameCtrls[index];
                      final totalCtrl = _floorTotalCtrls[index];
                      final carCtrl = _floorCarCtrls[index];
                      final bikeCtrl = _floorBikeCtrls[index];
                      final evCtrl = _floorEvCtrls[index];

                      final cVal = int.tryParse(carCtrl.text.trim()) ?? 0;
                      final bVal = int.tryParse(bikeCtrl.text.trim()) ?? 0;
                      final eVal = int.tryParse(evCtrl.text.trim()) ?? 0;
                      final sum = cVal + bVal + eVal;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.2),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: nameCtrl,
                                    label: 'Floor Name',
                                    hint: 'Floor ${index + 1}',
                                    icon: Icons.layers_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: totalCtrl,
                                    label: 'Total Slots',
                                    hint: '20',
                                    icon: Icons.grid_view_rounded,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final val = int.tryParse(v ?? '');
                                      if (val == null || val <= 0) {
                                        return 'Req';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Vehicle Slot Allocation',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: carCtrl,
                                    label: 'Car',
                                    hint: '10',
                                    icon: Icons.directions_car_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: bikeCtrl,
                                    label: 'Bike',
                                    hint: '5',
                                    icon: Icons.two_wheeler_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: evCtrl,
                                    label: 'EV',
                                    hint: '5',
                                    icon: Icons.electric_car_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$cVal Car + $eVal EV + $bVal Bike',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Total: $sum slots',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: sum ==
                                              (int.tryParse(totalCtrl.text.trim()) ?? 0)
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Section 3: Amenities
                _buildSectionHeader('Amenities & Features', Icons.star_outline),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allAmenities.map((amenity) {
                    final selected = _selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.bgCard,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Submit Button
                Consumer<AdminProvider>(
                  builder: (_, admin, __) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: admin.isLoading ? null : _submit,
                      icon: admin.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_circle_outline_rounded,
                              size: 20),
                      label: Text(
                        admin.isLoading ? 'Creating...' : 'Save Parking Place',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.bgCard,
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
