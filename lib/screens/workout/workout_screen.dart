/// Workout screen — weekly plan view + start session button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../../data/exercise_database.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'workout_session_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final plan = ref.watch(activeWorkoutPlanProvider);
    final isGenerating = ref.watch(isGeneratingPlanProvider);

    if (profile == null) return const SizedBox();

    // If no plan exists, show generate button
    if (plan == null) {
      return _NoPlanView(isGenerating: isGenerating);
    }

    // Determine today's workout
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    final todayDay = plan.days.length > todayIndex
        ? plan.days[todayIndex]
        : plan.days.first;
    final isRestDay = todayDay.name.toLowerCase().contains('rest');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout Plan', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text('${plan.splitType} Split • Week ${plan.weekNumber}',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),

              // Week overview
              Row(
                children: List.generate(plan.days.length, (i) {
                  final day = plan.days[i];
                  final isToday = i == todayIndex;
                  final isRest = day.name.toLowerCase().contains('rest');
                  final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final label = i < dayLabels.length ? dayLabels[i] : '${i + 1}';

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _showDayDetail(context, ref, plan, i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.accentSubtle
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          border: isToday
                              ? Border.all(color: AppColors.accent)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(label,
                                style: AppTextStyles.caption.copyWith(
                                  color: isToday
                                      ? AppColors.accent
                                      : AppColors.textTertiary,
                                )),
                            const SizedBox(height: 4),
                            Icon(
                              isRest ? Icons.bedtime : Icons.fitness_center,
                              size: 16,
                              color: isToday
                                  ? AppColors.accent
                                  : isRest
                                      ? AppColors.textTertiary
                                      : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              if (isRestDay) ...[
                // Rest day
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.bedtime,
                          size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text('Rest Day', style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text('Recovery is when muscles grow. Stay active with light walking or stretching.',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ] else ...[
                // Today's workout detail
                SectionHeader(
                  title: 'Today: ${todayDay.name}',
                  action: 'Regenerate',
                  onAction: () => _regeneratePlan(context, ref),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoChip(Icons.timer, '~${todayDay.estimatedMinutes} min'),
                      _InfoChip(Icons.fitness_center, '${todayDay.exercises.length} exercises'),
                      _InfoChip(Icons.monitor_weight,
                          '~${todayDay.estimatedVolume.toStringAsFixed(0)} kg vol'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Exercise list
                ...todayDay.exercises.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final planned = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(planned.exercise.name,
                                  style: AppTextStyles.body
                                      .copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                '${planned.sets} × ${planned.reps} • ${planned.restSeconds}s rest • RPE ${planned.targetRPE.toStringAsFixed(0)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz,
                              color: AppColors.textTertiary, size: 20),
                          onPressed: () => _swapExercise(
                              context, ref, plan, todayIndex, idx, planned),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Start Workout button
                AccentButton(
                  label: 'Start Workout',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutSessionScreen(
                          workoutDayName: todayDay.name,
                          plannedExercises: todayDay.exercises,
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _swapExercise(BuildContext context, WidgetRef ref,
      WorkoutPlan plan, int dayIndex, int exerciseIndex, PlannedExercise current) {
    final alternative = ExerciseDatabase.getSwapAlternative(current.exercise);
    if (alternative == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No alternative found for this exercise')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: const Text('Swap Exercise', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Replace:', style: AppTextStyles.caption),
            Text(current.exercise.name,
                style: AppTextStyles.body.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('With:', style: AppTextStyles.caption),
            Text(alternative.name,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.accent)),
            const SizedBox(height: 4),
            Text('${alternative.primaryMuscle.label} • ${alternative.category} • ${alternative.difficulty}',
                style: AppTextStyles.caption),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPlanned = PlannedExercise(
                exercise: alternative,
                sets: current.sets,
                reps: current.reps,
                restSeconds: current.restSeconds,
                targetRPE: current.targetRPE,
              );
              ref.read(activeWorkoutPlanProvider.notifier)
                  .swapExercise(dayIndex, exerciseIndex, newPlanned);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Swapped to ${alternative.name}')),
              );
            },
            child: const Text('Swap'),
          ),
        ],
      ),
    );
  }

  void _showDayDetail(BuildContext context, WidgetRef ref, WorkoutPlan plan, int dayIndex) {
    // Tapping a day in the week bar scrolls to / shows that day's info
    // For simplicity, show a bottom sheet with that day's exercises
    if (dayIndex >= plan.days.length) return;
    final day = plan.days[dayIndex];
    final isRest = day.name.toLowerCase().contains('rest');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.name, style: AppTextStyles.h2),
            const SizedBox(height: 4),
            if (isRest)
              Text('Rest & recovery day', style: AppTextStyles.bodySmall)
            else ...[
              Text('${day.exercises.length} exercises • ~${day.estimatedMinutes} min',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              ...day.exercises.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• ${e.exercise.name} — ${e.sets}×${e.reps}',
                        style: AppTextStyles.body),
                  )),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _regeneratePlan(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Use the AI Coach to generate a new plan')),
    );
    ref.read(currentTabProvider.notifier).state = 4; // Switch to Coach tab
  }
}

/// Shown when no workout plan has been generated yet
class _NoPlanView extends ConsumerWidget {
  final bool isGenerating;
  const _NoPlanView({required this.isGenerating});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout Plan', style: AppTextStyles.h1),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center,
                        size: 64, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text('No workout plan yet',
                        style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      'Ask the AI Coach to generate your personalized workout plan based on your profile.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (isGenerating)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 12),
                          Text('Generating your plan...',
                              style: AppTextStyles.bodySmall),
                        ],
                      )
                    else
                      AccentButton(
                        label: 'Ask AI Coach',
                        icon: Icons.smart_toy_rounded,
                        onPressed: () {
                          // Navigate to Coach tab
                          ref.read(currentTabProvider.notifier).state = 4;
                        },
                      ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
