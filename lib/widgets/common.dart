/// Reusable widgets for FitAI Coach — cards, buttons, indicators.
library;

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/constants.dart';

/// Accent-colored primary button
class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  const AccentButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.background,
              ),
            )
          : Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Dark stat card with value + label
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, color: AppColors.accent, size: 20),
          if (icon != null) const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.stat.copyWith(
              color: valueColor ?? AppColors.accent,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circular progress ring (for calories, macros, etc.)
class ProgressRing extends StatelessWidget {
  final double percent; // 0.0-1.0
  final String centerText;
  final String? label;
  final Color? progressColor;
  final double radius;

  const ProgressRing({
    super.key,
    required this.percent,
    required this.centerText,
    this.label,
    this.progressColor,
    this.radius = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: 8,
          percent: percent.clamp(0, 1),
          center: Text(centerText, style: AppTextStyles.h3),
          progressColor: progressColor ?? AppColors.accent,
          backgroundColor: AppColors.surfaceLight,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

/// Macro bar (protein, carbs, fat)
class MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;

  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(
              '${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}g',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 6,
          percent: percent,
          progressColor: color,
          backgroundColor: AppColors.surfaceLight,
          barRadius: const Radius.circular(3),
        ),
      ],
    );
  }
}

/// Chip/Tag for selection
class SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSubtle : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state placeholder
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
