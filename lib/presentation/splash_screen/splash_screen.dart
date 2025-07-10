import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation controller for transitions
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Fade animation for screen transition
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate app initialization tasks
      await _performInitializationTasks();

      if (mounted) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    // Simulate checking authentication status
    setState(() {
      _loadingText = 'Checking authentication...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate loading user preferences
    setState(() {
      _loadingText = 'Loading preferences...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate fetching essential config data
    setState(() {
      _loadingText = 'Fetching configuration...';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulate preparing cached vocabulary content
    setState(() {
      _loadingText = 'Preparing content...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Final delay to ensure smooth animation completion
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _navigateToNextScreen() async {
    // Start fade out animation
    await _fadeAnimationController.forward();

    if (mounted) {
      // Simulate authentication check
      final bool isAuthenticated = _checkAuthenticationStatus();
      final bool isNewUser = _checkIfNewUser();

      String nextRoute;
      if (isAuthenticated) {
        nextRoute = '/dashboard-home-screen';
      } else if (isNewUser) {
        nextRoute = '/registration-screen';
      } else {
        nextRoute = '/login-screen';
      }

      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  bool _checkAuthenticationStatus() {
    // Mock authentication check - in real app, check stored tokens/credentials
    return false; // Simulate non-authenticated user
  }

  bool _checkIfNewUser() {
    // Mock new user check - in real app, check if user has completed onboarding
    return false; // Simulate returning user
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _loadingText = 'Retrying...';
    });
    _initializeApp();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar on Android, match brand color on iOS
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryLight,
                    AppTheme.primaryLight.withValues(alpha: 0.8),
                    AppTheme.secondaryLight.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spacer to push content to center
                    const Spacer(flex: 2),

                    // Animated Logo Section
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: _buildLogoSection(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 8.h),

                    // Loading or Error Section
                    _hasError ? _buildErrorSection() : _buildLoadingSection(),

                    // Spacer to maintain center alignment
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: AppTheme.getElevationShadow(
              isLight: true,
              elevation: 8.0,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'school',
              color: AppTheme.primaryLight,
              size: 12.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App Name
        Text(
          'EduLearn',
          style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 1.h),

        // App Tagline
        Text(
          'Learn • Practice • Excel',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading Indicator
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: CircularProgressIndicator(
            strokeWidth: 0.8.w,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),

        SizedBox(height: 2.h),

        // Loading Text
        Text(
          _loadingText,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error Icon
        CustomIconWidget(
          iconName: 'error_outline',
          color: Colors.white,
          size: 8.w,
        ),

        SizedBox(height: 2.h),

        // Error Message
        Text(
          'Connection timeout',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Please check your internet connection',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 3.h),

        // Retry Button
        ElevatedButton(
          onPressed: _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryLight,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.primaryLight,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Retry',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
