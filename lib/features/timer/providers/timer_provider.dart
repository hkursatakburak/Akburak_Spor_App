import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/feedback_service.dart';

enum TimerMode { stopwatch, roundTimer }
enum RoundPhase { stopped, work, rest, finished }

class TimerState {
  final TimerMode mode;
  final RoundPhase phase;
  final int totalSeconds;
  
  // Round Timer specific
  final int workDuration;
  final int restDuration;
  final int totalRounds;
  final int currentRound;

  TimerState({
    required this.mode,
    required this.phase,
    required this.totalSeconds,
    required this.workDuration,
    required this.restDuration,
    required this.totalRounds,
    required this.currentRound,
  });

  TimerState copyWith({
    TimerMode? mode,
    RoundPhase? phase,
    int? totalSeconds,
    int? workDuration,
    int? restDuration,
    int? totalRounds,
    int? currentRound,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      workDuration: workDuration ?? this.workDuration,
      restDuration: restDuration ?? this.restDuration,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
    );
  }
}

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return TimerState(
      mode: TimerMode.roundTimer,
      phase: RoundPhase.stopped,
      totalSeconds: 180, // 3 mins default
      workDuration: 180,
      restDuration: 60, // 1 min rest
      totalRounds: 5,
      currentRound: 1,
    );
  }

  void setMode(TimerMode mode) {
    _timer?.cancel();
    state = state.copyWith(
      mode: mode,
      phase: RoundPhase.stopped,
      totalSeconds: mode == TimerMode.roundTimer ? state.workDuration : 0,
      currentRound: 1,
    );
  }

  void updateSettings({int? workDuration, int? restDuration, int? totalRounds}) {
    state = state.copyWith(
      workDuration: workDuration ?? state.workDuration,
      restDuration: restDuration ?? state.restDuration,
      totalRounds: totalRounds ?? state.totalRounds,
      totalSeconds: workDuration ?? state.workDuration,
      phase: RoundPhase.stopped,
      currentRound: 1,
    );
  }

  void togglePlayPause() {
    if (state.phase == RoundPhase.stopped || state.phase == RoundPhase.finished) {
      if (state.mode == TimerMode.stopwatch) {
        state = state.copyWith(phase: RoundPhase.work, totalSeconds: 0);
      } else {
        if (state.phase == RoundPhase.finished) {
           state = state.copyWith(currentRound: 1, totalSeconds: state.workDuration);
        }
        state = state.copyWith(phase: RoundPhase.work);
      }
      _startTimer();
    } else {
      _timer?.cancel();
      state = state.copyWith(phase: RoundPhase.stopped);
    }
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      phase: RoundPhase.stopped,
      totalSeconds: state.mode == TimerMode.roundTimer ? state.workDuration : 0,
      currentRound: 1,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.mode == TimerMode.stopwatch) {
        state = state.copyWith(totalSeconds: state.totalSeconds + 1);
      } else {
        if (state.totalSeconds > 0) {
          state = state.copyWith(totalSeconds: state.totalSeconds - 1);
        } else {
          FeedbackService().triggerRoundEnd();
          _handleRoundTimerPhaseComplete();
        }
      }
    });
  }

  void _handleRoundTimerPhaseComplete() {
    if (state.phase == RoundPhase.work) {
      if (state.currentRound < state.totalRounds) {
        // Go to rest
        state = state.copyWith(
          phase: RoundPhase.rest,
          totalSeconds: state.restDuration,
        );
      } else {
        // Finished
        _timer?.cancel();
        state = state.copyWith(phase: RoundPhase.finished, totalSeconds: 0);
      }
    } else if (state.phase == RoundPhase.rest) {
      // Go to next round
      state = state.copyWith(
        phase: RoundPhase.work,
        currentRound: state.currentRound + 1,
        totalSeconds: state.workDuration,
      );
    }
  }

}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);
