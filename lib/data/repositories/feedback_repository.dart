import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../models/feedback_model.dart';

class FeedbackRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String tableFeedback = 'feedback';

  Future<bool> submitFeedback({
    required String userId,
    String? bookingId,
    String? locationId,
    required int rating,
    String? comments,
  }) async {
    try {
      await _client.from(tableFeedback).insert({
        'user_id': userId,
        if (bookingId != null) 'booking_id': bookingId,
        if (locationId != null) 'location_id': locationId,
        'rating': rating,
        if (comments != null && comments.trim().isNotEmpty)
          'comments': comments.trim(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<FeedbackModel>> getAllFeedback() async {
    try {
      final data = await _client
          .from(tableFeedback)
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
