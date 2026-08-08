class UserStats {
  final int totalPoints;
  final int workouts;
  final int calories;
  final int minutes;

  UserStats({
    required this.totalPoints,
    required this.workouts,
    required this.calories,
    required this.minutes,
  });
}

class WorkoutProgram {
  final String title;
  final String progress;
  final String imageUrl;

  WorkoutProgram({
    required this.title,
    required this.progress,
    required this.imageUrl,
  });
}

class WorkoutLocation {
  final String title;
  final String imageUrl;

  WorkoutLocation({
    required this.title,
    required this.imageUrl,
  });
}
