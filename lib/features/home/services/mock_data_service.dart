import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_models.dart';

class MockDataService {
  UserStats getUserStats() {
    return UserStats(
      totalPoints: 50,
      workouts: 1,
      calories: 1361,
      minutes: 45,
    );
  }

  List<WorkoutProgram> getYourPrograms() {
    return [
      WorkoutProgram(
        title: "Tüm Vücut Kas Geliştirme",
        progress: "2/12 Antrenman",
        imageUrl: "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=500&auto=format&fit=crop",
      ),
      WorkoutProgram(
        title: "Kardiyo Başlangıç",
        progress: "1/5 Antrenman",
        imageUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500&auto=format&fit=crop",
      ),
    ];
  }

  List<WorkoutLocation> getWorkoutLocations() {
    return [
      WorkoutLocation(
        title: "Kulüpte",
        imageUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500&auto=format&fit=crop",
      ),
      WorkoutLocation(
        title: "Evde",
        imageUrl: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=500&auto=format&fit=crop",
      ),
      WorkoutLocation(
        title: "Dışarıda",
        imageUrl: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500&auto=format&fit=crop",
      ),
    ];
  }
}

final mockDataServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});

final userStatsProvider = Provider<UserStats>((ref) {
  return ref.watch(mockDataServiceProvider).getUserStats();
});

final yourProgramsProvider = Provider<List<WorkoutProgram>>((ref) {
  return ref.watch(mockDataServiceProvider).getYourPrograms();
});

final workoutLocationsProvider = Provider<List<WorkoutLocation>>((ref) {
  return ref.watch(mockDataServiceProvider).getWorkoutLocations();
});
