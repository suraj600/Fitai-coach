/// Riverpod providers for app-wide state management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/nutrition.dart';
import '../models/chat_message.dart';
import '../data/demo_data.dart';

// ─── Service Providers ──────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final aiServiceProvider = Provider<AIService>((ref) => AIService());

// ─── Auth State ─────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Whether the user chose to skip login and use demo data
final authSkippedProvider = StateProvider<bool>((ref) => false);

// ─── User Profile ───────────────────────────────────────────────────────────

/// Holds the current user profile — loaded from Firestore for logged-in users,
/// or from demo data if auth was skipped.
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(null) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authSkipped = _ref.read(authSkippedProvider);

    if (authSkipped) {
      // Demo mode — use local demo data
      state = DemoData.demoUser;
      return;
    }

    // Try loading from Firebase if user is authenticated
    try {
      final auth = _ref.read(authServiceProvider);
      final uid = auth.uid;
      if (uid != null) {
        final firestore = _ref.read(firestoreServiceProvider);
        final profile = await firestore.getUserProfile(uid);
        if (profile != null) {
          state = profile;
          return;
        }
      }
    } catch (_) {
      // Firebase not initialized — fall through to demo
    }

    // No profile found — user needs onboarding
    state = null;
  }

  void updateProfile(UserProfile profile) {
    state = profile;
    // Save to Firestore if not in demo mode
    if (!_ref.read(authSkippedProvider)) {
      try {
        _ref.read(firestoreServiceProvider).saveUserProfile(profile);
      } catch (_) {
        // Firebase not available — continue with local state
      }
    }
  }

  void updateMeasurements(Map<String, double> measurements) {
    if (state != null) {
      state = state!.copyWith(measurements: measurements);
    }
  }

  /// Reload profile from Firestore
  Future<void> refresh() async => _loadProfile();
}

// ─── Navigation ─────────────────────────────────────────────────────────────

final currentTabProvider = StateProvider<int>((ref) => 0);

// ─── Workout Plan ───────────────────────────────────────────────────────────

final activeWorkoutPlanProvider = StateNotifierProvider<WorkoutPlanNotifier, WorkoutPlan?>((ref) {
  return WorkoutPlanNotifier(ref);
});

class WorkoutPlanNotifier extends StateNotifier<WorkoutPlan?> {
  final Ref _ref;

  WorkoutPlanNotifier(this._ref) : super(null) {
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    if (_ref.read(authSkippedProvider)) return; // demo mode has no saved plan
    try {
      final auth = _ref.read(authServiceProvider);
      final uid = auth.uid;
      if (uid != null) {
        final plan = await _ref.read(firestoreServiceProvider).getActiveWorkoutPlan(uid);
        if (plan != null) state = plan;
      }
    } catch (_) {}
  }

  void setPlan(WorkoutPlan plan) {
    state = plan;
    // Persist to Firestore
    if (!_ref.read(authSkippedProvider)) {
      try {
        _ref.read(firestoreServiceProvider).saveWorkoutPlan(plan);
      } catch (_) {}
    }
  }

  /// Swap an exercise in a specific day
  void swapExercise(int dayIndex, int exerciseIndex, PlannedExercise newExercise) {
    if (state == null) return;
    final days = List<WorkoutDay>.from(state!.days);
    if (dayIndex >= days.length) return;

    final day = days[dayIndex];
    final exercises = List<PlannedExercise>.from(day.exercises);
    if (exerciseIndex >= exercises.length) return;

    exercises[exerciseIndex] = newExercise;
    days[dayIndex] = WorkoutDay(
      name: day.name,
      dayIndex: day.dayIndex,
      exercises: exercises,
      estimatedMinutes: day.estimatedMinutes,
      estimatedVolume: day.estimatedVolume,
    );

    state = WorkoutPlan(
      id: state!.id,
      userId: state!.userId,
      splitType: state!.splitType,
      weekNumber: state!.weekNumber,
      days: days,
      createdAt: state!.createdAt,
    );

    // Save updated plan
    if (!_ref.read(authSkippedProvider)) {
      try {
        _ref.read(firestoreServiceProvider).saveWorkoutPlan(state!);
      } catch (_) {}
    }
  }
}

// ─── Workout Logs ───────────────────────────────────────────────────────────

final workoutLogsProvider = StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>((ref) {
  return WorkoutLogsNotifier(ref);
});

