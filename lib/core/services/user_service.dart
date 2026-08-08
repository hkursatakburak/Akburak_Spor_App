import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/home/models/home_models.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches UserStats dynamically from backend profile data
  Future<UserStats> getUserStats() async {
    try {
      final response = await _apiClient.get('/api/user/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        return UserStats(
          totalPoints: data['total_points'] ?? 0,
          workouts: data['workouts'] ?? 0,
          calories: data['calories'] ?? 0,
          minutes: data['minutes'] ?? 0,
        );
      }
      throw Exception('Failed to load user stats');
    } catch (e) {
      debugPrint('UserService getUserStats error: $e');
      // Return safe defaults
      return UserStats(
        totalPoints: 0,
        workouts: 0,
        calories: 0,
        minutes: 0,
      );
    }
  }

  /// Fetches the raw user profile JSON mapping from backend
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get('/api/user/profile');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load user profile');
    } catch (e) {
      debugPrint('UserService getUserProfile error: $e');
      return {};
    }
  }

  /// Sends the completed workout stats (duration, calories, type) to backend
  Future<bool> submitWorkoutSession(int durationMinutes, int kcal, String workoutType) async {
    try {
      final response = await _apiClient.post(
        '/api/user/workout-session',
        data: {
          'duration_minutes': durationMinutes,
          'kcal': kcal,
          'workout_type': workoutType,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('UserService submitWorkoutSession error: $e');
      return false;
    }
  }
}

final userStatsFutureProvider = FutureProvider<UserStats>((ref) async {
  return UserService().getUserStats();
});

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return UserService().getUserProfile();
});
