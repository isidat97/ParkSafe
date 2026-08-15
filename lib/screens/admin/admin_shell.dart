import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_scan_screen.dart';
import 'admin_todays_bookings_screen.dart';
import 'admin_all_bookings_screen.dart';
import 'admin_vehicles_screen.dart';
import 'admin_slots_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_revenue_screen.dart';
import 'admin_add_location_screen.dart';
import 'admin_refunds_screen.dart';


class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan QR'),
    _NavItem(icon: Icons.today_rounded, label: "Today's"),
    _NavItem(icon: Icons.list_alt_rounded, label: 'Bookings'),
    _NavItem(icon: Icons.directions_car_rounded, label: 'Vehicles'),
    _NavItem(icon: Icons.local_parking_rounded, label: 'Slots'),
    _NavItem(icon: Icons.add_location_alt_rounded, label: 'Add Place'),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Customers'),
    _NavItem(icon: Icons.currency_rupee_rounded, label: 'Refunds'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Revenue'),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboardScreen(),
      const AdminScanScreen(),
      const AdminTodaysBookingsScreen(),
      const AdminAllBookingsScreen(),
      const AdminVehiclesScreen(),
      const AdminSlotsScreen(),
      const AdminAddLocationScreen(),
      const AdminCustomersScreen(),
      const AdminRefundsScreen(),
      const AdminRevenueScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProfile = context.read<AuthProvider>().profile;
      final adminProv = context.read<AdminProvider>();
      adminProv.setAdminContext(authProfile);
      adminProv.loadDashboardStats();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out of the admin panel?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Logout',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          // Sidebar (on large screens) / hidden on small
          if (MediaQuery.of(context).size.width >= 600) _buildSidebar(),

          // Main content
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
      // Bottom nav on small screens
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? _buildBottomNav()
          : null,
    );
  }

  Widget _buildSidebar() {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) => Container(
        width: 200,
        color: AppColors.bgCard,
        child: Column(
          children: [
            // Admin header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          admin.adminProfile?.fullName ?? 'Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 10, color: AppColors.accent),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                admin.assignedLocationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          ..._navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final selected = _selectedIndex == i;
            return _SidebarTile(
              icon: item.icon,
              label: item.label,
              selected: selected,
              onTap: () => setState(() => _selectedIndex = i),
            );
          }),
          const Spacer(),
          const Divider(height: 1, color: AppColors.border),
          _SidebarTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            selected: false,
            onTap: _logout,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ));
  }

  Widget _buildBottomNav() {
    // Show only first 5 items in bottom nav; rest accessible via overflow
    final visibleItems = _navItems.sublist(0, 5);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              ...visibleItems.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final selected = _selectedIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // More button
              Expanded(
                child: InkWell(
                  onTap: () => _showMoreMenu(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.more_horiz_rounded,
                        color: _selectedIndex >= 5
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'More',
                        style: TextStyle(
                          color: _selectedIndex >= 5
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ..._navItems.sublist(5).asMap().entries.map((entry) {
                final i = entry.key + 5;
                final item = entry.value;
                return ListTile(
                  leading: Icon(item.icon, color: AppColors.primary),
                  title: Text(item.label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedIndex = i);
                  },
                );
              }),
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text('Logout',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (selected ? AppColors.primary : AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: c, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: c,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
