import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    if (state.mode == TimerMode.roundTimer) {
      if (state.phase == RoundPhase.work) {
        backgroundColor = Colors.redAccent.withOpacity(isDark ? 0.2 : 0.1);
      } else if (state.phase == RoundPhase.rest) {
        backgroundColor = Colors.blueAccent.withOpacity(isDark ? 0.2 : 0.1);
      } else if (state.phase == RoundPhase.finished) {
        backgroundColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Sayaç",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SegmentedButton<TimerMode>(
                segments: const [
                  ButtonSegment(
                    value: TimerMode.stopwatch,
                    label: Text("Kronometre"),
                  ),
                  ButtonSegment(
                    value: TimerMode.roundTimer,
                    label: Text("Raunt Sayacı"),
                  ),
                ],
                selected: {state.mode},
                onSelectionChanged: (Set<TimerMode> newSelection) {
                  notifier.setMode(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Settings Panel (Only for Round Timer and if stopped)
            if (state.mode == TimerMode.roundTimer &&
                state.phase == RoundPhase.stopped)
              _buildRoundSettings(context, state, notifier),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.mode == TimerMode.roundTimer)
                    Text(
                      state.phase == RoundPhase.finished
                          ? "Bitti"
                          : "Raunt ${state.currentRound} / ${state.totalRounds}",
                      style: const TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _formatTime(state.totalSeconds),
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w200,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.mode == TimerMode.roundTimer)
                    Text(
                      _getPhaseText(state.phase),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getPhaseColor(state.phase),
                      ),
                    ),
                ],
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.refresh),
                    onPressed: () => notifier.reset(),
                  ),
                  FloatingActionButton.large(
                    onPressed: () => notifier.togglePlayPause(),
                    backgroundColor:
                        state.phase == RoundPhase.work ||
                            state.phase == RoundPhase.rest
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    child: Icon(
                      state.phase == RoundPhase.work ||
                              state.phase == RoundPhase.rest
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSettings(
    BuildContext context,
    TimerState state,
    TimerNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSettingSpinner(
            context,
            "Çalışma (dk)",
            state.workDuration ~/ 60,
            (val) {
              notifier.updateSettings(workDuration: val * 60);
            },
          ),
          _buildSettingSpinner(
            context,
            "Dinlenme (dk)",
            state.restDuration ~/ 60,
            (val) {
              notifier.updateSettings(restDuration: val * 60);
            },
          ),
          _buildSettingSpinner(context, "Raunt", state.totalRounds, (val) {
            notifier.updateSettings(totalRounds: val);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingSpinner(
    BuildContext context,
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
            ),
            Text(
              "$value",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  String _getPhaseText(RoundPhase phase) {
    switch (phase) {
      case RoundPhase.work:
        return "ÇALIŞ!";
      case RoundPhase.rest:
        return "DİNLEN";
      case RoundPhase.stopped:
        return "HAZIR";
      case RoundPhase.finished:
        return "TAMAMLANDI";
    }
  }

  Color _getPhaseColor(RoundPhase phase) {
    switch (phase) {
      case RoundPhase.work:
        return Colors.redAccent;
      case RoundPhase.rest:
        return Colors.blueAccent;
      case RoundPhase.stopped:
        return Colors.grey;
      case RoundPhase.finished:
        return Colors.green;
    }
  }
}
