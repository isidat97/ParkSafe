import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/user_profile.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<UserProfile?> getUserByPhone(String phone) async {
    try {
      final cleanPhone = phone.trim();
      final List res = await _client
          .from(AppConstants.tableProfiles)
          .select()
          .eq('phone', cleanPhone)
          .limit(1);
      if (res.isNotEmpty) {
        return UserProfile.fromJson(res.first as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }



  Future<UserProfile> customSignUp({
    required String phone,
    required String password,
    required String fullName,
  }) async {
    final cleanPhone = phone.trim();

    final data = {
      'phone': cleanPhone,
      'password': password.trim(),
      'full_name': fullName.trim(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    final res = await _client
        .from(AppConstants.tableProfiles)
        .insert(data)
        .select()
        .single();

    return UserProfile.fromJson(res);
  }

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _client
        .from(AppConstants.tableProfiles)
        .update({
          'full_name': profile.fullName,
          'phone': profile.phone,
          if (profile.fcmToken != null) 'fcm_token': profile.fcmToken,
        })
        .eq('id', profile.id);
  }

  Future<void> saveFcmToken(String token) async {
    final user = currentUser;
    if (user != null) {
      await _client
          .from(AppConstants.tableProfiles)
          .update({'fcm_token': token})
          .eq('id', user.id);
    }
  }

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
