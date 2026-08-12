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


  Future<bool> signInAdmin() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final adminProfile = UserProfile(
      id: 'admin-001',
      phone: '9999988888',
      fullName: 'ParkSafe Admin',
      role: 'admin',
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
      final existingUser = await _repo.getUserByPhone(cleanPhone);

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
