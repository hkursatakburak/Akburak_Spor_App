import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/workout_models.dart';
import '../providers/workout_engine_provider.dart';

final dummyExercises = [
  Exercise(name: "Jumping Jacks", type: ExerciseType.time, targetValue: 30, videoUrl: ""),
  Exercise(name: "Push Up", type: ExerciseType.reps, targetValue: 20, videoUrl: ""),
  Exercise(name: "Plank", type: ExerciseType.time, targetValue: 60, videoUrl: ""),
];

// Helper to retrieve beautiful placeholder Unsplash images based on exercise name
String _getExerciseImage(String name) {
  final cleanName = name.toLowerCase();
  if (cleanName.contains("jumping") || cleanName.contains("jack")) {
    return "https://images.unsplash.com/photo-1434596994283-7a4cc37c3a1d?q=80&w=800&auto=format&fit=crop";
  } else if (cleanName.contains("push") || cleanName.contains("şınav")) {
    return "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=800&auto=format&fit=crop";
  } else if (cleanName.contains("plank")) {
    return "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop";
  } else if (cleanName.contains("squat")) {
    return "https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=800&auto=format&fit=crop";
  } else if (cleanName.contains("boks") || cleanName.contains("gard") || cleanName.contains("torba")) {
    return "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=800&auto=format&fit=crop";
  }
  return "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=800&auto=format&fit=crop";
}

