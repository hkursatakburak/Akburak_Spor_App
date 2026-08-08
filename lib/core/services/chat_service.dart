import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../../features/chat/models/chat_models.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ChatMessage>> getMessages(String trainerId, String userId) async {
    try {
      final response = await _apiClient.get(
        '/api/messages/$trainerId',
        queryParameters: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List? ?? [];
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('ChatService getMessages network error: ${e.message}');
      return _getMockMessages(trainerId, userId);
    } catch (e) {
      debugPrint('ChatService getMessages unexpected error: $e');
      return _getMockMessages(trainerId, userId);
    }
  }

  Future<bool> sendMessage(ChatMessage message) async {
    try {
      final response = await _apiClient.post(
        '/api/messages/send',
        data: message.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('ChatService sendMessage network error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('ChatService sendMessage unexpected error: $e');
      return false;
    }
  }

  List<ChatMessage> _getMockMessages(String trainerId, String userId) {
    return [
      ChatMessage(senderId: trainerId, receiverId: userId, content: "Merhaba sporcu, antrenmanlar nasıl gidiyor? 🥊", timestamp: "2026-07-17T22:00:00Z", isRead: true),
      ChatMessage(senderId: userId, receiverId: trainerId, content: "Harika gidiyor hocam! Boks torbası serilerini yapıyorum.", timestamp: "2026-07-17T22:05:00Z", isRead: true),
      ChatMessage(senderId: trainerId, receiverId: userId, content: "Süper, gardını yüksek tutmayı unutma! Yarın kontrol edeceğim.", timestamp: "2026-07-17T22:06:00Z", isRead: true),
    ];
  }
}
