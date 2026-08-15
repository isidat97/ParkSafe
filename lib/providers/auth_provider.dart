import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_profile.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  UserProfile? _profile;
  String? _errorMessage;

  bool _isInitialized = false;

  AuthStatus get status => _status;
  UserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _profile != null;
  bool get isInitialized => _isInitialized;

  bool get isAdmin => _profile?.role == 'admin' || _profile?.role == 'super_admin';
  bool get isSuperAdmin =>
      _profile?.role == 'super_admin' ||
      (_profile?.role == 'admin' &&
          (_profile?.assignedLocationId == null ||
              _profile?.assignedLocationId == 'ALL' ||
              _profile?.assignedLocationId == ''));
  String? get assignedLocationId => _profile?.assignedLocationId;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('saved_user_profile');
      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(savedUserJson);
        _profile = UserProfile.fromJson(map);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }


  Future<bool> signUp({
    required String phone,
    required String password,
    required String fullName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanPhone = phone.trim();
      final cleanPassword = password.trim();

      // Check if customer already exists in database
      final existingUser = await _repo.getUserByPhone(cleanPhone);
      if (existingUser != null) {
        // Reuse existing customer account & Customer ID if password matches or empty
        if (existingUser.password == null ||
            existingUser.password!.isEmpty ||
            existingUser.password == cleanPassword) {
          _profile = existingUser;
          _status = AuthStatus.authenticated;
          await _saveProfileToPrefs(existingUser);
          notifyListeners();
          return true;
        } else {
          _status = AuthStatus.error;
          _errorMessage =
              'An account with this mobile number already exists. Please sign in with your password.';
          notifyListeners();
          _autoDismissError();
          return false;
        }
      }

      // Customer genuinely does not exist -> Create new account
      final createdProfile = await _repo.customSignUp(
        phone: cleanPhone,
        password: cleanPassword,
        fullName: fullName,
      );

      _profile = createdProfile;
      _status = AuthStatus.authenticated;
      await _saveProfileToPrefs(createdProfile);
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      final errStr = e.toString();
      if (errStr.contains('row-level security') ||
          errStr.contains('42501') ||
          errStr.contains('PGRST301')) {
        _errorMessage =
            'Database RLS Blocking: Please run the updated SQL script in Supabase SQL Editor.';
      } else {
        _errorMessage = 'Failed to create account: $errStr';
      }
      notifyListeners();
      _autoDismissError();
      return false;
    }
  }


  Future<bool> signInAdmin({
    String phone = '9999988888',
    String? assignedLocationId,
    String? fullName,
    String? role,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final dbUser = await _repo.getUserByPhone(phone.trim());
      if (dbUser != null && (dbUser.role == 'admin' || dbUser.role == 'super_admin')) {
        _profile = dbUser;
        _status = AuthStatus.authenticated;
        await _saveProfileToPrefs(dbUser);
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Fallback to default admin profile configuration if DB fails or offline
    String adminRole = role ?? (phone == '9999988888' ? 'super_admin' : 'admin');
    String adminName = fullName ?? 'ParkSafe Admin';
    String? locId = assignedLocationId;

    if (locId == null) {
      if (phone == '9999911111') {
        locId = 'b0000000-0000-0000-0000-000000000034'; // Surat VR Mall
        adminName = 'Surat VR Mall Admin';
      } else if (phone == '9999922222') {
        locId = 'b0000000-0000-0000-0000-000000000009'; // Mumbai Airport
        adminName = 'Mumbai Airport Admin';
      } else if (phone == '9999933333') {
        locId = 'b0000000-0000-0000-0000-000000000051'; // Surat RR Mall
        adminName = 'Surat RR Mall Admin';
      } else if (phone == '9999988888') {
        adminName = 'Main Admin (All Locations)';
      }
    }

    final adminProfile = UserProfile(
      id: 'admin-$phone',
      phone: phone,
      fullName: adminName,
      role: adminRole,
      assignedLocationId: locId,
    );
    _profile = adminProfile;
    _status = AuthStatus.authenticated;
    await _saveProfileToPrefs(adminProfile);
    notifyListeners();
    return true;
  }

  Future<bool> signIn({
    required String phone,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanPhone = phone.trim();
      UserProfile? existingUser = await _repo.getAdminAccountByPhone(cleanPhone);
      existingUser ??= await _repo.getUserByPhone(cleanPhone);

      // Check 1: Account does not exist
      if (existingUser == null) {
        _status = AuthStatus.error;
        _errorMessage = 'An account with this mobile number does not exist. Please sign up first.';
        notifyListeners();
        _autoDismissError();
        return false;
      }

      // Check 2: Password verification
      if (existingUser.password != null && existingUser.password != password.trim()) {
        _status = AuthStatus.error;
        _errorMessage = 'Incorrect 6-digit password. Please try again.';
        notifyListeners();
        _autoDismissError();
        return false;
      }

      _profile = existingUser;
      _status = AuthStatus.authenticated;
      await _saveProfileToPrefs(existingUser);
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      _autoDismissError();
      return false;
    }
  }

  void _autoDismissError() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_status == AuthStatus.error) {
        _errorMessage = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _saveProfileToPrefs(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user_profile', jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_user_profile');
    } catch (_) {}
    _status = AuthStatus.unauthenticated;
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }



  Future<bool> updateProfile(UserProfile updated) async {
    try {
      await _repo.updateProfile(updated);
      
      // Reload profile from DB to ensure it reflects exact saved state
      final freshProfile = await _repo.getProfile(updated.id);
      if (freshProfile != null) {
        _profile = freshProfile;
        await _saveProfileToPrefs(freshProfile);
      } else {
        _profile = updated;
        await _saveProfileToPrefs(updated);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
