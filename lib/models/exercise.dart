/// Exercise model — single exercise in the database.
library;

import '../utils/constants.dart';

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final List<Equipment> equipmentOptions;
  final String instructions;
  final String? videoUrl;
  final String difficulty; // beginner, intermediate, advanced
  final String category; // compound, isolation

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.equipmentOptions = const [Equipment.fullGym],
    required this.instructions,
    this.videoUrl,
    this.difficulty = 'intermediate',
    this.category = 'compound',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'primaryMuscle': primaryMuscle.name,
        'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
        'equipmentOptions': equipmentOptions.map((e) => e.name).toList(),
        'instructions': instructions,
        'videoUrl': videoUrl,
        'difficulty': difficulty,
        'category': category,
      };
}

/// A planned exercise within a workout day
class PlannedExercise {
  final Exercise exercise;
  final int sets;
  final int reps;
  final int restSeconds;
  final double targetRPE;
  final String? notes;

  const PlannedExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    this.restSeconds = 90,
    this.targetRPE = 8,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'exerciseId': exercise.id,
        'exerciseName': exercise.name,
        'primaryMuscle': exercise.primaryMuscle.name,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'targetRPE': targetRPE,
        'notes': notes,
      };
}
