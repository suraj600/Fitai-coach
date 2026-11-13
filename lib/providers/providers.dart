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

// ─── User Profile ───────────────────────────────────────────────────────────

/// Holds the current user profile — initialized from demo data or Firestore.
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(null) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Use demo user by default (replace with auth-based loading in production)
    state = DemoData.demoUser;
  }

  void updateProfile(UserProfile profile) {
    state = profile;
    // Save to Firestore
    _ref.read(firestoreServiceProvider).saveUserProfile(profile);
  }

  void updateMeasurements(Map<String, double> measurements) {
    if (state != null) {
      state = state!.copyWith(measurements: measurements);
    }
  }
}

// ─── Navigation ─────────────────────────────────────────────────────────────

final currentTabProvider = StateProvider<int>((ref) => 0);

// ─── Workout Plan ───────────────────────────────────────────────────────────

final activeWorkoutPlanProvider = StateProvider<WorkoutPlan?>((ref) => null);

// ─── Workout Logs ───────────────────────────────────────────────────────────

final workoutLogsProvider = StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>((ref) {
  return WorkoutLogsNotifier(ref);
});

class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  final Ref _ref;

  WorkoutLogsNotifier(this._ref) : super([]) {
    _loadDemoLogs();
  }

  void _loadDemoLogs() {
    final profile = _ref.read(userProfileProvider);
    if (profile != null) {
      state = DemoData.generateWorkoutHistory(profile.uid);
    }
  }

  void addLog(WorkoutLog log) {
    state = [log, ...state];
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
    _loadDemoMeals();
  }

  void _loadDemoMeals() {
    final profile = _ref.read(userProfileProvider);
    if (profile != null) {
      state = DemoData.generateTodaysMeals(profile.uid);
    }
  }

  void addMeal(MealLog meal) {
    state = [...state, meal];
  }

  int get totalCalories => state.fold(0, (s, m) => s + m.calories);
  double get totalProtein => state.fold(0.0, (s, m) => s + m.proteinG);
  double get totalCarbs => state.fold(0.0, (s, m) => s + m.carbsG);
  double get totalFat => state.fold(0.0, (s, m) => s + m.fatG);
}

// ─── Water ──────────────────────────────────────────────────────────────────

final waterCountProvider = StateProvider<int>((ref) => 4); // glasses today

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
            'you\'re going for muscle gain with 5 days at MAS Gym. '
            'Your back and legs need the most attention.\n\n'
            'What would you like help with today?',
        isUser: false,
        suggestions: [
          'Adjust today\'s workout',
          'What should I eat?',
          'Show my progress',
          'Why is my bench stuck?',
        ],
      ),
    ];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
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
