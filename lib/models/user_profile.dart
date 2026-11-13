/// User profile model — stores onboarding data and body measurements.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserProfile {
  final String uid;
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final double? bodyFatPercent;

  // Goals
  final FitnessGoal primaryGoal;
  final FitnessGoal? secondaryGoal;

  // Experience
  final ExperienceLevel experience;
  final int yearsTraining;

  // Availability
  final int sessionDurationMinutes; // 30, 45, 60, 90
  final int daysPerWeek; // 3-6
  final Equipment equipment;

  // Body Measurements (cm)
  final Map<String, double> measurements; // chest, shoulder, bicepsL, bicepsR, waist, hips, thighL, thighR, calf

  // Health & Diet
  final List<String> injuries;
  final DietType dietType;
  final int dailyCalorieTarget;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool onboardingComplete;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.bodyFatPercent,
    required this.primaryGoal,
    this.secondaryGoal,
    required this.experience,
    this.yearsTraining = 0,
    this.sessionDurationMinutes = 60,
    this.daysPerWeek = 4,
    this.equipment = Equipment.fullGym,
    this.measurements = const {},
    this.injuries = const [],
    this.dietType = DietType.nonVeg,
    this.dailyCalorieTarget = 2200,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.onboardingComplete = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate TDEE-based calorie target
  static int calculateCalories({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int age,
    required FitnessGoal goal,
    required int daysPerWeek,
  }) {
    // Mifflin-St Jeor BMR
    double bmr;
    if (gender == Gender.male) {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    // Activity multiplier
    double multiplier = switch (daysPerWeek) {
      3 => 1.375,
      4 => 1.55,
      5 => 1.725,
      _ => 1.9,
    };

    double tdee = bmr * multiplier;

    // Goal adjustment
    return switch (goal) {
      FitnessGoal.fatLoss => (tdee - 500).round(),
      FitnessGoal.muscleGain => (tdee + 300).round(),
      FitnessGoal.strength => (tdee + 200).round(),
      _ => tdee.round(),
    };
  }

  /// Ideal measurement ratios for muscle balance scoring
  Map<String, double> get idealRatios {
    final h = heightCm;
    if (gender == Gender.female) {
      return {
        'chest': h * 0.53,
        'shoulder': h * 0.61,
        'biceps': h * 0.18,
        'waist': h * 0.38,
        'hips': h * 0.56,
        'thigh': h * 0.34,
        'calf': h * 0.21,
      };
    }
    return {
      'chest': h * 0.62,
      'shoulder': h * 0.72,
      'biceps': h * 0.22,
      'waist': h * 0.44,
      'hips': h * 0.53,
      'thigh': h * 0.34,
      'calf': h * 0.235,
    };
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'name': name,
        'age': age,
        'gender': gender.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bodyFatPercent': bodyFatPercent,
        'primaryGoal': primaryGoal.name,
        'secondaryGoal': secondaryGoal?.name,
        'experience': experience.name,
        'yearsTraining': yearsTraining,
        'sessionDurationMinutes': sessionDurationMinutes,
        'daysPerWeek': daysPerWeek,
        'equipment': equipment.name,
        'measurements': measurements,
        'injuries': injuries,
        'dietType': dietType.name,
        'dailyCalorieTarget': dailyCalorieTarget,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'onboardingComplete': onboardingComplete,
      };

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 25,
      gender: Gender.values.firstWhere(
        (g) => g.name == data['gender'],
        orElse: () => Gender.male,
      ),
      heightCm: (data['heightCm'] ?? 170).toDouble(),
      weightKg: (data['weightKg'] ?? 70).toDouble(),
      bodyFatPercent: data['bodyFatPercent']?.toDouble(),
      primaryGoal: FitnessGoal.values.firstWhere(
        (g) => g.name == data['primaryGoal'],
        orElse: () => FitnessGoal.generalFitness,
      ),
      secondaryGoal: data['secondaryGoal'] != null
          ? FitnessGoal.values.firstWhere(
              (g) => g.name == data['secondaryGoal'],
              orElse: () => FitnessGoal.generalFitness,
            )
          : null,
      experience: ExperienceLevel.values.firstWhere(
        (e) => e.name == data['experience'],
        orElse: () => ExperienceLevel.beginner,
      ),
      yearsTraining: data['yearsTraining'] ?? 0,
      sessionDurationMinutes: data['sessionDurationMinutes'] ?? 60,
      daysPerWeek: data['daysPerWeek'] ?? 4,
      equipment: Equipment.values.firstWhere(
        (e) => e.name == data['equipment'],
        orElse: () => Equipment.fullGym,
      ),
      measurements: Map<String, double>.from(
        (data['measurements'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      injuries: List<String>.from(data['injuries'] ?? []),
      dietType: DietType.values.firstWhere(
        (d) => d.name == data['dietType'],
        orElse: () => DietType.nonVeg,
      ),
      dailyCalorieTarget: data['dailyCalorieTarget'] ?? 2200,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      onboardingComplete: data['onboardingComplete'] ?? false,
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    double? bodyFatPercent,
    FitnessGoal? primaryGoal,
    FitnessGoal? secondaryGoal,
    ExperienceLevel? experience,
    int? yearsTraining,
    int? sessionDurationMinutes,
    int? daysPerWeek,
    Equipment? equipment,
    Map<String, double>? measurements,
    List<String>? injuries,
    DietType? dietType,
    int? dailyCalorieTarget,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      secondaryGoal: secondaryGoal ?? this.secondaryGoal,
      experience: experience ?? this.experience,
      yearsTraining: yearsTraining ?? this.yearsTraining,
      sessionDurationMinutes: sessionDurationMinutes ?? this.sessionDurationMinutes,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      equipment: equipment ?? this.equipment,
      measurements: measurements ?? this.measurements,
      injuries: injuries ?? this.injuries,
      dietType: dietType ?? this.dietType,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      createdAt: createdAt,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
