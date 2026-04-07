import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/models/notification.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<TumeNotification> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<TumeNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  final ApiService _api = ApiService();

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Load from API
    await Future.delayed(const Duration(seconds: 1));

    _notifications = [
      TumeNotification(
        id: 1,
        title: 'Welcome to Tume Ride!',
        message: 'Thank you for joining. Enjoy your first ride!',
        type: 'system',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _unreadCount = _notifications.where((n) => !n.isRead).length;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = TumeNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        data: _notifications[index].data,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
      _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = TumeNotification(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          data: _notifications[i].data,
          isRead: true,
          createdAt: _notifications[i].createdAt,
        );
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification(TumeNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }
}