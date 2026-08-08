import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../../features/social/models/leaderboard_models.dart';

class SocialService {
  final ApiClient _apiClient = ApiClient();

  Future<List<LeaderboardUser>> getLeaderboard() async {
    try {
      final response = await _apiClient.get('/api/leaderboard');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List? ?? [];
        return data.map((json) => LeaderboardUser.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('SocialService getLeaderboard network error: ${e.message}');
      return _getMockLeaderboard();
    } catch (e) {
      debugPrint('SocialService getLeaderboard unexpected error: $e');
      return _getMockLeaderboard();
    }
  }

  List<LeaderboardUser> _getMockLeaderboard() {
    return [
      LeaderboardUser(name: "Hamza Kürşat Akburak", email: "hamza@akburak.com", totalPoints: 2450, rank: "Kara Kuşak", longestStreak: 15),
      LeaderboardUser(name: "Ali Demir", email: "ali@akburak.com", totalPoints: 2100, rank: "Kahverengi Kuşak", longestStreak: 12),
      LeaderboardUser(name: "Ayşe Kaya", email: "ayse@akburak.com", totalPoints: 1950, rank: "Mavi Kuşak", longestStreak: 9),
      LeaderboardUser(name: "Can Yılmaz", email: "can@akburak.com", totalPoints: 1700, rank: "Mavi Kuşak", longestStreak: 4),
      LeaderboardUser(name: "Deniz Yıldız", email: "deniz@akburak.com", totalPoints: 1500, rank: "Yeşil Kuşak", longestStreak: 8),
      LeaderboardUser(name: "Fatma Çelik", email: "fatma@akburak.com", totalPoints: 1350, rank: "Yeşil Kuşak", longestStreak: 2),
      LeaderboardUser(name: "Burak Şahin", email: "burak@akburak.com", totalPoints: 1100, rank: "Sarı Kuşak", longestStreak: 6),
      LeaderboardUser(name: "Gözde Öztürk", email: "gozde@akburak.com", totalPoints: 950, rank: "Sarı Kuşak", longestStreak: 3),
      LeaderboardUser(name: "Mehmet Yılmaz", email: "mehmet@akburak.com", totalPoints: 800, rank: "Beyaz Kuşak", longestStreak: 1),
      LeaderboardUser(name: "Zeynep Kaya", email: "zeynep@akburak.com", totalPoints: 650, rank: "Beyaz Kuşak", longestStreak: 7),
    ];
  }
}
