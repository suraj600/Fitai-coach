/// Workout screen — weekly plan view + start session button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'workout_session_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    // Mock weekly plan
    final weekDays = [
      _DayPlan('Mon', 'Push Day', '6 exercises', 65, true),
      _DayPlan('Tue', 'Pull Day', '6 exercises', 60, false),
      _DayPlan('Wed', 'Leg Day', '6 exercises', 70, false),
      _DayPlan('Thu', 'Push Day', '5 exercises', 55, false),
      _DayPlan('Fri', 'Pull Day', '5 exercises', 55, false),
      _DayPlan('Sat', 'Rest', 'Recovery', 0, false),
      _DayPlan('Sun', 'Rest', 'Recovery', 0, false),
    ];

    // Current day's exercises (Push Day)
    final todayExercises = [
      _ExercisePlan('Barbell Bench Press', '4 × 8', '120s rest', 'RPE 8'),
      _ExercisePlan('Incline Dumbbell Press', '3 × 10', '90s rest', 'RPE 7'),
      _ExercisePlan('Overhead Press', '3 × 10', '90s rest', 'RPE 8'),
      _ExercisePlan('Cable Lateral Raise', '3 × 15', '60s rest', 'RPE 7'),
      _ExercisePlan('Tricep Pushdown', '3 × 12', '60s rest', 'RPE 7'),
      _ExercisePlan('Overhead Tricep Extension', '3 × 12', '60s rest', 'RPE 7'),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout Plan', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text('Push/Pull/Legs Split • Week 5',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),

              // Week overview
              Row(
                children: weekDays.map((day) {
                  final isToday = day.isToday;
                  final isRest = day.name == 'Rest';
                  return Expanded(
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
                          Text(day.day,
                              style: AppTextStyles.caption.copyWith(
                                color: isToday
                                    ? AppColors.accent
                                    : AppColors.textTertiary,
                              )),
                          const SizedBox(height: 4),
                          Icon(
                            isRest
                                ? Icons.bedtime
                                : Icons.fitness_center,
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Today's workout detail
              SectionHeader(
                title: "Today: Push Day",
                action: 'Swap exercises',
                onAction: () {},
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
                    _InfoChip(Icons.timer, '~65 min'),
                    _InfoChip(Icons.fitness_center, '6 exercises'),
                    _InfoChip(Icons.monitor_weight, '~8,400 kg vol'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Exercise list
              ...todayExercises.asMap().entries.map((entry) {
                final idx = entry.key;
                final ex = entry.value;
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
                            Text(ex.name,
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '${ex.setsReps} • ${ex.rest} • ${ex.rpe}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz,
                            color: AppColors.textTertiary, size: 20),
                        onPressed: () {
                          // Swap exercise
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Exercise swapped!')),
                          );
                        },
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
                      builder: (_) => const WorkoutSessionScreen(
                        workoutDayName: 'Push Day',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Progressive overload note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Progressive overload: You completed all bench sets last week. Try 62.5 kg today (+2.5%).',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.accent),
                      ),
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
}

class _DayPlan {
  final String day;
  final String name;
  final String subtitle;
  final int minutes;
  final bool isToday;
  const _DayPlan(this.day, this.name, this.subtitle, this.minutes, this.isToday);
}

class _ExercisePlan {
  final String name;
  final String setsReps;
  final String rest;
  final String rpe;
  const _ExercisePlan(this.name, this.setsReps, this.rest, this.rpe);
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
