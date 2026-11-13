/// App-wide constants for FitAI Coach
library;

import 'package:flutter/material.dart';

// ─── Brand Colors ───────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF1A1A1A);
  static const Color cardHover = Color(0xFF222222);
  static const Color accent = Color(0xFFC8FF00);
  static const Color accentDark = Color(0xFF9ACC00);
  static const Color accentSubtle = Color(0x33C8FF00);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF4DFF91);
  static const Color warning = Color(0xFFFFB84D);
  static const Color info = Color(0xFF4DB8FF);

  // Muscle map colors
  static const Color muscleDeveloped = Color(0xFF4DFF91);
  static const Color muscleAverage = Color(0xFFFFB84D);
  static const Color muscleLagging = Color(0xFFFF4D4D);
}

// ─── Text Styles ────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.background,
    letterSpacing: 0.5,
  );

  static const TextStyle stat = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.accent,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 1.2,
  );
}

// ─── Spacing & Sizing ───────────────────────────────────────────────────────
class AppSizes {
  AppSizes._();

  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 100;

  static const double iconS = 20;
  static const double iconM = 24;
  static const double iconL = 32;

  static const double bottomNavHeight = 80;
  static const double fabSize = 56;
}

// ─── Gemini API ─────────────────────────────────────────────────────────────
class ApiConfig {
  ApiConfig._();

  /// API key loaded from --dart-define at build time.
  /// Build with: flutter run --dart-define=GEMINI_API_KEY=your_key_here
  /// NEVER hardcode the key in source code.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static bool get hasApiKey => geminiApiKey.isNotEmpty;

  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.0-flash';
  static const String geminiVisionModel = 'gemini-2.0-flash';
}

// ─── Enums ──────────────────────────────────────────────────────────────────
enum FitnessGoal {
  fatLoss('Fat Loss', Icons.local_fire_department),
  muscleGain('Muscle Gain', Icons.fitness_center),
  strength('Strength', Icons.bolt),
  athletic('Athletic Performance', Icons.sports_martial_arts),
  generalFitness('General Fitness', Icons.favorite);

  const FitnessGoal(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum ExperienceLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const ExperienceLevel(this.label);
  final String label;
}

enum Equipment {
  homeNone('Home - No Equipment'),
  homeDumbbells('Home - Dumbbells'),
  fullGym('Full Gym'),
  masGym('MAS Gym');

  const Equipment(this.label);
  final String label;
}

enum DietType {
  nonVeg('Non-Veg'),
  veg('Vegetarian'),
  vegan('Vegan'),
  jain('Jain'),
  keto('Keto');

  const DietType(this.label);
  final String label;
}

enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Forearms'),
  quads('Quadriceps'),
  hamstrings('Hamstrings'),
  glutes('Glutes'),
  calves('Calves'),
  abs('Abs'),
  traps('Traps'),
  lats('Lats');

  const MuscleGroup(this.label);
  final String label;
}

enum MuscleStatus {
  developed('Developed', AppColors.muscleDeveloped),
  average('Average', AppColors.muscleAverage),
  lagging('Lagging', AppColors.muscleLagging);

  const MuscleStatus(this.label, this.color);
  final String label;
  final Color color;
}

enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.label);
  final String label;
}
