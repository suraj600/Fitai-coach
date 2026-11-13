/// Firestore service — CRUD operations for user profiles, workouts, nutrition, chat.
///
/// Security: All write methods validate that userId matches the authenticated user.
/// Demo/local users (uid starting with 'local_') are blocked from Firestore writes.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/nutrition.dart';
import '../models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Verify the requested uid matches the currently authenticated user.
  /// Prevents client-side UID tampering. Blocks demo/local users.
  void _assertAuthorized(String uid) {
    if (uid.startsWith('local_')) {
      throw Exception('Demo users cannot access Firestore');
    }
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid != uid) {
      throw Exception('Unauthorized: uid mismatch');
    }
  }

  // ─── User Profile ─────────────────────────────────────────────────────────

  Future<void> saveUserProfile(UserProfile profile) async {
    _assertAuthorized(profile.uid);
    await _db.collection('users').doc(profile.uid).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!);
  }

  Stream<UserProfile?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data()!);
    });
  }

  // ─── Workout Plans ────────────────────────────────────────────────────────

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    _assertAuthorized(plan.userId);
    await _db
        .collection('users')
        .doc(plan.userId)
        .collection('workoutPlans')
        .doc(plan.id)
        .set(plan.toFirestore());
  }

  Future<WorkoutPlan?> getActiveWorkoutPlan(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('workoutPlans')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return WorkoutPlan.fromFirestore(snap.docs.first.data());
  }

  // ─── Workout Logs ─────────────────────────────────────────────────────────

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    _assertAuthorized(log.userId);
    await _db
        .collection('users')
        .doc(log.userId)
        .collection('workoutLogs')
        .doc(log.id)
        .set(log.toFirestore());
  }

  Future<List<WorkoutLog>> getWorkoutLogs(String uid, {int limit = 30}) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map((d) => WorkoutLog.fromFirestore(d.data())).toList();
  }

  Stream<List<WorkoutLog>> streamWorkoutLogs(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .orderBy('date', descending: true)
        .limit(60)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => WorkoutLog.fromFirestore(d.data())).toList());
  }

  /// Get the most recent log for a specific exercise
  Future<ExerciseLog?> getLastExerciseLog(String uid, String exerciseId) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    for (final doc in snap.docs) {
      final log = WorkoutLog.fromFirestore(doc.data());
      for (final ex in log.exercises) {
        if (ex.exerciseId == exerciseId) return ex;
      }
    }
    return null;
  }

  // ─── Nutrition Logs ───────────────────────────────────────────────────────

  Future<void> saveMealLog(MealLog meal) async {
    _assertAuthorized(meal.userId);
    await _db
        .collection('users')
        .doc(meal.userId)
        .collection('mealLogs')
        .doc(meal.id)
        .set(meal.toFirestore());
  }

  Future<List<MealLog>> getMealsForDate(String uid, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('mealLogs')
        .where('loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('loggedAt')
        .get();

    return snap.docs.map((d) => MealLog.fromFirestore(d.data())).toList();
  }

  Stream<List<MealLog>> streamTodaysMeals(String uid) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _db
        .collection('users')
        .doc(uid)
        .collection('mealLogs')
        .where('loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('loggedAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealLog.fromFirestore(d.data())).toList());
  }

  // ─── Water Tracking ───────────────────────────────────────────────────────

  Future<void> updateWaterCount(String uid, DateTime date, int glasses) async {
    _assertAuthorized(uid);
    final key = '${date.year}-${date.month}-${date.day}';
    await _db
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(key)
        .set({'glasses': glasses, 'date': Timestamp.fromDate(date)});
  }

  Future<int> getWaterCount(String uid, DateTime date) async {
    final key = '${date.year}-${date.month}-${date.day}';
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(key)
        .get();
    return doc.data()?['glasses'] ?? 0;
  }

  // ─── Chat Messages ────────────────────────────────────────────────────────

  static const int _maxChatMessages = 200;

  Future<void> saveChatMessage(ChatMessage message) async {
    _assertAuthorized(message.userId);
    await _db
        .collection('users')
        .doc(message.userId)
        .collection('chatMessages')
        .doc(message.id)
        .set(message.toFirestore());

    // Prune old messages if over limit (fire-and-forget)
    _pruneOldChatMessages(message.userId);
  }

  Future<void> _pruneOldChatMessages(String uid) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('chatMessages')
          .orderBy('timestamp', descending: false)
          .get();

      if (snap.docs.length > _maxChatMessages) {
        final toDelete = snap.docs.length - _maxChatMessages;
        final batch = _db.batch();
        for (int i = 0; i < toDelete; i++) {
          batch.delete(snap.docs[i].reference);
        }
        await batch.commit();
      }
    } catch (_) {
      // Non-critical — silently fail
    }
  }

  Stream<List<ChatMessage>> streamChatMessages(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chatMessages')
        .orderBy('timestamp', descending: false)
        .limit(_maxChatMessages)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromFirestore(d.data())).toList());
  }

  // ─── Body Measurements History ────────────────────────────────────────────

  Future<void> saveBodyMeasurement(
      String uid, Map<String, double> measurements) async {
    _assertAuthorized(uid);
    await _db
        .collection('users')
        .doc(uid)
        .collection('bodyMeasurements')
        .add({
      'measurements': measurements,
      'date': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<List<Map<String, dynamic>>> getBodyMeasurementHistory(
      String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('bodyMeasurements')
        .orderBy('date', descending: true)
        .limit(20)
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }
}
