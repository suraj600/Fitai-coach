/// Demo data — Rohan, 22, Muscle Gain, MAS Gym, 4 weeks of past workouts.
library;

import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/nutrition.dart';
import '../utils/constants.dart';

class DemoData {
  static const _uuid = Uuid();

  /// Demo user: Rohan
  static UserProfile get demoUser => UserProfile(
        uid: 'demo_rohan_001',
        name: 'Rohan',
        age: 22,
        gender: Gender.male,
        heightCm: 175,
        weightKg: 72,
        bodyFatPercent: 18,
        primaryGoal: FitnessGoal.muscleGain,
        secondaryGoal: FitnessGoal.strength,
        experience: ExperienceLevel.intermediate,
        yearsTraining: 2,
        sessionDurationMinutes: 60,
        daysPerWeek: 5,
        equipment: Equipment.masGym,
        measurements: {
          'chest': 96,
          'shoulder': 115,
          'bicepsL': 34,
          'bicepsR': 35,
          'waist': 80,
          'hips': 95,
          'thighL': 56,
          'thighR': 57,
          'calf': 37,
        },
        injuries: [],
        dietType: DietType.nonVeg,
        dailyCalorieTarget: 2800,
        onboardingComplete: true,
      );

  /// Generate 4 weeks of past workout logs
  static List<WorkoutLog> generateWorkoutHistory(String userId) {
    final logs = <WorkoutLog>[];
    final now = DateTime.now();

    // Workout templates
    final pushExercises = [
      ExerciseLog(exerciseId: 'ch01', exerciseName: 'Barbell Bench Press', sets: [
        SetLog(setNumber: 1, weightKg: 60, reps: 8),
        SetLog(setNumber: 2, weightKg: 62.5, reps: 7),
        SetLog(setNumber: 3, weightKg: 62.5, reps: 6),
        SetLog(setNumber: 4, weightKg: 60, reps: 8),
      ], rpe: 8),
      ExerciseLog(exerciseId: 'ch04', exerciseName: 'Incline Dumbbell Press', sets: [
        SetLog(setNumber: 1, weightKg: 22, reps: 10),
        SetLog(setNumber: 2, weightKg: 24, reps: 8),
        SetLog(setNumber: 3, weightKg: 24, reps: 7),
      ], rpe: 7),
      ExerciseLog(exerciseId: 'sh01', exerciseName: 'Overhead Press', sets: [
        SetLog(setNumber: 1, weightKg: 40, reps: 8),
        SetLog(setNumber: 2, weightKg: 42.5, reps: 6),
        SetLog(setNumber: 3, weightKg: 40, reps: 8),
      ], rpe: 8),
      ExerciseLog(exerciseId: 'sh04', exerciseName: 'Cable Lateral Raise', sets: [
        SetLog(setNumber: 1, weightKg: 7.5, reps: 15),
        SetLog(setNumber: 2, weightKg: 7.5, reps: 14),
        SetLog(setNumber: 3, weightKg: 7.5, reps: 12),
      ], rpe: 7),
      ExerciseLog(exerciseId: 'tr01', exerciseName: 'Tricep Pushdown', sets: [
        SetLog(setNumber: 1, weightKg: 25, reps: 12),
        SetLog(setNumber: 2, weightKg: 27.5, reps: 10),
        SetLog(setNumber: 3, weightKg: 25, reps: 12),
      ], rpe: 7),
    ];

    final pullExercises = [
      ExerciseLog(exerciseId: 'bk01', exerciseName: 'Barbell Row', sets: [
        SetLog(setNumber: 1, weightKg: 60, reps: 8),
        SetLog(setNumber: 2, weightKg: 65, reps: 6),
        SetLog(setNumber: 3, weightKg: 60, reps: 8),
        SetLog(setNumber: 4, weightKg: 60, reps: 7),
      ], rpe: 8),
      ExerciseLog(exerciseId: 'bk02', exerciseName: 'Lat Pulldown', sets: [
        SetLog(setNumber: 1, weightKg: 50, reps: 10),
        SetLog(setNumber: 2, weightKg: 55, reps: 8),
        SetLog(setNumber: 3, weightKg: 50, reps: 10),
      ], rpe: 7),
      ExerciseLog(exerciseId: 'bk03', exerciseName: 'Seated Cable Row', sets: [
        SetLog(setNumber: 1, weightKg: 45, reps: 12),
        SetLog(setNumber: 2, weightKg: 50, reps: 10),
        SetLog(setNumber: 3, weightKg: 50, reps: 9),
      ], rpe: 7),
      ExerciseLog(exerciseId: 'bi01', exerciseName: 'Barbell Curl', sets: [
        SetLog(setNumber: 1, weightKg: 25, reps: 10),
        SetLog(setNumber: 2, weightKg: 27.5, reps: 8),
        SetLog(setNumber: 3, weightKg: 25, reps: 10),
      ], rpe: 7),
    ];

    final legExercises = [
      ExerciseLog(exerciseId: 'qu01', exerciseName: 'Barbell Squat', sets: [
        SetLog(setNumber: 1, weightKg: 80, reps: 8),
        SetLog(setNumber: 2, weightKg: 85, reps: 6),
        SetLog(setNumber: 3, weightKg: 80, reps: 7),
        SetLog(setNumber: 4, weightKg: 80, reps: 6),
      ], rpe: 9),
      ExerciseLog(exerciseId: 'hm01', exerciseName: 'Romanian Deadlift', sets: [
        SetLog(setNumber: 1, weightKg: 60, reps: 10),
        SetLog(setNumber: 2, weightKg: 65, reps: 8),
        SetLog(setNumber: 3, weightKg: 60, reps: 10),
      ], rpe: 7),
      ExerciseLog(exerciseId: 'qu03', exerciseName: 'Leg Press', sets: [
        SetLog(setNumber: 1, weightKg: 120, reps: 12),
        SetLog(setNumber: 2, weightKg: 140, reps: 10),
        SetLog(setNumber: 3, weightKg: 140, reps: 8),
      ], rpe: 8),
      ExerciseLog(exerciseId: 'cv01', exerciseName: 'Standing Calf Raise', sets: [
        SetLog(setNumber: 1, weightKg: 40, reps: 15),
        SetLog(setNumber: 2, weightKg: 45, reps: 12),
        SetLog(setNumber: 3, weightKg: 45, reps: 12),
        SetLog(setNumber: 4, weightKg: 40, reps: 15),
      ], rpe: 7),
    ];

    // Generate 4 weeks of PPL
    for (int week = 4; week >= 1; week--) {
      final weekOffset = week * 7;

      // Push
      final pushDate = now.subtract(Duration(days: weekOffset));
      final pushVolume = pushExercises.fold(0.0, (s, e) => s + e.totalVolume);
      logs.add(WorkoutLog(
        id: _uuid.v4(),
        userId: userId,
        workoutDayName: 'Push Day',
        date: pushDate,
        durationMinutes: 58 + (4 - week) * 2,
        totalVolume: pushVolume + (4 - week) * 50,
        exercises: pushExercises,
      ));

      // Pull
      final pullDate = now.subtract(Duration(days: weekOffset - 1));
      final pullVolume = pullExercises.fold(0.0, (s, e) => s + e.totalVolume);
      logs.add(WorkoutLog(
        id: _uuid.v4(),
        userId: userId,
        workoutDayName: 'Pull Day',
        date: pullDate,
        durationMinutes: 52 + (4 - week) * 2,
        totalVolume: pullVolume + (4 - week) * 40,
        exercises: pullExercises,
      ));

      // Legs
      final legDate = now.subtract(Duration(days: weekOffset - 2));
      final legVolume = legExercises.fold(0.0, (s, e) => s + e.totalVolume);
      logs.add(WorkoutLog(
        id: _uuid.v4(),
        userId: userId,
        workoutDayName: 'Leg Day',
        date: legDate,
        durationMinutes: 65 + (4 - week) * 3,
        totalVolume: legVolume + (4 - week) * 80,
        exercises: legExercises,
      ));

      // Push 2
      if (week <= 3) {
        final push2Date = now.subtract(Duration(days: weekOffset - 3));
        logs.add(WorkoutLog(
          id: _uuid.v4(),
          userId: userId,
          workoutDayName: 'Push Day',
          date: push2Date,
          durationMinutes: 55,
          totalVolume: pushVolume * 0.9 + (4 - week) * 30,
          exercises: pushExercises,
        ));
      }

      // Pull 2
      if (week <= 2) {
        final pull2Date = now.subtract(Duration(days: weekOffset - 4));
        logs.add(WorkoutLog(
          id: _uuid.v4(),
          userId: userId,
          workoutDayName: 'Pull Day',
          date: pull2Date,
          durationMinutes: 50,
          totalVolume: pullVolume * 0.85 + (4 - week) * 30,
          exercises: pullExercises,
        ));
      }
    }

    return logs;
  }

