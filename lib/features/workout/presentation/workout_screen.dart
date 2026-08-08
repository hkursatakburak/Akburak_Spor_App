import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/user_service.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildDailyGoalCard(context, ref),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildMainCategoriesGrid(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "En Çok Tercih Edilenler",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTop10HorizontalList(context),
                  const SizedBox(height: 32), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      title: const Text(
        "Antrenman",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.precision_manufacturing, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "AI Asistan geliştirme aşamasında!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userStatsAsync = ref.watch(userStatsFutureProvider);

    return userStatsAsync.maybeWhen(
      data: (userStats) {
        final double kcalProgress = (userStats.calories / 600).clamp(0.0, 1.0);
        final int progressPercent = (kcalProgress * 100).round();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Günlük Hedef",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    "%$progressPercent",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: kcalProgress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGoalStat(context, Icons.local_fire_department, "${userStats.calories} / 600 Kcal"),
                  _buildGoalStat(context, Icons.timer, "${userStats.minutes} / 45 Dk"),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      ),
    );
  }

  Widget _buildGoalStat(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCategoriesGrid() {
    final categories = [
      {"title": "Boks", "img": "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=500&auto=format&fit=crop"},
      {"title": "Wushu Sanda", "img": "https://images.unsplash.com/photo-1555597673-b21d5c935865?q=80&w=500&auto=format&fit=crop"},
      {"title": "Kardiyo", "img": "https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=500&auto=format&fit=crop"},
      {"title": "Kas Geliştirme", "img": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500&auto=format&fit=crop"},
      {"title": "Benim Oluşturduklarım", "img": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500&auto=format&fit=crop"},
      {"title": "Eğitmenden Gelenler", "img": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=500&auto=format&fit=crop"},
      {"title": "Favorilerim", "img": "https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=500&auto=format&fit=crop"},
      {"title": "En Son Yaptıklarım", "img": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=500&auto=format&fit=crop"},
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final cat = categories[index];
          return _buildGridCard(context, cat['title']!, cat['img']!);
        },
        childCount: categories.length,
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, String imageUrl) {
    return InkWell(
      onTap: () {
        context.push('/workout/category', extra: title);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop10HorizontalList(BuildContext context) {
    final topRoutines = [
      {"title": "Strong Arms, Powerful Guns", "level": "Orta", "time": "27 Dk", "img": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=500&auto=format&fit=crop"},
      {"title": "Core Crusher 3000", "level": "Zor", "time": "15 Dk", "img": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=500&auto=format&fit=crop"},
      {"title": "Morning Mobility", "level": "Başlangıç", "time": "10 Dk", "img": "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=500&auto=format&fit=crop"},
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: topRoutines.length,
        itemBuilder: (context, index) {
          final routine = topRoutines[index];
          return _buildTopRoutineCard(context, routine);
        },
      ),
    );
  }

  Widget _buildTopRoutineCard(BuildContext context, Map<String, String> routine) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(routine['img']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routine['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.sports_mma, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  routine['level']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  routine['time']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

