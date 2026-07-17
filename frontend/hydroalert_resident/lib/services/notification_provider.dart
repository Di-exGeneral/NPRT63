import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _service.getNotifications();
    } catch (e) {
      _error = 'Failed to load notifications';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationID) async {
    try {
      await _service.markAsRead(notificationID);
      final index = _notifications.indexWhere((n) => n.id == notificationID);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userID: _notifications[index].userID,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to mark as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        userID: n.userID,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to mark all as read: $e');
    }
  }
}