  /// Generate demo meal logs for today
  static List<MealLog> generateTodaysMeals(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      MealLog(
        id: _uuid.v4(),
        userId: userId,
        foodName: '4 Egg Whites + 2 Whole Eggs Omelette',
        calories: 320,
        proteinG: 32,
        carbsG: 4,
        fatG: 18,
        portionSize: '1 plate',
        mealType: 'breakfast',
        loggedAt: today.add(const Duration(hours: 8)),
      ),
      MealLog(
        id: _uuid.v4(),
        userId: userId,
        foodName: 'Chicken Breast with Brown Rice & Dal',
        calories: 580,
        proteinG: 48,
        carbsG: 62,
        fatG: 12,
        portionSize: '1 thali',
        mealType: 'lunch',
        loggedAt: today.add(const Duration(hours: 13)),
      ),
      MealLog(
        id: _uuid.v4(),
        userId: userId,
        foodName: 'Whey Protein Shake + Banana',
        calories: 280,
        proteinG: 30,
        carbsG: 32,
        fatG: 3,
        portionSize: '1 shake',
        mealType: 'snack',
        loggedAt: today.add(const Duration(hours: 16, minutes: 30)),
      ),
    ];
  }

  /// Generate weight history for progress graph (simulating 4 weeks of gains)
  static List<Map<String, dynamic>> generateWeightHistory() {
    final now = DateTime.now();
    return List.generate(28, (i) {
      final date = now.subtract(Duration(days: 28 - i));
      // Starting at 70kg, gaining ~0.07kg/day (about 0.5kg/week)
      final weight = 70.0 + (i * 0.07) + (i % 3 == 0 ? -0.2 : 0.1);
      return {'date': date, 'weight': double.parse(weight.toStringAsFixed(1))};
    });
  }
}
