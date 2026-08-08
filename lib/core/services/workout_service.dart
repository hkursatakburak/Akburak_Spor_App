import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../../features/workout/models/workout_models.dart';

class WorkoutService {
  final ApiClient _apiClient = ApiClient();

  Future<List<WorkoutRoutine>> getWorkoutsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/api/workouts/$category');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List? ?? [];
        return data.map((json) => _mapJsonToWorkoutRoutine(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('WorkoutService getWorkoutsByCategory network error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('WorkoutService getWorkoutsByCategory unexpected error: $e');
      rethrow;
    }
  }

  WorkoutRoutine _mapJsonToWorkoutRoutine(Map<String, dynamic> json) {
    final exercisesList = (json['exercises'] as List? ?? []).map((exJson) {
      final durationStr = exJson['duration_seconds_or_reps']?.toString() ?? "30";
      final target = int.tryParse(durationStr) ?? 30;
      final type = durationStr.contains("x") ? ExerciseType.reps : ExerciseType.time;
      
      return Exercise(
        name: exJson['name'] ?? "",
        type: type,
        targetValue: target,
        videoUrl: exJson['video_url'] ?? "",
      );
    }).toList();

    return WorkoutRoutine(
      title: json['title'] ?? "",
      durationMinutes: json['duration_minutes'] ?? 15,
      difficulty: json['difficulty'] ?? "Orta",
      imageUrl: json['cover_image_url'] ?? "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=800",
      exerciseCount: exercisesList.length,
      exercises: exercisesList,
      instructorId: json['instructor_id'],
      instructorName: json['instructor_name'] ?? "Antrenör",
      instructorBadgeLevel: json['instructor_badge_level'] ?? "Bronze",
    );
  }
}
