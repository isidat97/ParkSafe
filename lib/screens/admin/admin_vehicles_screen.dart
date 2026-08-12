import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';

class AdminVehiclesScreen extends StatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  State<AdminVehiclesScreen> createState() => _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends State<AdminVehiclesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (ctx, admin, _) {
            final vehicles = admin.vehicles;
            final filtered = vehicles.where((v) {
              final q = _searchQuery.toLowerCase();
              final vn = (v['vehicle_number'] as String? ?? '').toLowerCase();
              return q.isEmpty || vn.contains(q);
            }).toList();

            return Column(
              children: [
                // Header & Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Vehicles',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              )),
                          const Spacer(),
                          Text('${vehicles.length} unique vehicles',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search by vehicle number...',
                          hintStyle: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: AppColors.bgCard,
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textMuted, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle List
                Expanded(
                  child: admin.isLoading && vehicles.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : filtered.isEmpty
                          ? const Center(
                              child: Text('No vehicles found',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final item = filtered[i];
                                final vn =
                                    item['vehicle_number'] as String? ?? 'N/A';
                                final count = item['visit_count'] as int? ?? 1;
                                final last =
                                    item['last_visit'] as String? ?? '-';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x0F14181B),
                                          blurRadius: 6,
                                          offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.accent
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                            Icons.directions_car_rounded,
                                            color: AppColors.accent,
                                            size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vn,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Last park: $last',
                                              style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '$count visit${count > 1 ? 's' : ''}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
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
