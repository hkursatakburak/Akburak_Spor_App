import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/workout_service.dart';
import '../../profile/widgets/badge_display.dart';
import '../models/workout_models.dart';

class CategoryWorkoutListScreen extends StatefulWidget {
  final String categoryName;

  const CategoryWorkoutListScreen({super.key, required this.categoryName});

  @override
  State<CategoryWorkoutListScreen> createState() => _CategoryWorkoutListScreenState();
}

class _CategoryWorkoutListScreenState extends State<CategoryWorkoutListScreen> {
  late Future<List<WorkoutRoutine>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = WorkoutService().getWorkoutsByCategory(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<WorkoutRoutine>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Veri yüklenirken hata oluştu",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lütfen sunucu bağlantınızı kontrol edin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _workoutsFuture = WorkoutService().getWorkoutsByCategory(widget.categoryName);
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Yeniden Dene", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          final List<WorkoutRoutine> routines = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  "${widget.categoryName} Antrenmanları",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              if (routines.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Bu kategori için antrenman bulunamadı.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final routine = routines[index];
                        return _buildRoutineCard(context, routine);
                      },
                      childCount: routines.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, WorkoutRoutine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 160,
      child: InkWell(
        onTap: () {
          context.push('/workout/detail', extra: routine.title);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: NetworkImage(routine.imageUrl),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      routine.instructorName ?? "Antrenör",
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InstructorBadgeWidget(level: routine.instructorBadgeLevel ?? "Bronze"),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  routine.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "${routine.durationMinutes} Dk",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.format_list_numbered, color: Colors.tealAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "${routine.exerciseCount} Egzersiz",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bar_chart, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          routine.difficulty,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
