import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/feedback_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<AuthProvider>().profile;
      if (profile != null) {
        _nameCtrl.text = profile.fullName ?? '';
        _phoneCtrl.text = profile.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    if (auth.profile == null) return;

    final newName = _nameCtrl.text.trim();
    final newPhone = _phoneCtrl.text.trim();

    if (newName.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and mobile number cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updated = auth.profile!.copyWith(
      fullName: newName,
      phone: newPhone,
    );
    final success = await auth.updateProfile(updated);
    if (mounted) {
      setState(() {
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Profile information updated successfully!'
              : 'Failed to update profile details'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      if (_editing) {
                        _save();
                      } else {
                        setState(() => _editing = true);
                      }
                    },
                    icon: Icon(
                      _editing ? Icons.save_rounded : Icons.edit_rounded,
                      size: 18,
                    ),
                    label: Text(_editing ? 'Save' : 'Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (profile?.fullName?.isNotEmpty == true)
                            ? profile!.fullName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.bgDark, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                profile?.fullName ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                profile?.phone ?? '',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              // Profile fields
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline,
                      readOnly: !_editing,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Phone',
                      controller: _phoneCtrl,
                      prefixIcon: Icons.phone_outlined,
                      readOnly: !_editing,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Settings
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () => Navigator.pushNamed(context, '/notifications'),
                    ),
                    _SettingsTile(
                      icon: Icons.rate_review_outlined,
                      label: 'Customer Feedback',
                      onTap: () {
                        if (profile != null) {
                          showDialog(
                            context: context,
                            builder: (ctx) => CustomerFeedbackDialog(
                              userId: profile.id,
                            ),
                          );
                        }
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About ParkSafe v1.0',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sign out
              AppButton(
                label: 'Sign Out',
                isOutlined: true,
                color: AppColors.error,
                icon: Icons.logout_rounded,
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (r) => false);
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted, size: 20),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
