import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_models.dart';
import '../presentation/active_workout_screen.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/user_service.dart';

class WorkoutEngineNotifier extends Notifier<WorkoutState> {
  Timer? _timer;

  @override
  WorkoutState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return WorkoutState(
      phase: WorkoutPhase.ready,
      currentExerciseIndex: 0,
      timeRemaining: 10, // 10s prep
      exercises: dummyExercises,
    );
  }

  void startWorkout() {
    _startCountdown(10, WorkoutPhase.ready);
  }

  void _startCountdown(int seconds, WorkoutPhase phase) {
    _timer?.cancel();
    state = state.copyWith(timeRemaining: seconds, phase: phase, isPaused: false);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        timer.cancel();
        FeedbackService().triggerRoundEnd();
        _handlePhaseComplete();
      }
    });
  }

  void _handlePhaseComplete() {
    switch (state.phase) {
      case WorkoutPhase.ready:
        _startActivePhase();
        break;
      case WorkoutPhase.active:
        _startRestPhase();
        break;
      case WorkoutPhase.rest:
        _nextExercise();
        break;
      case WorkoutPhase.finished:
        break;
    }
  }

  void _startActivePhase() {
    final exercise = state.currentExercise;
    if (exercise.type == ExerciseType.time) {
      _startCountdown(exercise.targetValue, WorkoutPhase.active);
    } else {
      _timer?.cancel();
      state = state.copyWith(
        phase: WorkoutPhase.active,
        timeRemaining: 0,
        isPaused: false,
      );
    }
  }

  void completeRepExercise() {
    if (state.phase == WorkoutPhase.active && state.currentExercise.type == ExerciseType.reps) {
      _startRestPhase();
    }
  }

  void _startRestPhase() {
    if (state.currentExerciseIndex < state.exercises.length - 1) {
      _startCountdown(30, WorkoutPhase.rest); // 30s rest default
    } else {
      state = state.copyWith(phase: WorkoutPhase.finished);

      // Calculate workout routine statistics and submit to backend
      int totalSeconds = 0;
      for (final ex in state.exercises) {
        totalSeconds += ex.targetValue;
      }
      int durationMinutes = (totalSeconds / 60).round();
      if (durationMinutes < 1) durationMinutes = 1;
      final int kcal = durationMinutes * 8;

      UserService().submitWorkoutSession(durationMinutes, kcal, "Antrenman").then((success) {
        if (success) {
          ref.invalidate(userStatsFutureProvider);
          ref.invalidate(userProfileProvider);
        }
      });
    }
  }

  void _nextExercise() {
    if (state.currentExerciseIndex < state.exercises.length - 1) {
      state = state.copyWith(currentExerciseIndex: state.currentExerciseIndex + 1);
      _startActivePhase();
    }
  }

  void addRestTime(int seconds) {
    if (state.phase == WorkoutPhase.rest) {
      state = state.copyWith(timeRemaining: state.timeRemaining + seconds);
    }
  }

  void skipRest() {
    if (state.phase == WorkoutPhase.rest) {
      _timer?.cancel();
      _nextExercise();
    }
  }

  void pause() {
    if (state.phase == WorkoutPhase.finished) return;
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    if (!state.isPaused || state.phase == WorkoutPhase.finished) return;
    state = state.copyWith(isPaused: false);
    
    if (state.phase == WorkoutPhase.ready || state.phase == WorkoutPhase.rest || 
        (state.phase == WorkoutPhase.active && state.currentExercise.type == ExerciseType.time)) {
      _startCountdown(state.timeRemaining, state.phase);
    }
  }

  void skip() {
    if (state.phase == WorkoutPhase.finished) return;
    _timer?.cancel();
    state = state.copyWith(timeRemaining: 0, isPaused: false);
    _handlePhaseComplete();
  }

}

final workoutEngineProvider = NotifierProvider<WorkoutEngineNotifier, WorkoutState>(WorkoutEngineNotifier.new);
