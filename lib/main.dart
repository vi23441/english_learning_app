import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase only if [DEFAULT] app does not exist, ignore duplicate error
    try {
      if (!Firebase.apps.any((app) => app.name == '[DEFAULT]')) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
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
      if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
        // Ignore duplicate app error
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
