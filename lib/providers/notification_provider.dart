import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import '../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repo.getNotifications(userId);
    } catch (_) {
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    final notification = await _repo.createNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
    );

    if (notification != null) {
      _notifications.insert(0, notification);
      notifyListeners();
    }

    // Trigger local push banner
    await _service.showNotification(
      title: title,
      body: body,
    );
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
      await _repo.markAsRead(id);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _repo.markAllAsRead(userId);
  }
}
