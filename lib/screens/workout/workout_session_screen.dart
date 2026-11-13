/// Workout Session — live tracking with timer, set logging, rest countdown.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final String workoutDayName;
  final List<PlannedExercise> plannedExercises;

  const WorkoutSessionScreen({
    super.key,
    required this.workoutDayName,
    this.plannedExercises = const [],
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  bool _isResting = false;
  int _restRemaining = 0;

  // Built from planned exercises
  late List<_SessionExercise> _exercises;
  int _currentExerciseIndex = 0;
  double _rpe = 7;

  @override
  void initState() {
    super.initState();

    // Build session exercises from plan (or fallback to hardcoded)
    if (widget.plannedExercises.isNotEmpty) {
      _exercises = widget.plannedExercises.map((p) {
        return _SessionExercise(
          p.exercise.name,
          p.exercise.id,
          List.generate(p.sets, (i) => _SetEntry(0, 0)),
          p.restSeconds,
        );
      }).toList();
    } else {
      // Fallback for backward compatibility
      _exercises = [
        _SessionExercise('Barbell Bench Press', 'ch01', [
          _SetEntry(60, 8), _SetEntry(62.5, 7), _SetEntry(62.5, 6), _SetEntry(60, 8),
        ], 120),
        _SessionExercise('Incline Dumbbell Press', 'ch04', [
          _SetEntry(22, 10), _SetEntry(24, 8), _SetEntry(24, 0),
        ], 90),
        _SessionExercise('Overhead Press', 'sh01', [
          _SetEntry(40, 8), _SetEntry(42.5, 0), _SetEntry(40, 0),
        ], 90),
      ];
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
          if (_isResting && _restRemaining > 0) {
            _restRemaining--;
            if (_restRemaining == 0) _isResting = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _isResting = true;
      _restRemaining = seconds;
    });
  }

  void _finishWorkout() {
    // Check at least one set was logged
    final hasData = _exercises.any((ex) => ex.sets.any((s) => s.reps > 0));
    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log at least one set before finishing')),
      );
      return;
    }

    final exerciseLogs = _exercises.map((ex) {
      return ExerciseLog(
        exerciseId: ex.id,
        exerciseName: ex.name,
        sets: ex.sets.asMap().entries.where((e) => e.value.reps > 0).map((e) {
          return SetLog(
            setNumber: e.key + 1,
            weightKg: e.value.weight,
            reps: e.value.reps,
          );
        }).toList(),
        rpe: _rpe,
      );
    }).toList();

    final totalVolume = exerciseLogs.fold(0.0, (s, e) => s + e.totalVolume);

    final log = WorkoutLog(
      id: const Uuid().v4(),
      userId: ref.read(userProfileProvider)?.uid ?? '',
      workoutDayName: widget.workoutDayName,
      date: DateTime.now(),
      durationMinutes: _elapsedSeconds ~/ 60,
      totalVolume: totalVolume,
      exercises: exerciseLogs,
    );

    try {
      ref.read(workoutLogsProvider.notifier).addLog(log);
    } catch (_) {
      // Log save failed — still show summary, data is in-memory
    }

    // Show summary
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: const Text('Great Workout! 💪', style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You lifted ${totalVolume.toStringAsFixed(0)} kg in ${_elapsedSeconds ~/ 60} minutes.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            Text(
              '${exerciseLogs.where((e) => e.sets.isNotEmpty).length} of ${_exercises.length} exercises completed.',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEx = _exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutDayName),
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: const Text('Finish',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer,
                        color: _isPaused ? AppColors.warning : AppColors.accent,
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: AppTextStyles.h3.copyWith(
                        fontFamily: 'monospace',
                        color: _isPaused ? AppColors.warning : AppColors.accent,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _isPaused = !_isPaused),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rest timer overlay
          if (_isResting)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.accentSubtle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_bottom,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Rest: ${_formatTime(_restRemaining)}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => setState(() => _isResting = false),
                    child: Text('Skip',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.accent)),
                  ),
                ],
              ),
            ),

          // Exercise tabs
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _exercises.length,
              itemBuilder: (context, idx) {
                final isActive = idx == _currentExerciseIndex;
                final hasData = _exercises[idx].sets.any((s) => s.reps > 0);
                return GestureDetector(
                  onTap: () => setState(() => _currentExerciseIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accent
                          : hasData
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.background
                              : hasData
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Current exercise card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentEx.name, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text('Rest: ${currentEx.restSeconds}s between sets',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 20),

                  // Sets table
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            SizedBox(width: 40, child: Text('Set', style: AppTextStyles.label)),
                            Expanded(child: Text('Weight (kg)', style: AppTextStyles.label)),
                            Expanded(child: Text('Reps', style: AppTextStyles.label)),
                            const SizedBox(width: 50),
                          ],
                        ),
                        const Divider(height: 16),
                        // Sets
                        ...currentEx.sets.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final set = entry.value;
                          final isCompleted = set.reps > 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text('${idx + 1}',
                                      style: AppTextStyles.body
                                          .copyWith(fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.body,
                                      decoration: InputDecoration(
                                        hintText: set.weight > 0 ? '${set.weight}' : '0',
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (v) {
                                        setState(() => set.weight = double.tryParse(v) ?? set.weight);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.body,
                                      decoration: InputDecoration(
                                        hintText: set.reps > 0 ? '${set.reps}' : '–',
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (v) {
                                        setState(() => set.reps = int.tryParse(v) ?? 0);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (set.reps == 0) {
                                      setState(() => set.reps = 8);
                                    }
                                    _startRestTimer(currentEx.restSeconds);
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? AppColors.success.withValues(alpha: 0.15)
                                          : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isCompleted ? Icons.check : Icons.radio_button_unchecked,
                                      color: isCompleted
                                          ? AppColors.success
                                          : AppColors.textTertiary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        // Add set button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentEx.sets.add(_SetEntry(
                                  currentEx.sets.isNotEmpty ? currentEx.sets.last.weight : 0, 0));
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add,
                                    color: AppColors.textSecondary, size: 18),
                                const SizedBox(width: 4),
                                Text('Add Set', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // RPE Slider
                  Text('RPE (Rate of Perceived Exertion)', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Slider(
                    value: _rpe,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _rpe.toStringAsFixed(0),
                    onChanged: (v) => setState(() => _rpe = v),
                  ),
                  Center(
                    child: Text('RPE: ${_rpe.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall),
                  ),
                  const SizedBox(height: 16),

                  // Note field
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Add note (e.g. "shoulder felt tight")',
                      prefixIcon: Icon(Icons.note_add, size: 20),
                    ),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionExercise {
  final String name;
  final String id;
  final List<_SetEntry> sets;
  final int restSeconds;
  _SessionExercise(this.name, this.id, this.sets, this.restSeconds);
}

class _SetEntry {
  double weight;
  int reps;
  _SetEntry(this.weight, this.reps);
}
