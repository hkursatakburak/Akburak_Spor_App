import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/workout/presentation/workout_screen.dart';
import '../../features/workout/presentation/workout_detail_screen.dart';
import '../../features/workout/presentation/active_workout_screen.dart';
import '../../features/timer/presentation/timer_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/workout/presentation/category_workout_list_screen.dart';
import '../../features/chatbot/presentation/chatbot_screen.dart';
import '../../features/trainer/presentation/trainer_dashboard_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_flow_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/social/presentation/leaderboard_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorWorkoutKey = GlobalKey<NavigatorState>(debugLabel: 'shellWorkout');
final _shellNavigatorTimerKey = GlobalKey<NavigatorState>(debugLabel: 'shellTimer');
final _shellNavigatorLeaderboardKey = GlobalKey<NavigatorState>(debugLabel: 'shellLeaderboard');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
    GoRoute(
      path: '/trainer',
      builder: (context, state) => const TrainerDashboardScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final Map<String, String> args = state.extra as Map<String, String>? ?? {};
        return ChatScreen(
          trainerId: args['trainerId'] ?? 'inst_hamza',
          trainerName: args['trainerName'] ?? 'Hamza Akburak',
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlowScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorWorkoutKey,
          routes: [
            GoRoute(
              path: '/workout',
              builder: (context, state) => const WorkoutScreen(),
              routes: [
                GoRoute(
                  path: 'category',
                  builder: (context, state) => CategoryWorkoutListScreen(categoryName: state.extra as String? ?? "Boks"),
                ),
                GoRoute(
                  path: 'detail',
                  builder: (context, state) => WorkoutDetailScreen(title: state.extra as String? ?? "Antrenman"),
                ),
                GoRoute(
                  path: 'active',
                  builder: (context, state) => const ActiveWorkoutScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTimerKey,
          routes: [
            GoRoute(
              path: '/timer',
              builder: (context, state) => const TimerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLeaderboardKey,
          routes: [
            GoRoute(
              path: '/leaderboard',
              builder: (context, state) => const LeaderboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
