/// 5-step onboarding flow for creating user profile.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../models/user_profile.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../app_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '70');
  Gender _gender = Gender.male;

  // Step 2: Goals
  FitnessGoal _primaryGoal = FitnessGoal.muscleGain;
  FitnessGoal? _secondaryGoal;

  // Step 3: Experience
  ExperienceLevel _experience = ExperienceLevel.beginner;
  int _yearsTraining = 0;

  // Step 4: Availability
  int _sessionDuration = 60;
  int _daysPerWeek = 4;
  Equipment _equipment = Equipment.fullGym;

  // Step 5: Measurements & Diet
  DietType _dietType = DietType.nonVeg;
  final _chestController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _waistController = TextEditingController();
  final _injuriesController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    final measurements = <String, double>{};
    if (_chestController.text.isNotEmpty) {
      measurements['chest'] = double.tryParse(_chestController.text) ?? 0;
    }
    if (_shoulderController.text.isNotEmpty) {
      measurements['shoulder'] = double.tryParse(_shoulderController.text) ?? 0;
    }
    if (_waistController.text.isNotEmpty) {
      measurements['waist'] = double.tryParse(_waistController.text) ?? 0;
    }

    final calorieTarget = UserProfile.calculateCalories(
      gender: _gender,
      weightKg: double.tryParse(_weightController.text) ?? 70,
      heightCm: double.tryParse(_heightController.text) ?? 170,
      age: int.tryParse(_ageController.text) ?? 25,
      goal: _primaryGoal,
      daysPerWeek: _daysPerWeek,
    );

    final profile = UserProfile(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.isEmpty ? 'User' : _nameController.text,
      age: int.tryParse(_ageController.text) ?? 25,
      gender: _gender,
      heightCm: double.tryParse(_heightController.text) ?? 170,
      weightKg: double.tryParse(_weightController.text) ?? 70,
      primaryGoal: _primaryGoal,
      secondaryGoal: _secondaryGoal,
      experience: _experience,
      yearsTraining: _yearsTraining,
      sessionDurationMinutes: _sessionDuration,
      daysPerWeek: _daysPerWeek,
      equipment: _equipment,
      measurements: measurements,
      injuries: _injuriesController.text.isEmpty
          ? []
          : _injuriesController.text.split(',').map((e) => e.trim()).toList(),
      dietType: _dietType,
      dailyCalorieTarget: calorieTarget,
      onboardingComplete: true,
    );

    ref.read(userProfileProvider.notifier).updateProfile(profile);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _prevStep,
                          child: const Icon(Icons.arrow_back_ios,
                              color: AppColors.textSecondary, size: 20),
                        )
                      else
                        const SizedBox(width: 20),
                      Text(
                        'Step ${_currentStep + 1} of 5',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 3,
                          decoration: BoxDecoration(
                            color: i <= _currentStep
                                ? AppColors.accent
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfo(),
                  _buildGoals(),
                  _buildExperience(),
                  _buildAvailability(),
                  _buildMeasurements(),
                ],
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: AccentButton(
                label: _currentStep == 4 ? 'Start Training →' : 'Continue',
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Let\'s get to know you', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('This helps us create your perfect plan',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'e.g. Rohan',
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    suffixText: 'cm',
                  ),
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    suffixText: 'kg',
                  ),
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Gender', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Gender.values.map((g) {
              return SelectableChip(
                label: g.label,
                isSelected: _gender == g,
                onTap: () => setState(() => _gender = g),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s your goal?', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('Select primary + optional secondary goal',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 32),
          Text('PRIMARY GOAL', style: AppTextStyles.label),
          const SizedBox(height: 12),
          ...FitnessGoal.values.map((goal) {
            final isSelected = _primaryGoal == goal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _primaryGoal = goal),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSubtle : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(goal.icon,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(goal.label,
                          style: AppTextStyles.body.copyWith(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textPrimary,
                          )),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('SECONDARY GOAL (Optional)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FitnessGoal.values
                .where((g) => g != _primaryGoal)
                .map((goal) {
              return SelectableChip(
                label: goal.label,
                isSelected: _secondaryGoal == goal,
                onTap: () => setState(() {
                  _secondaryGoal = _secondaryGoal == goal ? null : goal;
                }),
                icon: goal.icon,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperience() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your experience', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('This helps us set the right intensity',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 32),
          ...ExperienceLevel.values.map((level) {
            final isSelected = _experience == level;
            final descriptions = {
              ExperienceLevel.beginner: 'New to lifting or < 6 months. Focus on form and building habits.',
              ExperienceLevel.intermediate: '6 months - 3 years. Comfortable with compound lifts.',
              ExperienceLevel.advanced: '3+ years. Looking to optimize and break plateaus.',
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _experience = level),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSubtle : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(level.label,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.accent : AppColors.textPrimary,
                          )),
                      const SizedBox(height: 4),
                      Text(descriptions[level]!,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('YEARS TRAINING', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Slider(
            value: _yearsTraining.toDouble(),
            min: 0,
            max: 15,
            divisions: 15,
            label: '$_yearsTraining years',
            onChanged: (v) => setState(() => _yearsTraining = v.round()),
          ),
          Center(
            child: Text('$_yearsTraining years', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailability() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your schedule', style: AppTextStyles.h1),
          const SizedBox(height: 32),
          Text('WORKOUT DURATION', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [30, 45, 60, 90].map((min) {
              return SelectableChip(
                label: '$min min',
                isSelected: _sessionDuration == min,
                onTap: () => setState(() => _sessionDuration = min),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('DAYS PER WEEK', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [3, 4, 5, 6].map((d) {
              return SelectableChip(
                label: '$d days',
                isSelected: _daysPerWeek == d,
                onTap: () => setState(() => _daysPerWeek = d),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('EQUIPMENT', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ...Equipment.values.map((eq) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableChip(
                label: eq.label,
                isSelected: _equipment == eq,
                onTap: () => setState(() => _equipment = eq),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMeasurements() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Body & Diet', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('Optional — helps with muscle gap analysis',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 32),
          Text('MEASUREMENTS (cm)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chestController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Chest'),
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _shoulderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Shoulder'),
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _waistController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Waist'),
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _injuriesController,
            decoration: const InputDecoration(
              labelText: 'Injuries / Medical conditions',
              hintText: 'e.g. lower back pain, knee issue (comma-separated)',
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 24),
          Text('DIET TYPE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DietType.values.map((d) {
              return SelectableChip(
                label: d.label,
                isSelected: _dietType == d,
                onTap: () => setState(() => _dietType = d),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _shoulderController.dispose();
    _waistController.dispose();
    _injuriesController.dispose();
    super.dispose();
  }
}
