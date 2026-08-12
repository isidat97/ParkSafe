import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String tableNotifications = 'notifications';

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final data = await _client
          .from(tableNotifications)
          .select()
          .or('user_id.eq.$userId,user_id.eq.all')
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<NotificationModel?> createNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    try {
      final res = await _client
          .from(tableNotifications)
          .insert({
            'user_id': userId,
            'title': title,
            'body': body,
            'type': type,
            'is_read': false,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();

      return NotificationModel.fromJson(res);
    } catch (_) {
      return null;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client
          .from(tableNotifications)
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead(String userId) async {
    try {
      await _client
          .from(tableNotifications)
          .update({'is_read': true})
          .or('user_id.eq.$userId,user_id.eq.all');
      return true;
    } catch (_) {
      return false;
    }
  }
}
