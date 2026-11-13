/// Nutrition models — meal logs, calorie tracking.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class MealLog {
  final String id;
  final String userId;
  final String foodName;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String portionSize;
  final double confidenceScore; // 0-1 from AI
  final String? imageUrl;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime loggedAt;

  MealLog({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.portionSize = '1 serving',
    this.confidenceScore = 0.8,
    this.imageUrl,
    this.mealType = 'lunch',
    DateTime? loggedAt,
  }) : loggedAt = loggedAt ?? DateTime.now();

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId': userId,
        'foodName': foodName,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'portionSize': portionSize,
        'confidenceScore': confidenceScore,
        'imageUrl': imageUrl,
        'mealType': mealType,
        'loggedAt': Timestamp.fromDate(loggedAt),
      };

  factory MealLog.fromFirestore(Map<String, dynamic> data) {
    return MealLog(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      foodName: data['foodName'] ?? '',
      calories: data['calories'] ?? 0,
      proteinG: (data['proteinG'] ?? 0).toDouble(),
      carbsG: (data['carbsG'] ?? 0).toDouble(),
      fatG: (data['fatG'] ?? 0).toDouble(),
      portionSize: data['portionSize'] ?? '1 serving',
      confidenceScore: (data['confidenceScore'] ?? 0.8).toDouble(),
      imageUrl: data['imageUrl'],
      mealType: data['mealType'] ?? 'lunch',
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Daily nutrition summary
class DailyNutrition {
  final DateTime date;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int waterGlasses;
  final List<MealLog> meals;

  const DailyNutrition({
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.waterGlasses = 0,
    this.meals = const [],
  });

  factory DailyNutrition.fromMeals(DateTime date, List<MealLog> meals, {int water = 0}) {
    return DailyNutrition(
      date: date,
      totalCalories: meals.fold(0, (s, m) => s + m.calories),
      totalProtein: meals.fold(0.0, (s, m) => s + m.proteinG),
      totalCarbs: meals.fold(0.0, (s, m) => s + m.carbsG),
      totalFat: meals.fold(0.0, (s, m) => s + m.fatG),
      waterGlasses: water,
      meals: meals,
    );
  }
}
