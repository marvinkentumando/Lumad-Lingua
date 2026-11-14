import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/vocabulary_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/learning/learning_path_screen.dart';
import '../screens/learning/unit_details_screen.dart';
import '../screens/learning/lesson_study_screen.dart';
import '../screens/learning/lesson_screen.dart';
import '../screens/learning/lesson_result_screen.dart';
import '../screens/dictionary/dictionary_screen.dart';
import '../screens/dictionary/word_details_screen.dart';
import '../screens/pronunciation/pronunciation_screen.dart';
import '../screens/sentiment/sentiment_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/classroom/classroom_dashboard_screen.dart';
import '../screens/gamification/streaks_xp_dashboard_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/arena/duel_lobby_screen.dart';
import '../screens/arena/duel_battle_screen.dart';
import '../widgets/common/app_bottom_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/unit/:id',
      builder: (context, state) => UnitDetailsScreen(
        unitId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/lesson/:id',
      builder: (context, state) => LessonStudyScreen(
        lessonId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/lesson/:id/drills',
      builder: (context, state) => LessonScreen(
        lessonId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/lesson-result',
      builder: (context, state) {
        final result = state.extra as Map<String, dynamic>? ?? {};
        return LessonResultScreen(resultData: result);
      },
    ),
    GoRoute(
      path: '/dictionary/details',
      builder: (context, state) {
        final vocab = state.extra as VocabularyModel;
        return WordDetailsScreen(vocabulary: vocab);
      },
    ),
    GoRoute(
      path: '/pronunciation',
      builder: (context, state) => const PronunciationScreen(),
    ),
    GoRoute(
      path: '/sentiment',
      builder: (context, state) => const SentimentScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/classroom/dashboard',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return ClassroomDashboardScreen(
          classId: args['classId'] ?? '',
          classroomData: args['classroomData'] ?? {},
        );
      },
    ),
    GoRoute(
      path: '/streaks-xp',
      builder: (context, state) => const StreaksXpDashboardScreen(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/arena',
      builder: (context, state) => const DuelLobbyScreen(),
    ),
    GoRoute(
      path: '/arena/battle',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return DuelBattleScreen(
          sessionId: args['sessionId'] ?? '',
        );
      },
    ),

    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learn',
              builder: (context, state) => const LearningPathScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dictionary',
              builder: (context, state) => const DictionaryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
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
