/// Home screen — today's overview, quick actions, AI insight card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../body_analysis/body_analysis_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final logs = ref.watch(workoutLogsProvider);
    final meals = ref.watch(todaysMealsProvider);

    if (profile == null) return const SizedBox();

    final todayCalories = meals.fold(0, (s, m) => s + m.calories);
    final lastWorkout = logs.isNotEmpty ? logs.first : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey ${profile.name} 💪',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.primaryGoal.label} • ${profile.equipment.label}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.accentSubtle,
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0] : 'U',
                        style: AppTextStyles.h3.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick stats row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: ref.read(workoutLogsProvider.notifier).currentStreak.toString(),
                      label: 'Day Streak',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '$todayCalories',
                      label: 'kcal today',
                      icon: Icons.restaurant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: ref.read(workoutLogsProvider.notifier).thisMonthCount.toString(),
                      label: 'This month',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Workout card
              const SectionHeader(title: "Today's Plan"),
              GestureDetector(
                onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A2A00), Color(0xFF0A0A0A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fitness_center,
                              color: AppColors.accent, size: 24),
                          const SizedBox(width: 8),
                          Text('Push Day', style: AppTextStyles.h3),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentSubtle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('~60 min',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.accent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '6 exercises • Bench Press, Incline DB, OHP, Lateral Raise, Tricep Pushdown, OH Extension',
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      const AccentButton(label: 'Start Workout', expanded: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Insight Card
              const SectionHeader(title: 'AI Insight'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy,
                            color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text('Weekly Analysis',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.accent)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your chest volume stalled for 2 weeks. I suggest increasing chest sets from 10 to 14 next week. Your back improved +8% — great work on those rows! 📈',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => ref.read(currentTabProvider.notifier).state = 4,
                      child: Text(
                        'Ask Coach for details →',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Body Analysis shortcut
              const SectionHeader(title: 'Body Analysis'),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BodyAnalysisScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtle,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: const Icon(Icons.accessibility_new,
                            color: AppColors.accent, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Muscle Balance Score',
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text('53/100 — 3 areas need work',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Last workout summary
              if (lastWorkout != null) ...[
                const SectionHeader(title: 'Last Workout'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lastWorkout.workoutDayName,
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              '${lastWorkout.durationMinutes} min • ${lastWorkout.totalVolume.toStringAsFixed(0)} kg volume',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+5%',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 100), // space for FAB
            ],
          ),
        ),
      ),
    );
  }
}
