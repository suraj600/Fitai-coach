/// Profile / Settings screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTextStyles.h1),
              const SizedBox(height: 24),

              // Avatar + name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.accentSubtle,
                      child: Text(
                        profile?.name.isNotEmpty == true
                            ? profile!.name[0].toUpperCase()
                            : 'R',
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.accent, fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(profile?.name ?? 'User', style: AppTextStyles.h2),
                    Text(
                        '${profile?.experience.label ?? ''} • ${profile?.primaryGoal.label ?? ''}',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickStat(
                        '${profile?.weightKg ?? 0}', 'kg', 'Weight'),
                    _QuickStat(
                        '${profile?.heightCm ?? 0}', 'cm', 'Height'),
                    _QuickStat(
                        '${profile?.dailyCalorieTarget ?? 0}', 'kcal', 'Target'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings sections
              _SettingsSection(title: 'Account', items: [
                _SettingsTile(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.fitness_center,
                  title: 'Update Goals',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.straighten,
                  title: 'Body Measurements',
                  onTap: () => _showComingSoon(context),
                ),
              ]),
              const SizedBox(height: 16),

              _SettingsSection(title: 'Preferences', items: [
                _SettingsTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppColors.accent,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.cloud_download,
                  title: 'Offline Mode',
                  trailing: Switch(
                    value: false,
                    onChanged: (_) {},
                    activeColor: AppColors.accent,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Units',
                  subtitle: 'Metric (kg, cm)',
                ),
              ]),
              const SizedBox(height: 16),

              _SettingsSection(title: 'Data', items: [
                _SettingsTile(
                  icon: Icons.download,
                  title: 'Export Workout Data',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.backup,
                  title: 'Cloud Backup',
                  subtitle: 'Synced via Firebase',
                ),
              ]),
              const SizedBox(height: 16),

              _SettingsSection(title: 'Subscription', items: [
                _SettingsTile(
                  icon: Icons.star,
                  title: 'FitAI Pro',
                  subtitle: 'Unlock unlimited AI features',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Upgrade',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.accent)),
                  ),
                  onTap: () => _showComingSoon(context),
                ),
              ]),
              const SizedBox(height: 24),

              // Sign out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sign out (demo mode)')),
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text('Sign Out',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text('FitAI Coach v1.0.0 • Made with 💪',
                    style: AppTextStyles.caption),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const _QuickStat(this.value, this.unit, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: value,
            style: AppTextStyles.h2.copyWith(color: AppColors.accent),
            children: [
              TextSpan(
                text: ' $unit',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(title, style: AppTextStyles.body),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20)
              : null),
      onTap: onTap,
    );
  }
}
