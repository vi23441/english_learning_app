import 'package:flutter/material.dart';

import '../presentation/dashboard_home_screen/dashboard_home_screen.dart';
import '../presentation/flashcards_practice_screen/flashcards_practice_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/test_results_screen/test_results_screen.dart';
import '../presentation/test_taking_screen/test_taking_screen.dart';
import '../presentation/video_library_screen/video_library_screen.dart';
import '../presentation/video_player_screen/video_player_screen.dart';
import '../presentation/vocabulary_lookup_screen/vocabulary_lookup_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String dashboardHomeScreen = '/dashboard-home-screen';
  static const String videoLibraryScreen = '/video-library-screen';
  static const String videoPlayerScreen = '/video-player-screen';
  static const String vocabularyLookupScreen = '/vocabulary-lookup-screen';
  static const String flashcardsPracticeScreen = '/flashcards-practice-screen';
  static const String testTakingScreen = '/test-taking-screen';
  static const String testResultsScreen = '/test-results-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    dashboardHomeScreen: (context) => const DashboardHomeScreen(),
    videoLibraryScreen: (context) => const VideoLibraryScreen(),
    videoPlayerScreen: (context) => const VideoPlayerScreen(),
    vocabularyLookupScreen: (context) => const VocabularyLookupScreen(),
    flashcardsPracticeScreen: (context) => const FlashcardsPracticeScreen(),
    testTakingScreen: (context) => const TestTakingScreen(),
    testResultsScreen: (context) => const TestResultsScreen(),
    // TODO: Add your other routes here
  };
}
