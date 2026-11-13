/// App shell — bottom navigation + floating AI Coach button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/providers.dart';
import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'progress/progress_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'coach/coach_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    WorkoutScreen(),
    ProgressScreen(),
    NutritionScreen(),
    CoachScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentTab == 0,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 0,
                ),
                _NavItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workout',
                  isActive: currentTab == 1,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                ),
                _NavItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Progress',
                  isActive: currentTab == 2,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
                _NavItem(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrition',
                  isActive: currentTab == 3,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 3,
                ),
                _NavItem(
                  icon: Icons.smart_toy_rounded,
                  label: 'Coach',
                  isActive: currentTab == 4,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 4,
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating "Ask Coach" button on non-coach screens
      floatingActionButton: currentTab != 4
          ? FloatingActionButton(
              onPressed: () => ref.read(currentTabProvider.notifier).state = 4,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.background),
            )
          : null,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.accent : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
