import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the educational mobile application.
/// Implements Contemporary Educational Minimalism with Focused Learning Palette.
class AppTheme {
  AppTheme._();

  // Educational Application Color Palette - Focused Learning Colors
  // Primary colors for educational authority and trust
  static const Color primaryLight =
      Color(0xFF2563EB); // Deep blue for educational authority
  static const Color primaryDark =
      Color(0xFF3B82F6); // Lighter blue for dark mode readability

  // Secondary colors for interactive elements and progress
  static const Color secondaryLight =
      Color(0xFF7C3AED); // Accent purple for interactions
  static const Color secondaryDark =
      Color(0xFF8B5CF6); // Lighter purple for dark mode

  // Semantic colors for feedback and states
  static const Color successLight =
      Color(0xFF059669); // Forest green for completed tasks
  static const Color successDark =
      Color(0xFF10B981); // Brighter green for dark mode
  static const Color warningLight =
      Color(0xFFD97706); // Amber for attention elements
  static const Color warningDark =
      Color(0xFFF59E0B); // Brighter amber for dark mode
  static const Color errorLight = Color(0xFFDC2626); // Clear red for errors
  static const Color errorDark =
      Color(0xFFEF4444); // Brighter red for dark mode

  // Background and surface colors optimized for extended mobile use
  static const Color backgroundLight =
      Color(0xFFF8FAFC); // Soft gray-blue reducing eye strain
  static const Color backgroundDark =
      Color(0xFF0F172A); // Deep slate for dark mode
  static const Color surfaceLight =
      Color(0xFFFFFFFF); // Pure white for content cards
  static const Color surfaceDark = Color(0xFF1E293B); // Dark slate for surfaces

  // Text colors with proper contrast for mobile readability
  static const Color textPrimaryLight =
      Color(0xFF1E293B); // Dark slate for primary text
  static const Color textPrimaryDark =
      Color(0xFFF1F5F9); // Light slate for dark mode
  static const Color textSecondaryLight =
      Color(0xFF64748B); // Medium gray for supporting text
  static const Color textSecondaryDark =
      Color(0xFF94A3B8); // Lighter gray for dark mode

  // Border and divider colors for minimal visual separation
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle gray for borders
  static const Color borderDark =
      Color(0xFF334155); // Medium slate for dark borders

  // Card and dialog colors for content containers
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white cards
  static const Color cardDark = Color(0xFF1E293B); // Dark slate cards

  // Shadow colors for subtle elevation
  static const Color shadowLight = Color(0x14000000); // 8% black shadow
  static const Color shadowDark = Color(0x1FFFFFFF); // 12% white shadow

