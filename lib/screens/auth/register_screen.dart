import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.signUp(
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/location-select');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create\nAccount ✨',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up with your mobile number to get started',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  AppTextField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Full name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
                  AppTextField(
                    label: 'Mobile Number',
                    hint: '9876543210',
                    controller: _phoneCtrl,
                    prefixIcon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                      if (v.trim().length != 10) return 'Enter a valid 10-digit mobile number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 6-Digit Password
                  AppTextField(
                    label: '6-Digit Password',
                    hint: 'Enter 6-digit password',
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePass,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Password is required';
                      if (v.trim().length < 6) return 'Must be 6 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  AppTextField(
                    label: 'Confirm 6-Digit Password',
                    hint: 'Repeat 6-digit password',
                    controller: _confirmCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirm,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Confirm password';
                      if (v.trim() != _passCtrl.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error Container
                  Consumer<AuthProvider>(
                    builder: (ctx, auth, _) {
                      if (auth.errorMessage != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Submit Button
                  Consumer<AuthProvider>(
                    builder: (ctx, auth, _) => AppButton(
                      label: 'Create Account',
                      isLoading: auth.status == AuthStatus.loading,
                      onTap: _register,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
