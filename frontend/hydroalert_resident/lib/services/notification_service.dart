import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _api.get('/notifications/');
    return (response.data as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<void> markAsRead(String notificationID) async {
    await _api.patch('/notifications/$notificationID/read');
  }

  Future<void> markAllAsRead() async {
    await _api.patch('/notifications/read-all');
  }
}