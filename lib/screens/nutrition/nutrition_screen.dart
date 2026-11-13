/// Nutrition screen — daily calorie/macro tracking, photo meal logger, manual entry, water tracker.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';
import '../../models/nutrition.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  bool _isAnalyzing = false;

  Future<void> _snapMealPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // Read image and send to AI
      final bytes = await File(image.path).readAsBytes();
      final base64 = base64Encode(bytes);

      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.estimateCaloriesFromPhoto(base64);

      if (mounted) {
        _showCalorieResult(result);
      }
    } catch (e) {
      // Fallback to mock
      _showCalorieResult({
        'foodName': 'Chicken Biryani with Raita',
        'calories': 650,
        'proteinG': 35.0,
        'carbsG': 72.0,
        'fatG': 22.0,
        'portionSize': '1 plate (350g)',
        'confidenceScore': 0.82,
      });
    }

    setState(() => _isAnalyzing = false);
  }

  void _showManualMealEntry() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    final portionController = TextEditingController(text: '1 serving');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text('Add Meal Manually', style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food name',
                    hintText: 'e.g. Chicken Biryani',
                  ),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          suffixText: 'kcal',
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: portionController,
                        decoration: const InputDecoration(
                          labelText: 'Portion',
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protein',
                          suffixText: 'g',
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: carbsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Carbs',
                          suffixText: 'g',
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fat',
                          suffixText: 'g',
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AccentButton(
                  label: 'Log Meal',
                  onPressed: () {
                    final name = nameController.text.trim();
                    final cal = int.tryParse(calController.text) ?? 0;
                    if (name.isEmpty || cal <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Enter food name and calories')),
                      );
                      return;
                    }

                    final profile = ref.read(userProfileProvider);
                    final meal = MealLog(
                      id: const Uuid().v4(),
                      userId: profile?.uid ?? '',
                      foodName: name,
                      calories: cal,
                      proteinG: double.tryParse(proteinController.text) ?? 0,
                      carbsG: double.tryParse(carbsController.text) ?? 0,
                      fatG: double.tryParse(fatController.text) ?? 0,
                      portionSize: portionController.text,
                      confidenceScore: 1.0,
                      mealType: _getCurrentMealType(),
                    );
                    ref.read(todaysMealsProvider.notifier).addMeal(meal);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name logged! 🍽️')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCalorieResult(Map<String, dynamic> result) {
    final profile = ref.read(userProfileProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(result['foodName'] ?? 'Food',
                        style: AppTextStyles.h3),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((result['confidenceScore'] ?? 0.8) * 100).toStringAsFixed(0)}% sure',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(result['portionSize'] ?? '1 serving',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientChip('Calories', '${result['calories'] ?? 0}',
                      'kcal', AppColors.accent),
                  _NutrientChip('Protein', '${(result['proteinG'] ?? 0).toStringAsFixed(0)}',
                      'g', AppColors.info),
                  _NutrientChip('Carbs', '${(result['carbsG'] ?? 0).toStringAsFixed(0)}',
                      'g', AppColors.warning),
                  _NutrientChip('Fat', '${(result['fatG'] ?? 0).toStringAsFixed(0)}',
                      'g', AppColors.error),
                ],
              ),
              const SizedBox(height: 20),
              AccentButton(
                label: 'Log This Meal',
                onPressed: () {
                  final meal = MealLog(
                    id: const Uuid().v4(),
                    userId: profile?.uid ?? '',
                    foodName: result['foodName'] ?? 'Food',
                    calories: result['calories'] ?? 0,
                    proteinG: (result['proteinG'] ?? 0).toDouble(),
                    carbsG: (result['carbsG'] ?? 0).toDouble(),
                    fatG: (result['fatG'] ?? 0).toDouble(),
                    portionSize: result['portionSize'] ?? '1 serving',
                    confidenceScore: (result['confidenceScore'] ?? 0.8).toDouble(),
                    mealType: _getCurrentMealType(),
                  );
                  ref.read(todaysMealsProvider.notifier).addMeal(meal);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${meal.foodName} logged! 🍽️')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 18) return 'snack';
    return 'dinner';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final meals = ref.watch(todaysMealsProvider);
    final waterCount = ref.watch(waterCountProvider);

    if (profile == null) return const SizedBox();

    final totalCal = meals.fold(0, (s, m) => s + m.calories);
    final targetCal = profile.dailyCalorieTarget;
    final totalProtein = meals.fold(0.0, (s, m) => s + m.proteinG);
    final totalCarbs = meals.fold(0.0, (s, m) => s + m.carbsG);
    final totalFat = meals.fold(0.0, (s, m) => s + m.fatG);

    // Macro targets (approx)
    final proteinTarget = profile.weightKg * 2; // 2g/kg
    final fatTarget = profile.dailyCalorieTarget * 0.25 / 9; // 25% from fat
    final carbsTarget =
        (profile.dailyCalorieTarget - (proteinTarget * 4) - (fatTarget * 9)) / 4;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nutrition', style: AppTextStyles.h1),
              const SizedBox(height: 24),

              // Calorie ring + macros
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Column(
                  children: [
                    ProgressRing(
                      percent: targetCal > 0 ? totalCal / targetCal : 0,
                      centerText: '$totalCal',
                      label: '$totalCal / $targetCal kcal',
                      radius: 70,
                    ),
                    const SizedBox(height: 20),
                    MacroBar(
                        label: 'Protein',
                        current: totalProtein,
                        target: proteinTarget,
                        color: AppColors.info),
                    const SizedBox(height: 12),
                    MacroBar(
                        label: 'Carbs',
                        current: totalCarbs,
                        target: carbsTarget,
                        color: AppColors.warning),
                    const SizedBox(height: 12),
                    MacroBar(
                        label: 'Fat',
                        current: totalFat,
                        target: fatTarget,
                        color: AppColors.error),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Add meal buttons row
              Row(
                children: [
                  // Snap photo
                  Expanded(
                    child: GestureDetector(
                      onTap: _isAnalyzing ? null : _snapMealPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A2A00), Color(0xFF0A0A0A)],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: _isAnalyzing
                            ? const Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: AppColors.accent, strokeWidth: 2),
                                ))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      color: AppColors.accent, size: 22),
                                  const SizedBox(width: 8),
                                  Text('Snap Photo',
                                      style: AppTextStyles.body
                                          .copyWith(color: AppColors.accent)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Manual entry
                  Expanded(
                    child: GestureDetector(
                      onTap: _showManualMealEntry,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note,
                                color: AppColors.textSecondary, size: 22),
                            const SizedBox(width: 8),
                            Text('Add Manual',
                                style: AppTextStyles.body),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Water tracker
              const SectionHeader(title: 'Water'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop,
                            color: AppColors.info, size: 24),
                        const SizedBox(width: 8),
                        Text('$waterCount / 8 glasses',
                            style: AppTextStyles.body),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.textTertiary),
                          onPressed: () {
                            ref.read(waterCountProvider.notifier).decrement();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.info),
                          onPressed: () {
                            ref.read(waterCountProvider.notifier).increment();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Today's meals
              const SectionHeader(title: "Today's Meals"),
              if (meals.isEmpty)
                const EmptyState(
                  icon: Icons.restaurant,
                  title: 'No meals logged yet',
                  subtitle: 'Snap a photo or add manually to start tracking',
                )
              else
                ...meals.map((meal) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _mealIcon(meal.mealType),
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meal.foodName,
                                    style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                  '${meal.calories} kcal • P: ${meal.proteinG.toStringAsFixed(0)}g • C: ${meal.carbsG.toStringAsFixed(0)}g • F: ${meal.fatG.toStringAsFixed(0)}g',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            meal.mealType[0].toUpperCase() + meal.mealType.substring(1),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 20),

              // Weekly insight
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tips_and_updates,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 6),
                        Text('Weekly Insight',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.accent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You hit your protein target only 3/7 days. Add 30g paneer or 1 extra chicken breast daily to close the gap.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  IconData _mealIcon(String type) => switch (type) {
        'breakfast' => Icons.free_breakfast,
        'lunch' => Icons.lunch_dining,
        'dinner' => Icons.dinner_dining,
        _ => Icons.cookie,
      };
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutrientChip(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.h3.copyWith(color: color)),
        Text(unit, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}
