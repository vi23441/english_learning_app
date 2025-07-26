import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../providers/auth_provider.dart';
import '../providers/video_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/test_provider.dart';
import '../providers/admin_provider.dart';
import '../services/test_data_seeder.dart';
import 'firebase_options.dart';

void main() async {
  debugPrint('main() started.');
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    debugPrint('Checking if Firebase [DEFAULT] app exists...');
    bool firebaseDefaultAppExists = Firebase.apps.any((app) => app.name == '[DEFAULT]');
    debugPrint('Firebase [DEFAULT] app exists: $firebaseDefaultAppExists');

    if (firebaseDefaultAppExists) {
      debugPrint('Firebase [DEFAULT] app already exists. Skipping initialization and App Check activation.');
      for (var app in Firebase.apps) {
        debugPrint('Existing Firebase app: ${app.name}');
      }
    }

    if (!firebaseDefaultAppExists) {
      debugPrint('Initializing Firebase...');
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('Firebase initialized.');
      } catch (e) {
        debugPrint('Error during Firebase initialization: $e');
        if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
          // Ignore duplicate app error if it happens here
        } else {
          rethrow;
        }
      }
    } else {
      debugPrint('Firebase [DEFAULT] app already exists. Proceeding to App Check activation.');
      for (var app in Firebase.apps) {
        debugPrint('Existing Firebase app: ${app.name}');
      }
    }

    // Configure Firebase App Check - This should run regardless of whether Firebase was just initialized or already existed
    try {
      debugPrint('Activating Firebase App Check...');
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
      );
      debugPrint('Firebase App Check activated.');

      // Configure Firebase settings to reduce warnings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Seed test data in development
      if (kDebugMode) {
        final seeder = TestDataSeeder();
        seeder.seedTestData();
      }

    } catch (e) {
      debugPrint('Error during App Check activation or other post-init setup: $e');
      // We might still want to ignore duplicate app errors here if they somehow propagate,
      // but the primary duplicate check is now outside this try block.
      if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
        // This case should ideally not happen here anymore if the logic is correct.
        // But keeping it for robustness.
      } else {
        rethrow;
      }
    }

    // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return CustomErrorWidget(
        errorDetails: details,
      );
    };

    // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(MyApp());
  }, (error, stack) {
    if (error.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
      // Ignore duplicate app error
      return;
    }
    debugPrint('Uncaught error: $error');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Sizer(builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'EduLearn Mobile',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      }),
    );
  }
}
