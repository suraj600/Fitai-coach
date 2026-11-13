/// Progress dashboard — Strength charts, Body graphs, Consistency heatmap, AI insights.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Text('Progress', style: AppTextStyles.h1),
            ),
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Strength'),
                  Tab(text: 'Body'),
                  Tab(text: 'Consistency'),
                  Tab(text: 'AI'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _StrengthTab(),
                  _BodyTab(),
                  _ConsistencyTab(),
                  _AIInsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ─── Strength Tab ───
class _StrengthTab extends ConsumerWidget {
  const _StrengthTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);

    // Extract bench press volume over time
    final benchData = <FlSpot>[];
    final squatData = <FlSpot>[];
    final deadliftData = <FlSpot>[];

    for (int i = 0; i < logs.length; i++) {
      for (final ex in logs[i].exercises) {
        final name = ex.exerciseName.toLowerCase();
        final bestWeight = ex.sets.isEmpty
            ? 0.0
            : ex.sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);

        if (name.contains('bench press') && !name.contains('incline')) {
          benchData.add(FlSpot(i.toDouble(), bestWeight));
        } else if (name.contains('squat') && !name.contains('bulgarian')) {
          squatData.add(FlSpot(i.toDouble(), bestWeight));
        } else if (name.contains('deadlift') && !name.contains('romanian')) {
          deadliftData.add(FlSpot(i.toDouble(), bestWeight));
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Big 3 Lifts Over Time'),
          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: (benchData.isEmpty && squatData.isEmpty && deadliftData.isEmpty)
                ? const EmptyState(
                    icon: Icons.show_chart,
                    title: 'No data yet',
                    subtitle: 'Complete workouts to see strength trends',
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: AppColors.divider,
                          strokeWidth: 0.5,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}kg',
                              style: const TextStyle(
                                  color: AppColors.textTertiary, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        if (benchData.isNotEmpty)
                          _lineBar(benchData, AppColors.accent),
                        if (squatData.isNotEmpty)
                          _lineBar(squatData, AppColors.info),
                        if (deadliftData.isNotEmpty)
                          _lineBar(deadliftData, AppColors.warning),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot('Bench', AppColors.accent),
              const SizedBox(width: 16),
              _LegendDot('Squat', AppColors.info),
              const SizedBox(width: 16),
              _LegendDot('Deadlift', AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),

          // Volume load trend
          const SectionHeader(title: 'Total Volume per Session'),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: logs.isEmpty
                ? const EmptyState(
                    icon: Icons.bar_chart,
                    title: 'No data yet',
                    subtitle: 'Log workouts to track volume',
                  )
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2000,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: AppColors.divider,
                          strokeWidth: 0.5,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(
                              '${(v / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(
                                  color: AppColors.textTertiary, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: logs.asMap().entries.map((e) {
                        final vol = e.value.totalVolume;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: vol,
                              color: AppColors.accent.withValues(alpha: 0.7),
                              width: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  LineChartBarData _lineBar(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }
}

// ─── Body Tab ───
class _BodyTab extends ConsumerWidget {
  const _BodyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final logs = ref.watch(workoutLogsProvider);

    // Weight trend from demo data
    final weightSpots = <FlSpot>[];
    for (int i = 0; i < 28; i++) {
      weightSpots.add(FlSpot(i.toDouble(), 70.5 + (i * 0.06)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Weight Trend'),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toStringAsFixed(1)}',
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (v, _) => Text(
                        'W${(v / 7).toInt() + 1}',
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 70,
                maxY: 73,
                lineBarsData: [
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accent.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '+1.7 kg over 4 weeks (0.42 kg/week)',
              style: AppTextStyles.caption.copyWith(color: AppColors.success),
            ),
          ),
          const SizedBox(height: 24),

          // Body stats
          const SectionHeader(title: 'Current Stats'),
          if (profile != null)
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Weight',
                    value: '${profile.weightKg} kg',
                    icon: Icons.monitor_weight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Height',
                    value: '${profile.heightCm} cm',
                    icon: Icons.height,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'BMI',
                  value: profile != null
                      ? (profile.weightKg /
                              ((profile.heightCm / 100) *
                                  (profile.heightCm / 100)))
                          .toStringAsFixed(1)
                      : '-',
                  icon: Icons.speed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Workouts',
                  value: '${logs.length}',
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── Consistency Tab ───
class _ConsistencyTab extends ConsumerWidget {
  const _ConsistencyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);

    // Build heatmap data for last 12 weeks
    final now = DateTime.now();
    final weeks = 12;
    final startDate = now.subtract(Duration(days: weeks * 7));

    // Count workouts per day
    final workoutDays = <String>{};
    for (final log in logs) {
      workoutDays.add(
          '${log.date.year}-${log.date.month}-${log.date.day}');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Workout Heatmap (12 weeks)'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              children: [
                // Day labels
                Row(
                  children: [
                    const SizedBox(width: 30),
                    ...['M', 'T', 'W', 'T', 'F', 'S', 'S'].map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Grid
                ...List.generate(weeks, (weekIdx) {
                  final weekStart =
                      startDate.add(Duration(days: weekIdx * 7));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            'W${weekIdx + 1}',
                            style: AppTextStyles.caption
                                .copyWith(fontSize: 9),
                          ),
                        ),
                        ...List.generate(7, (dayIdx) {
                          final date =
                              weekStart.add(Duration(days: dayIdx));
                          final key =
                              '${date.year}-${date.month}-${date.day}';
                          final hasWorkout = workoutDays.contains(key);
                          final isFuture = date.isAfter(now);

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(1.5),
                              height: 20,
                              decoration: BoxDecoration(
                                color: isFuture
                                    ? AppColors.surfaceLight
                                        .withValues(alpha: 0.3)
                                    : hasWorkout
                                        ? AppColors.accent
                                        : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot('Workout day', AppColors.accent),
              const SizedBox(width: 16),
              _LegendDot('Rest day', AppColors.surfaceLight),
            ],
          ),
          const SizedBox(height: 24),

          // Streak info
          const SectionHeader(title: 'Streak & Stats'),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Current Streak',
                  value: '${ref.watch(workoutLogsProvider.notifier).currentStreak} days',
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'This Month',
                  value: '${ref.watch(workoutLogsProvider.notifier).thisMonthCount}',
                  icon: Icons.calendar_month,
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── AI Insights Tab ───
class _AIInsightsTab extends ConsumerWidget {
  const _AIInsightsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = [
      {
        'icon': Icons.trending_up,
        'color': AppColors.success,
        'title': 'Bench Press Plateau',
        'body':
            'Your bench press has been at 60kg for 2 weeks. Try a deload week at 50kg, then push to 62.5kg with 3×4 instead of 3×8.',
      },
      {
        'icon': Icons.warning_amber,
        'color': AppColors.warning,
        'title': 'Leg Volume Imbalance',
        'body':
            'You\'re doing 2× more quad volume than hamstring. Add 2 sets of Romanian deadlifts to your leg day to balance this.',
      },
      {
        'icon': Icons.restaurant,
        'color': AppColors.info,
        'title': 'Protein Timing',
        'body':
            'You\'re hitting 140g protein but most comes at dinner. Spread it across 4 meals (35g each) for better muscle protein synthesis.',
      },
      {
        'icon': Icons.nights_stay,
        'color': AppColors.error,
        'title': 'Recovery Alert',
        'body':
            'You trained 6 days in a row last week. Your volume per session dropped 15% by day 5. Take at least 1 rest day between every 3 training days.',
      },
      {
        'icon': Icons.emoji_events,
        'color': AppColors.accent,
        'title': 'Milestone Approaching',
        'body':
            'Your squat is at 80kg — you\'re 5kg away from a bodyweight squat! At your current rate, you\'ll hit it in ~2 weeks.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'AI-Powered Insights'),
          ...insights.map((insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: (insight['color'] as Color).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(insight['icon'] as IconData,
                            color: insight['color'] as Color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(insight['title'] as String,
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(insight['body'] as String,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── Helper widgets ───
class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}
