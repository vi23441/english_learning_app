import 'package:flutter/material.dart';

import '../presentation/dashboard_home_screen/dashboard_home_screen.dart';
import '../presentation/flashcard_set_detail_screen/flashcard_set_detail_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/test_results_screen/test_results_screen.dart';
import '../presentation/test_taking_screen/test_taking_screen.dart';
import '../presentation/video_library_screen/video_library_screen.dart';
import '../presentation/video_player_screen/video_player_screen.dart';

import '../presentation/admin/admin_dashboard_screen.dart';
import '../presentation/admin/admin_users_screen.dart';
import '../presentation/admin/admin_videos_screen.dart';
import '../presentation/admin/admin_tests_screen.dart';
import '../presentation/admin/admin_questions_screen.dart';
import '../presentation/admin/admin_feedbacks_screen.dart';
import '../presentation/admin/admin_statistics_screen.dart';
import '../presentation/test_history_screen/test_history_screen.dart';

import '../presentation/vocabulary_sets_screen/vocabulary_sets_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String dashboardHomeScreen = '/dashboard-home-screen';
  static const String videoLibraryScreen = '/video-library-screen';
  static const String videoPlayerScreen = '/video-player-screen';
  static const String vocabularySetsScreen = '/vocabulary-sets-screen'; // New route
  static const String flashcardSetDetailScreen = '/flashcard-set-detail-screen';
  // static const String testListScreen = '/test-list-screen';
  static const String testTakingScreen = '/test-taking-screen';
  static const String testResultsScreen = '/test-results-screen';
  static const String testHistoryScreen = '/test-history-screen';
  static const String settingsScreen = '/settings-screen';
  static const String profileScreen = '/profile-screen';
  
  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String adminUsers = '/admin-users';
  static const String adminVideos = '/admin-videos';
  static const String adminTests = '/admin-tests';
  static const String adminQuestions = '/admin-questions';
  static const String adminFeedbacks = '/admin-feedbacks';
  static const String adminStatistics = '/admin-statistics';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    dashboardHomeScreen: (context) => const DashboardHomeScreen(),
    videoLibraryScreen: (context) => const VideoLibraryScreen(),
    videoPlayerScreen: (context) {
      final String videoId = ModalRoute.of(context)?.settings.arguments as String? ?? 'default';
      return VideoPlayerScreen(videoId: videoId);
    },
    vocabularySetsScreen: (context) => VocabularySetsScreen(), // New route
    flashcardSetDetailScreen: (context) {
      final String setId = ModalRoute.of(context)?.settings.arguments as String? ?? 'dummy_set_id';
      return FlashcardSetDetailScreen(setId: setId);
    },
    // testListScreen: (context) => TestListScreen(),
    testTakingScreen: (context) => const TestTakingScreen(),
    testResultsScreen: (context) => const TestResultsScreen(),
    testHistoryScreen: (context) => const TestHistoryScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    profileScreen: (context) => const ProfileScreen(),
    
    // Admin routes
    adminDashboard: (context) => const AdminDashboardScreen(),
    adminUsers: (context) => const AdminUsersScreen(),
    adminVideos: (context) => const AdminVideosScreen(),
    adminTests: (context) => const AdminTestsScreen(),
    adminQuestions: (context) => const AdminQuestionsScreen(),
    adminFeedbacks: (context) => const AdminFeedbacksScreen(),
    adminStatistics: (context) => const AdminStatisticsScreen(),
    // TODO: Add your other routes here
  };
}