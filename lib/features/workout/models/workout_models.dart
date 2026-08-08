enum ExerciseType { time, reps }

class Exercise {
  final String name;
  final ExerciseType type;
  final int targetValue; // Seconds if time, count if reps
  final String videoUrl;

  Exercise({
    required this.name,
    required this.type,
    required this.targetValue,
    required this.videoUrl,
  });
}

class WorkoutRoutine {
  final String title;
  final int durationMinutes;
  final String difficulty;
  final String imageUrl;
  final int exerciseCount;
  final List<Exercise> exercises;
  final String? instructorId;
  final String? instructorName;
  final String? instructorBadgeLevel; // "Bronze" | "Silver" | "Gold"

  WorkoutRoutine({
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.imageUrl,
    required this.exerciseCount,
    required this.exercises,
    this.instructorId,
    this.instructorName,
    this.instructorBadgeLevel = "Bronze",
  });
}

enum WorkoutPhase { ready, active, rest, finished }

class WorkoutState {
  final WorkoutPhase phase;
  final int currentExerciseIndex;
  final int timeRemaining;
  final List<Exercise> exercises;
  final bool isPaused;

  WorkoutState({
    required this.phase,
    required this.currentExerciseIndex,
    required this.timeRemaining,
    required this.exercises,
    this.isPaused = false,
  });

  Exercise get currentExercise => exercises[currentExerciseIndex];
  
  WorkoutState copyWith({
    WorkoutPhase? phase,
    int? currentExerciseIndex,
    int? timeRemaining,
    List<Exercise>? exercises,
    bool? isPaused,
  }) {
    return WorkoutState(
      phase: phase ?? this.phase,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      exercises: exercises ?? this.exercises,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