  /// Light theme optimized for educational mobile applications
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryLight,
          onPrimary: Colors.white,
          primaryContainer: primaryLight.withValues(alpha: 0.1),
          onPrimaryContainer: primaryLight,
          secondary: secondaryLight,
          onSecondary: Colors.white,
          secondaryContainer: secondaryLight.withValues(alpha: 0.1),
          onSecondaryContainer: secondaryLight,
          tertiary: successLight,
          onTertiary: Colors.white,
          tertiaryContainer: successLight.withValues(alpha: 0.1),
          onTertiaryContainer: successLight,
          error: errorLight,
          onError: Colors.white,
          surface: surfaceLight,
          onSurface: textPrimaryLight,
          onSurfaceVariant: textSecondaryLight,
          outline: borderLight,
          outlineVariant: borderLight.withValues(alpha: 0.5),
          shadow: shadowLight,
          scrim: Colors.black.withValues(alpha: 0.5),
          inverseSurface: surfaceDark,
          onInverseSurface: textPrimaryDark,
          inversePrimary: primaryDark),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      dividerColor: borderLight,

      // AppBar theme for educational authority
      appBarTheme: AppBarTheme(
          backgroundColor: surfaceLight,
          foregroundColor: textPrimaryLight,
          elevation: 0,
          shadowColor: shadowLight,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryLight)),

      // Card theme with subtle elevation for content hierarchy
      cardTheme: CardThemeData(
          color: cardLight,
          elevation: 2.0,
          shadowColor: shadowLight,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),

      // Bottom navigation optimized for educational workflows
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primaryLight,
          unselectedItemColor: textSecondaryLight,
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),

      // Floating action button for contextual actions
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryLight,
          foregroundColor: Colors.white,
          elevation: 4.0,
          shape: CircleBorder()),

      // Button themes for educational interactions
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryLight,
              elevation: 2.0,
              shadowColor: shadowLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: primaryLight, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),

      // Typography theme using Inter for educational clarity
      textTheme: _buildTextTheme(isLight: true),

      // Input decoration optimized for learning forms
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceLight,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderLight, width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderLight, width: 1.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: primaryLight, width: 2.0)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: errorLight, width: 1.0)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: errorLight, width: 2.0)),
          labelStyle: GoogleFonts.inter(color: textSecondaryLight, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textSecondaryLight.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w400),
          errorStyle: GoogleFonts.inter(color: errorLight, fontSize: 12, fontWeight: FontWeight.w400)),

      // Interactive element themes
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey.shade400;
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.3);
        }
        return Colors.grey.shade300;
      })),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryLight;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: borderLight, width: 2.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return borderLight;
      })),

      // Progress indicators for learning progress
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryLight, linearTrackColor: borderLight, circularTrackColor: borderLight),
      sliderTheme: SliderThemeData(activeTrackColor: primaryLight, thumbColor: primaryLight, overlayColor: primaryLight.withValues(alpha: 0.2), inactiveTrackColor: borderLight, trackHeight: 4.0),

      // Tab bar theme for content navigation
      tabBarTheme: TabBarThemeData(labelColor: primaryLight, unselectedLabelColor: textSecondaryLight, indicatorColor: primaryLight, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),

      // Tooltip theme for educational hints
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: textPrimaryLight.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),

      // Snackbar theme for feedback messages
      snackBarTheme: SnackBarThemeData(backgroundColor: textPrimaryLight, contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: secondaryLight, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // Bottom sheet theme for contextual content
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surfaceLight, elevation: 8.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)))),
      dialogTheme: DialogThemeData(backgroundColor: surfaceLight));

  /// Dark theme optimized for educational mobile applications
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: Colors.black,
          primaryContainer: primaryDark.withValues(alpha: 0.2),
          onPrimaryContainer: primaryDark,
          secondary: secondaryDark,
          onSecondary: Colors.black,
          secondaryContainer: secondaryDark.withValues(alpha: 0.2),
          onSecondaryContainer: secondaryDark,
          tertiary: successDark,
          onTertiary: Colors.black,
          tertiaryContainer: successDark.withValues(alpha: 0.2),
          onTertiaryContainer: successDark,
          error: errorDark,
          onError: Colors.black,
          surface: surfaceDark,
          onSurface: textPrimaryDark,
          onSurfaceVariant: textSecondaryDark,
          outline: borderDark,
          outlineVariant: borderDark.withValues(alpha: 0.5),
          shadow: shadowDark,
          scrim: Colors.black.withValues(alpha: 0.7),
          inverseSurface: surfaceLight,
          onInverseSurface: textPrimaryLight,
          inversePrimary: primaryLight),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: borderDark,

      // AppBar theme for dark mode
      appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: textPrimaryDark,
          elevation: 0,
          shadowColor: shadowDark,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryDark)),

      // Card theme for dark mode
      cardTheme: CardThemeData(
          color: cardDark,
          elevation: 2.0,
          shadowColor: shadowDark,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),

      // Bottom navigation for dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: textSecondaryDark,
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),

      // Floating action button for dark mode
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryDark,
          foregroundColor: Colors.black,
          elevation: 4.0,
          shape: CircleBorder()),

      // Button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: primaryDark,
              elevation: 2.0,
              shadowColor: shadowDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: primaryDark, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),

      // Typography theme for dark mode
      textTheme: _buildTextTheme(isLight: false),

      // Input decoration for dark mode
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceDark,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderDark, width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderDark, width: 1.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: primaryDark, width: 2.0)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: errorDark, width: 1.0)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: errorDark, width: 2.0)),
          labelStyle: GoogleFonts.inter(color: textSecondaryDark, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textSecondaryDark.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w400),
          errorStyle: GoogleFonts.inter(color: errorDark, fontSize: 12, fontWeight: FontWeight.w400)),

      // Interactive elements for dark mode
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.grey.shade600;
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.3);
        }
        return Colors.grey.shade700;
      })),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryDark;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.black),
          side: const BorderSide(color: borderDark, width: 2.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return borderDark;
      })),

      // Progress indicators for dark mode
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryDark, linearTrackColor: borderDark, circularTrackColor: borderDark),
      sliderTheme: SliderThemeData(activeTrackColor: primaryDark, thumbColor: primaryDark, overlayColor: primaryDark.withValues(alpha: 0.2), inactiveTrackColor: borderDark, trackHeight: 4.0),

      // Tab bar theme for dark mode
      tabBarTheme: TabBarThemeData(labelColor: primaryDark, unselectedLabelColor: textSecondaryDark, indicatorColor: primaryDark, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),

      // Tooltip theme for dark mode
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: textPrimaryDark.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),

      // Snackbar theme for dark mode
      snackBarTheme: SnackBarThemeData(backgroundColor: textPrimaryDark, contentTextStyle: GoogleFonts.inter(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: secondaryDark, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // Bottom sheet theme for dark mode
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surfaceDark, elevation: 8.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)))),
      dialogTheme: DialogThemeData(backgroundColor: surfaceDark));

  /// Helper method to build text theme using Inter font family
  /// Optimized for educational content readability on mobile devices
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textSecondary =
        isLight ? textSecondaryLight : textSecondaryDark;

    return TextTheme(
        // Display styles for large headings
        displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.25,
            height: 1.12),
        displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 0,
            height: 1.16),
        displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0,
            height: 1.22),

        // Headline styles for section headers
        headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0,
            height: 1.25),
        headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0,
            height: 1.29),
        headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0,
            height: 1.33),

        // Title styles for card headers and important text
        titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0,
            height: 1.27),
        titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.15,
            height: 1.50),
        titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1,
            height: 1.43),

        // Body styles for main content
        bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: 0.5,
            height: 1.50),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: 0.25,
            height: 1.43),
        bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            letterSpacing: 0.4,
            height: 1.33),

        // Label styles for buttons and form elements
        labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1,
            height: 1.43),
        labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5,
            height: 1.33),
        labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5,
            height: 1.45));
  }

  /// Data text style using JetBrains Mono for numerical content
  /// Used for test scores, progress percentages, and precise data alignment
  static TextStyle dataTextStyle({
    required bool isLight,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    final Color textColor = isLight ? textPrimaryLight : textPrimaryDark;
    return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0,
        height: 1.4);
  }

  /// Box shadow for subtle elevation effects
  /// Applied to cards and floating elements with 2-8dp blur radius
  static List<BoxShadow> getElevationShadow({
    required bool isLight,
    double elevation = 2.0,
  }) {
    final Color shadowColor = isLight ? shadowLight : shadowDark;
    return [
      BoxShadow(
          color: shadowColor,
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
          spreadRadius: 0),
    ];
  }
}