class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  final Ref _ref;

  WorkoutLogsNotifier(this._ref) : super([]) {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final profile = _ref.read(userProfileProvider);
    if (profile == null) return;

    if (_ref.read(authSkippedProvider)) {
      // Demo mode
      state = DemoData.generateWorkoutHistory(profile.uid);
      return;
    }

    // Try Firestore
    try {
      final logs = await _ref.read(firestoreServiceProvider).getWorkoutLogs(profile.uid);
      if (logs.isNotEmpty) {
        state = logs;
        return;
      }
    } catch (_) {}

    // Fallback to demo data
    state = DemoData.generateWorkoutHistory(profile.uid);
  }

  void addLog(WorkoutLog log) {
    state = [log, ...state];
    // Persist
    if (!_ref.read(authSkippedProvider)) {
      try {
        _ref.read(firestoreServiceProvider).saveWorkoutLog(log);
      } catch (_) {}
    }
  }

  /// Get total workouts this month
  int get thisMonthCount {
    final now = DateTime.now();
    return state.where((l) =>
        l.date.month == now.month && l.date.year == now.year).length;
  }

  /// Get current streak (consecutive days)
  int get currentStreak {
    if (state.isEmpty) return 0;
    int streak = 0;
    var checkDate = DateTime.now();
    final sortedLogs = [...state]..sort((a, b) => b.date.compareTo(a.date));

    for (final log in sortedLogs) {
      if (_sameDay(log.date, checkDate) || _sameDay(log.date, checkDate.subtract(const Duration(days: 1)))) {
        streak++;
        checkDate = log.date;
      } else {
        break;
      }
    }
    return streak;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Nutrition ──────────────────────────────────────────────────────────────

final todaysMealsProvider = StateNotifierProvider<MealsNotifier, List<MealLog>>((ref) {
  return MealsNotifier(ref);
});

class MealsNotifier extends StateNotifier<List<MealLog>> {
  final Ref _ref;

  MealsNotifier(this._ref) : super([]) {
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final profile = _ref.read(userProfileProvider);
    if (profile == null) return;

    if (_ref.read(authSkippedProvider)) {
      state = DemoData.generateTodaysMeals(profile.uid);
      return;
    }

    try {
      final meals = await _ref
          .read(firestoreServiceProvider)
          .getMealsForDate(profile.uid, DateTime.now());
      if (meals.isNotEmpty) {
        state = meals;
        return;
      }
    } catch (_) {}

    state = DemoData.generateTodaysMeals(profile.uid);
  }

  void addMeal(MealLog meal) {
    state = [...state, meal];
    // Persist
    if (!_ref.read(authSkippedProvider)) {
      try {
        _ref.read(firestoreServiceProvider).saveMealLog(meal);
      } catch (_) {}
    }
  }

  int get totalCalories => state.fold(0, (s, m) => s + m.calories);
  double get totalProtein => state.fold(0.0, (s, m) => s + m.proteinG);
  double get totalCarbs => state.fold(0.0, (s, m) => s + m.carbsG);
  double get totalFat => state.fold(0.0, (s, m) => s + m.fatG);
}

// ─── Water ──────────────────────────────────────────────────────────────────

final waterCountProvider = StateNotifierProvider<WaterNotifier, int>((ref) {
  return WaterNotifier(ref);
});

class WaterNotifier extends StateNotifier<int> {
  final Ref _ref;

  WaterNotifier(this._ref) : super(0) {
    _loadWater();
  }

  Future<void> _loadWater() async {
    if (_ref.read(authSkippedProvider)) {
      state = 4; // demo default
      return;
    }

    try {
      final profile = _ref.read(userProfileProvider);
      if (profile != null) {
        final count = await _ref
            .read(firestoreServiceProvider)
            .getWaterCount(profile.uid, DateTime.now());
        state = count;
        return;
      }
    } catch (_) {}

    state = 4;
  }

  void increment() {
    state++;
    _persist();
  }

  void decrement() {
    if (state > 0) {
      state--;
      _persist();
    }
  }

  void _persist() {
    if (_ref.read(authSkippedProvider)) return;
    try {
      final profile = _ref.read(userProfileProvider);
      if (profile != null) {
        _ref
            .read(firestoreServiceProvider)
            .updateWaterCount(profile.uid, DateTime.now(), state);
      }
    } catch (_) {}
  }
}

// ─── Chat Messages ──────────────────────────────────────────────────────────

final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatNotifier(this._ref) : super([]) {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final profile = _ref.read(userProfileProvider);
    final name = profile?.name ?? 'there';
    state = [
      ChatMessage(
        id: 'welcome',
        userId: profile?.uid ?? '',
        content: 'Hey $name! 💪 I\'m your FitAI Coach. I\'ve analyzed your profile — '
            'you\'re going for ${profile?.primaryGoal.label.toLowerCase() ?? 'muscle gain'} with '
            '${profile?.daysPerWeek ?? 5} days at ${profile?.equipment.label ?? 'the gym'}. '
            '${profile?.measurements.isNotEmpty == true ? 'Your back and legs need the most attention.' : 'Let me know your measurements for a muscle gap analysis.'}\n\n'
            'What would you like help with today?',
        isUser: false,
        suggestions: [
          'Generate my workout plan',
          'What should I eat?',
          'Show my progress',
          'Muscle gap analysis',
        ],
      ),
    ];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
    // Persist to Firestore
    if (!_ref.read(authSkippedProvider)) {
      try {
        _ref.read(firestoreServiceProvider).saveChatMessage(message);
      } catch (_) {}
    }
  }

  void addMessages(List<ChatMessage> messages) {
    state = [...state, ...messages];
  }
}

// ─── Active Workout Session ─────────────────────────────────────────────────

final activeSessionProvider = StateProvider<ActiveWorkoutSession?>((ref) => null);

class ActiveWorkoutSession {
  final String workoutDayName;
  final DateTime startTime;
  final List<ExerciseLog> exercises;
  bool isPaused;

  ActiveWorkoutSession({
    required this.workoutDayName,
    DateTime? startTime,
    List<ExerciseLog>? exercises,
    this.isPaused = false,
  })  : startTime = startTime ?? DateTime.now(),
        exercises = exercises ?? [];

  int get elapsedMinutes => DateTime.now().difference(startTime).inMinutes;
  double get totalVolume =>
      exercises.fold(0.0, (s, e) => s + e.totalVolume);
}

// ─── Loading States ─────────────────────────────────────────────────────────

final isGeneratingPlanProvider = StateProvider<bool>((ref) => false);
final isCoachTypingProvider = StateProvider<bool>((ref) => false);