/// A custom progress tracker displaying segmented bars for each exercise.
/// - Completed: Turquoise
/// - Active: Pulsing Red
/// - Future: Grey
class WorkoutProgressTracker extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final WorkoutPhase phase;

  const WorkoutProgressTracker({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final isFinished = phase == WorkoutPhase.finished;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFinished ? "Antrenman Bitti! 🏆" : "Egzersiz ${currentIndex + 1} / $totalCount",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                "${((isFinished ? totalCount : currentIndex) / totalCount * 100).round()}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isFinished ? Colors.tealAccent : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalCount, (index) {
              Color color;
              bool isCurrent = index == currentIndex && !isFinished;

              if (isFinished || index < currentIndex) {
                color = const Color(0xFF40E0D0); // Turquoise
              } else if (isCurrent) {
                color = Colors.redAccent;
              } else {
                color = Colors.grey.withOpacity(0.3);
              }

              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index == totalCount - 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: isCurrent ? const PulsingBarIndicator() : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PulsingBarIndicator extends StatefulWidget {
  const PulsingBarIndicator({super.key});

  @override
  State<PulsingBarIndicator> createState() => _PulsingBarIndicatorState();
}

class _PulsingBarIndicatorState extends State<PulsingBarIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// A pulsing scaling timer text widget that turns bold Red during the final 3 seconds.
class PulsingTimerText extends StatefulWidget {
  final int secondsRemaining;
  const PulsingTimerText({super.key, required this.secondsRemaining});

  @override
  State<PulsingTimerText> createState() => _PulsingTimerTextState();
}

class _PulsingTimerTextState extends State<PulsingTimerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkPulse();
  }

  @override
  void didUpdateWidget(covariant PulsingTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkPulse();
  }

  void _checkPulse() {
    if (widget.secondsRemaining <= 3 && widget.secondsRemaining > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.secondsRemaining <= 3;
    final color = isUrgent 
        ? Colors.redAccent 
        : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87);

    return ScaleTransition(
      scale: isUrgent ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: Text(
        "${widget.secondsRemaining}",
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutEngineProvider.notifier).startWorkout();
    });
  }

  Widget _buildTopMediaArea(BuildContext context, WorkoutState state) {
    final isRest = state.phase == WorkoutPhase.rest;
    final isFinished = state.phase == WorkoutPhase.finished;
    
    String imageUrl = "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=800"; // default
    String titleText = "";
    String subtitleText = "";

    if (isRest && state.currentExerciseIndex < state.exercises.length - 1) {
      final nextEx = state.exercises[state.currentExerciseIndex + 1];
      imageUrl = _getExerciseImage(nextEx.name);
      titleText = nextEx.name;
      subtitleText = nextEx.type == ExerciseType.time 
          ? "${nextEx.targetValue} Saniye" 
          : "${nextEx.targetValue} Tekrar";
    } else if (state.phase == WorkoutPhase.active) {
      imageUrl = _getExerciseImage(state.currentExercise.name);
      titleText = state.currentExercise.name;
      subtitleText = state.currentExercise.type == ExerciseType.time 
          ? "Süre: ${state.currentExercise.targetValue} Saniye" 
          : "Hedef: ${state.currentExercise.targetValue} Tekrar";
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(isRest ? 0.70 : 0.45), // Darken layer
        child: isRest
            ? _buildNextExerciseOverlay(context, titleText, subtitleText)
            : Center(
                child: state.phase == WorkoutPhase.active 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_outline, size: 64, color: Colors.tealAccent),
                          const SizedBox(height: 12),
                          Text(
                            titleText,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 24, 
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black87, blurRadius: 10)]
                            ),
                          ),
                          Text(
                            subtitleText,
                            style: const TextStyle(
                              color: Colors.white70, 
                              fontSize: 16,
                              shadows: [Shadow(color: Colors.black87, blurRadius: 6)]
                            ),
                          ),
                        ],
                      )
                    : isFinished
                        ? const Icon(Icons.emoji_events, size: 64, color: Colors.amber)
                        : const Icon(Icons.sports_mma, size: 64, color: Colors.white54),
              ),
      ),
    );
  }

  Widget _buildNextExerciseOverlay(BuildContext context, String name, String target) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "SIRADAKİ EGZERSİZ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Süre / Hedef: $target",
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 6),
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutEngineProvider);
    final notifier = ref.read(workoutEngineProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Global Workout Progress Tracker
            WorkoutProgressTracker(
              currentIndex: state.currentExerciseIndex,
              totalCount: state.exercises.length,
              phase: state.phase,
            ),
            const Divider(height: 1, thickness: 1),
            
            // Top Media/Preview Canvas
            _buildTopMediaArea(context, state),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildPhaseContent(context, state, notifier),
                  ),
                ),
              ),
            ),
            
            // Controller Footer
            if (state.phase != WorkoutPhase.finished)
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => notifier.skip(),
                      icon: const Icon(Icons.fast_forward),
                      label: const Text("Geç"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isPaused ? () => notifier.resume() : () => notifier.pause(),
                        icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(
                          state.isPaused ? "Devam Et" : "Durdur", 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isPaused ? Colors.tealAccent : Colors.redAccent,
                          foregroundColor: state.isPaused ? Colors.black87 : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
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

  Widget _buildPhaseContent(BuildContext context, WorkoutState state, WorkoutEngineNotifier notifier) {
    switch (state.phase) {
      case WorkoutPhase.ready:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hazırlanın!", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: state.timeRemaining / 10.0,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: state.timeRemaining <= 3 ? Colors.redAccent : Colors.tealAccent,
                  ),
                ),
                PulsingTimerText(secondsRemaining: state.timeRemaining),
              ],
            ),
          ],
        );
      case WorkoutPhase.active:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.currentExercise.name, 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 32),
            if (state.currentExercise.type == ExerciseType.time)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: state.currentExercise.targetValue > 0 
                          ? state.timeRemaining / state.currentExercise.targetValue 
                          : 0,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      color: state.timeRemaining <= 3 ? Colors.redAccent : Color(0xFF40E0D0),
                    ),
                  ),
                  PulsingTimerText(secondsRemaining: state.timeRemaining),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    "Hedef: ${state.currentExercise.targetValue} Tekrar", 
                    style: const TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.w600)
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => notifier.completeRepExercise(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check, size: 24, fontWeight: FontWeight.bold),
                      label: const Text("Tamamla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        );
      case WorkoutPhase.rest:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Dinlenin", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: state.timeRemaining / 30.0,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: state.timeRemaining <= 3 ? Colors.redAccent : Colors.blueAccent,
                  ),
                ),
                PulsingTimerText(secondsRemaining: state.timeRemaining),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => notifier.addRestTime(20),
              icon: const Icon(Icons.more_time),
              label: const Text("+20s Dinlenme Ekle"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      case WorkoutPhase.finished:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            const Text("Tebrikler!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              "Antrenmanı başarıyla tamamladınız.", 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 18, color: Colors.grey)
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Ana Ekrana Dön", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        );
    }
  }
}
