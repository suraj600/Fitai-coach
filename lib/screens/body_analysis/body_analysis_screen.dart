/// Body Analysis — interactive muscle map with gap analysis.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class BodyAnalysisScreen extends ConsumerWidget {
  const BodyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock muscle scores (in production, from AI analysis)
    final muscleScores = {
      'Chest': {'score': 68, 'status': MuscleStatus.average},
      'Back': {'score': 42, 'status': MuscleStatus.lagging},
      'Shoulders': {'score': 72, 'status': MuscleStatus.average},
      'Biceps': {'score': 55, 'status': MuscleStatus.average},
      'Triceps': {'score': 60, 'status': MuscleStatus.average},
      'Quads': {'score': 50, 'status': MuscleStatus.lagging},
      'Hamstrings': {'score': 45, 'status': MuscleStatus.lagging},
      'Glutes': {'score': 48, 'status': MuscleStatus.lagging},
      'Calves': {'score': 35, 'status': MuscleStatus.lagging},
      'Abs': {'score': 58, 'status': MuscleStatus.average},
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Body Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall score
            Center(
              child: Column(
                children: [
                  ProgressRing(
                    percent: 0.53,
                    centerText: '53',
                    label: 'Muscle Balance Score',
                    radius: 70,
                  ),
                  const SizedBox(height: 8),
                  Text('3 muscle groups need attention',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Body map (simplified visual)
            Center(
              child: Container(
                width: 200,
                height: 400,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Body silhouette icon
                    Icon(Icons.accessibility_new,
                        size: 200, color: AppColors.surfaceLight),
                    // Overlay color indicators
                    Positioned(
                      top: 80,
                      child: _MuscleIndicator(
                          label: 'Shoulders', color: AppColors.muscleAverage),
                    ),
                    Positioned(
                      top: 120,
                      child: _MuscleIndicator(
                          label: 'Chest', color: AppColors.muscleAverage),
                    ),
                    Positioned(
                      top: 120,
                      right: 20,
                      child: _MuscleIndicator(
                          label: 'Back', color: AppColors.muscleLagging),
                    ),
                    Positioned(
                      top: 170,
                      left: 20,
                      child: _MuscleIndicator(
                          label: 'Arms', color: AppColors.muscleAverage),
                    ),
                    Positioned(
                      top: 200,
                      child: _MuscleIndicator(
                          label: 'Abs', color: AppColors.muscleAverage),
                    ),
                    Positioned(
                      top: 270,
                      child: _MuscleIndicator(
                          label: 'Legs', color: AppColors.muscleLagging),
                    ),
                    Positioned(
                      bottom: 50,
                      child: _MuscleIndicator(
                          label: 'Calves', color: AppColors.muscleLagging),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: AppColors.muscleDeveloped, label: 'Developed'),
                const SizedBox(width: 16),
                _LegendItem(color: AppColors.muscleAverage, label: 'Average'),
                const SizedBox(width: 16),
                _LegendItem(color: AppColors.muscleLagging, label: 'Lagging'),
              ],
            ),
            const SizedBox(height: 32),

            // Muscle breakdown
            const SectionHeader(title: 'Muscle Breakdown'),
            ...muscleScores.entries.map((entry) {
              final score = entry.value['score'] as int;
              final status = entry.value['status'] as MuscleStatus;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(
                          color: status.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key,
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text('$score% developed • ${status.label}',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            backgroundColor: AppColors.surfaceLight,
                            color: status.color,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // AI Recommendations
            const SectionHeader(title: 'AI Recommendations'),
            ...[
              'Your Back is 42% developed — needs +30% volume. Add Lat Pulldown and Rows 2x per week.',
              'Your Legs are lagging — increase squat frequency to 2x per week.',
              'Calves are your weakest area at 35%. Add standing and seated calf raises 3x/week.',
              'Chest is 68% — on track. Maintain current volume.',
            ].map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rec, style: AppTextStyles.bodySmall)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _MuscleIndicator extends StatelessWidget {
  final String label;
  final Color color;

  const _MuscleIndicator({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
