/// Exercise database — 120+ exercises organized by muscle group.
library;

import '../models/exercise.dart';
import '../utils/constants.dart';

class ExerciseDatabase {
  static final List<Exercise> exercises = [
    // ─── CHEST (15) ────────────────────────────────────────────────────────
    const Exercise(id: 'ch01', name: 'Barbell Bench Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders], instructions: 'Lie flat, grip bar slightly wider than shoulder-width. Lower to mid-chest, press up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'ch02', name: 'Incline Barbell Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps], instructions: 'Set bench to 30-45°. Press bar from upper chest to lockout.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'ch03', name: 'Dumbbell Bench Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps], instructions: 'Lie flat, dumbbells at chest height. Press up and slightly inward.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'ch04', name: 'Incline Dumbbell Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.shoulders], instructions: 'Bench at 30-45°. Press dumbbells from upper chest.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'ch05', name: 'Decline Bench Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps], instructions: 'Set bench to decline. Lower bar to lower chest.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'ch06', name: 'Cable Fly', primaryMuscle: MuscleGroup.chest, instructions: 'Stand between cables set high. Bring handles together in arc motion.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ch07', name: 'Dumbbell Fly', primaryMuscle: MuscleGroup.chest, instructions: 'Lie flat, arms extended. Lower dumbbells in wide arc, squeeze back up.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'ch08', name: 'Chest Dip', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps], instructions: 'Lean forward on dip bars. Lower until stretch in chest, press up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'ch09', name: 'Machine Chest Press', primaryMuscle: MuscleGroup.chest, instructions: 'Sit with handles at chest height. Press forward to full extension.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'ch10', name: 'Push-Up', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders], equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Hands shoulder-width, lower chest to floor, press up.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'ch11', name: 'Pec Deck', primaryMuscle: MuscleGroup.chest, instructions: 'Sit in machine, bring pads together in front of chest.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ch12', name: 'Incline Cable Fly', primaryMuscle: MuscleGroup.chest, instructions: 'Bench at 30° between low cables. Fly motion upward.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'ch13', name: 'Close-Grip Bench Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps], instructions: 'Narrow grip on bar. Lower to mid-chest, press up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'ch14', name: 'Landmine Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.shoulders], instructions: 'Hold barbell end at shoulder. Press upward at angle.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'ch15', name: 'Svend Press', primaryMuscle: MuscleGroup.chest, instructions: 'Squeeze two plates together at chest. Press forward.', difficulty: 'beginner', category: 'isolation'),

    // ─── BACK (15) ─────────────────────────────────────────────────────────
    const Exercise(id: 'bk01', name: 'Barbell Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.lats], instructions: 'Bend at hips 45°, pull bar to lower chest. Squeeze shoulder blades.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'bk02', name: 'Lat Pulldown', primaryMuscle: MuscleGroup.lats, secondaryMuscles: [MuscleGroup.biceps], instructions: 'Grip bar wide, pull to upper chest. Control the negative.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'bk03', name: 'Seated Cable Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.lats], instructions: 'Sit upright, pull handle to lower chest. Squeeze at peak.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'bk04', name: 'Deadlift', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes, MuscleGroup.traps], instructions: 'Feet hip-width, grip bar outside knees. Drive through heels, lock out hips.', difficulty: 'advanced', category: 'compound'),
    const Exercise(id: 'bk05', name: 'Pull-Ups', primaryMuscle: MuscleGroup.lats, secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.back], equipmentOptions: [Equipment.fullGym, Equipment.homeDumbbells], instructions: 'Grip bar overhand, pull chin above bar. Full extension at bottom.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'bk06', name: 'Dumbbell Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], instructions: 'One hand on bench, row dumbbell to hip. Keep torso parallel.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'bk07', name: 'T-Bar Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.lats], instructions: 'Straddle bar, grip V-handle. Row to chest.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'bk08', name: 'Face Pull', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.shoulders], instructions: 'Cable at face height, rope attachment. Pull to ears, externally rotate.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bk09', name: 'Reverse Fly', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.shoulders], instructions: 'Bent over or on machine, raise dumbbells out to sides.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bk10', name: 'Chin-Ups', primaryMuscle: MuscleGroup.lats, secondaryMuscles: [MuscleGroup.biceps], instructions: 'Underhand grip, pull chin above bar.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'bk11', name: 'Cable Pullover', primaryMuscle: MuscleGroup.lats, instructions: 'Face cable, straight arms, pull bar down in arc to hips.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'bk12', name: 'Rack Pull', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.traps], instructions: 'Bar at knee height on rack. Deadlift from this position.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'bk13', name: 'Pendlay Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], instructions: 'Bar on floor each rep. Explosive row to lower chest.', difficulty: 'advanced', category: 'compound'),
    const Exercise(id: 'bk14', name: 'Meadows Row', primaryMuscle: MuscleGroup.lats, instructions: 'Landmine setup, staggered stance. Row end of bar to hip.', difficulty: 'advanced', category: 'compound'),
    const Exercise(id: 'bk15', name: 'Straight-Arm Pulldown', primaryMuscle: MuscleGroup.lats, instructions: 'Cable high, straight arms, pull down to thighs.', difficulty: 'beginner', category: 'isolation'),

    // ─── SHOULDERS (12) ───────────────────────────────────────────────────
    const Exercise(id: 'sh01', name: 'Overhead Press', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.triceps], instructions: 'Bar at shoulders, press overhead. Lock out at top.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'sh02', name: 'Dumbbell Shoulder Press', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.triceps], instructions: 'Seated, dumbbells at ears. Press overhead.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'sh03', name: 'Arnold Press', primaryMuscle: MuscleGroup.shoulders, instructions: 'Start palms facing you, rotate as you press up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'sh04', name: 'Cable Lateral Raise', primaryMuscle: MuscleGroup.shoulders, instructions: 'Stand beside cable, raise arm to side until parallel.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'sh05', name: 'Dumbbell Lateral Raise', primaryMuscle: MuscleGroup.shoulders, instructions: 'Arms at sides, raise dumbbells to shoulder height. Slight forward lean.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'sh06', name: 'Front Raise', primaryMuscle: MuscleGroup.shoulders, instructions: 'Raise dumbbell/plate in front to eye height.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'sh07', name: 'Upright Row', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.traps], instructions: 'Narrow grip, pull bar to chin. Elbows lead.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'sh08', name: 'Machine Shoulder Press', primaryMuscle: MuscleGroup.shoulders, instructions: 'Sit in machine, press handles overhead.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'sh09', name: 'Behind-Neck Press', primaryMuscle: MuscleGroup.shoulders, instructions: 'Bar behind head at ear level. Press up. Advanced movement.', difficulty: 'advanced', category: 'compound'),
    const Exercise(id: 'sh10', name: 'Lu Raise', primaryMuscle: MuscleGroup.shoulders, instructions: 'Front raise to overhead in one motion with slight bend.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'sh11', name: 'Reverse Pec Deck', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.back], instructions: 'Face machine, pull handles back. Rear delt focus.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'sh12', name: 'Shrugs', primaryMuscle: MuscleGroup.traps, instructions: 'Hold heavy dumbbells/bar, shrug shoulders to ears.', difficulty: 'beginner', category: 'isolation'),

    // ─── BICEPS (8) ───────────────────────────────────────────────────────
    const Exercise(id: 'bi01', name: 'Barbell Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Stand, curl bar from thighs to shoulders. No swinging.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bi02', name: 'Dumbbell Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Alternating or together, curl to shoulders with supination.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bi03', name: 'Hammer Curl', primaryMuscle: MuscleGroup.biceps, secondaryMuscles: [MuscleGroup.forearms], instructions: 'Neutral grip curl. Targets brachialis and forearms.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bi04', name: 'Incline Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Bench at 45°, arms hanging. Curl with full stretch.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'bi05', name: 'Preacher Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Arms on preacher pad, curl to top. Control the negative.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'bi06', name: 'Cable Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Low cable, curl handle to shoulders. Constant tension.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bi07', name: 'Concentration Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Seated, elbow on inner thigh. Curl dumbbell with focus.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'bi08', name: 'Spider Curl', primaryMuscle: MuscleGroup.biceps, instructions: 'Chest on incline bench, curl from stretched position.', difficulty: 'intermediate', category: 'isolation'),

    // ─── TRICEPS (8) ──────────────────────────────────────────────────────
    const Exercise(id: 'tr01', name: 'Tricep Pushdown', primaryMuscle: MuscleGroup.triceps, instructions: 'Cable high, push bar down. Keep elbows at sides.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'tr02', name: 'Overhead Tricep Extension', primaryMuscle: MuscleGroup.triceps, instructions: 'Dumbbell or cable overhead, extend arms. Stretch at bottom.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'tr03', name: 'Skull Crushers', primaryMuscle: MuscleGroup.triceps, instructions: 'Lie flat, lower bar/DBs to forehead. Extend arms.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'tr04', name: 'Rope Pushdown', primaryMuscle: MuscleGroup.triceps, instructions: 'Cable rope, push down and spread at bottom.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'tr05', name: 'Dips (Tricep Focus)', primaryMuscle: MuscleGroup.triceps, secondaryMuscles: [MuscleGroup.chest], instructions: 'Upright torso on dip bars. Lower and press up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'tr06', name: 'Diamond Push-Up', primaryMuscle: MuscleGroup.triceps, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Hands together forming diamond. Push up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'tr07', name: 'Kickback', primaryMuscle: MuscleGroup.triceps, instructions: 'Bent over, extend arm back. Squeeze at top.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'tr08', name: 'Close-Grip Push-Up', primaryMuscle: MuscleGroup.triceps, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Hands inside shoulder width. Lower and press.', difficulty: 'beginner', category: 'compound'),

    // ─── QUADS (10) ───────────────────────────────────────────────────────
    const Exercise(id: 'qu01', name: 'Barbell Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings], instructions: 'Bar on upper back, squat to parallel or below. Drive up.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'qu02', name: 'Front Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Bar on front delts, squat upright. Quad-dominant.', difficulty: 'advanced', category: 'compound'),
    const Exercise(id: 'qu03', name: 'Leg Press', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Feet shoulder-width on platform. Press and return. Don\'t lock knees.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'qu04', name: 'Leg Extension', primaryMuscle: MuscleGroup.quads, instructions: 'Seated, extend legs to straight. Squeeze quads at top.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'qu05', name: 'Hack Squat', primaryMuscle: MuscleGroup.quads, instructions: 'Machine hack squat. Feet low on platform for quad focus.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'qu06', name: 'Bulgarian Split Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Rear foot elevated, lunge down. Drive through front heel.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'qu07', name: 'Walking Lunge', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Step forward, lower back knee. Alternate legs.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'qu08', name: 'Goblet Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], equipmentOptions: [Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Hold dumbbell at chest. Squat between knees.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'qu09', name: 'Sissy Squat', primaryMuscle: MuscleGroup.quads, instructions: 'Lean back, bend knees forward. Isolates quads.', difficulty: 'advanced', category: 'isolation'),
    const Exercise(id: 'qu10', name: 'Step-Up', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Step onto box/bench with one leg. Drive up.', difficulty: 'beginner', category: 'compound'),

    // ─── HAMSTRINGS (8) ──────────────────────────────────────────────────
    const Exercise(id: 'hm01', name: 'Romanian Deadlift', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back], instructions: 'Slight knee bend, hip hinge forward. Feel hamstring stretch.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'hm02', name: 'Leg Curl', primaryMuscle: MuscleGroup.hamstrings, instructions: 'Lying or seated, curl weight toward glutes.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'hm03', name: 'Stiff-Leg Deadlift', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Legs nearly straight, hinge at hips. Deeper hamstring stretch.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'hm04', name: 'Good Morning', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.back], instructions: 'Bar on back, bow forward keeping back neutral.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'hm05', name: 'Nordic Curl', primaryMuscle: MuscleGroup.hamstrings, equipmentOptions: [Equipment.homeNone, Equipment.fullGym], instructions: 'Kneel, someone holds ankles. Slowly lower body forward.', difficulty: 'advanced', category: 'isolation'),
    const Exercise(id: 'hm06', name: 'Glute-Ham Raise', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes], instructions: 'On GHD machine, lower and curl back up using hamstrings.', difficulty: 'advanced', category: 'compound'),
    const Exercise(id: 'hm07', name: 'Dumbbell RDL', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes], equipmentOptions: [Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Dumbbells in hand, hinge forward with slight knee bend.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'hm08', name: 'Single-Leg RDL', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes], instructions: 'Stand on one leg, hinge forward. Balance and stretch.', difficulty: 'intermediate', category: 'compound'),

    // ─── GLUTES (6) ──────────────────────────────────────────────────────
    const Exercise(id: 'gl01', name: 'Hip Thrust', primaryMuscle: MuscleGroup.glutes, secondaryMuscles: [MuscleGroup.hamstrings], instructions: 'Upper back on bench, bar on hips. Drive hips up. Squeeze at top.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'gl02', name: 'Cable Kickback', primaryMuscle: MuscleGroup.glutes, instructions: 'Ankle strap on cable, kick leg back. Squeeze glute.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'gl03', name: 'Glute Bridge', primaryMuscle: MuscleGroup.glutes, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Lie on floor, feet flat. Drive hips up.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'gl04', name: 'Sumo Deadlift', primaryMuscle: MuscleGroup.glutes, secondaryMuscles: [MuscleGroup.quads, MuscleGroup.hamstrings], instructions: 'Wide stance, toes out. Grip inside knees. Lift.', difficulty: 'intermediate', category: 'compound'),
    const Exercise(id: 'gl05', name: 'Cable Pull-Through', primaryMuscle: MuscleGroup.glutes, secondaryMuscles: [MuscleGroup.hamstrings], instructions: 'Face away from cable, hinge and pull through legs.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'gl06', name: 'Frog Pump', primaryMuscle: MuscleGroup.glutes, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Lie flat, soles of feet together, drive hips up.', difficulty: 'beginner', category: 'isolation'),

    // ─── CALVES (4) ──────────────────────────────────────────────────────
    const Exercise(id: 'cv01', name: 'Standing Calf Raise', primaryMuscle: MuscleGroup.calves, instructions: 'On calf raise machine or step. Rise onto toes, slow negative.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'cv02', name: 'Seated Calf Raise', primaryMuscle: MuscleGroup.calves, instructions: 'Seated machine, rise on toes. Targets soleus.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'cv03', name: 'Leg Press Calf Raise', primaryMuscle: MuscleGroup.calves, instructions: 'Toes on bottom of leg press platform. Press with calves.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'cv04', name: 'Donkey Calf Raise', primaryMuscle: MuscleGroup.calves, instructions: 'Bent over, weight on back. Rise on toes.', difficulty: 'intermediate', category: 'isolation'),

    // ─── ABS (10) ─────────────────────────────────────────────────────────
    const Exercise(id: 'ab01', name: 'Cable Crunch', primaryMuscle: MuscleGroup.abs, instructions: 'Kneel at cable, rope behind head. Crunch down.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ab02', name: 'Hanging Leg Raise', primaryMuscle: MuscleGroup.abs, instructions: 'Hang from bar, raise legs to parallel or above.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'ab03', name: 'Plank', primaryMuscle: MuscleGroup.abs, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Forearms on floor, body straight. Hold position.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ab04', name: 'Ab Wheel Rollout', primaryMuscle: MuscleGroup.abs, instructions: 'Kneel, roll wheel forward. Return using abs.', difficulty: 'intermediate', category: 'isolation'),
    const Exercise(id: 'ab05', name: 'Russian Twist', primaryMuscle: MuscleGroup.abs, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Sit, lean back, rotate side to side with weight.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ab06', name: 'Bicycle Crunch', primaryMuscle: MuscleGroup.abs, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Lie flat, alternate elbow-to-knee touches.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ab07', name: 'Dragon Flag', primaryMuscle: MuscleGroup.abs, instructions: 'Lie on bench, grip behind head. Raise body straight, lower slowly.', difficulty: 'advanced', category: 'isolation'),
    const Exercise(id: 'ab08', name: 'Decline Crunch', primaryMuscle: MuscleGroup.abs, instructions: 'Decline bench, crunch up. Add weight for progression.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'ab09', name: 'Mountain Climber', primaryMuscle: MuscleGroup.abs, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Push-up position, drive knees to chest alternately.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'ab10', name: 'Dead Bug', primaryMuscle: MuscleGroup.abs, equipmentOptions: [Equipment.homeNone, Equipment.homeDumbbells, Equipment.fullGym], instructions: 'Lie flat, opposite arm and leg extend out. Alternate.', difficulty: 'beginner', category: 'isolation'),

    // ─── FOREARMS (4) ────────────────────────────────────────────────────
    const Exercise(id: 'fr01', name: 'Wrist Curl', primaryMuscle: MuscleGroup.forearms, instructions: 'Forearms on knees, curl barbell/dumbbells with wrists.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'fr02', name: 'Reverse Wrist Curl', primaryMuscle: MuscleGroup.forearms, instructions: 'Forearms on knees, palms down. Curl wrists up.', difficulty: 'beginner', category: 'isolation'),
    const Exercise(id: 'fr03', name: 'Farmer\'s Walk', primaryMuscle: MuscleGroup.forearms, secondaryMuscles: [MuscleGroup.traps], instructions: 'Hold heavy dumbbells, walk for distance/time.', difficulty: 'beginner', category: 'compound'),
    const Exercise(id: 'fr04', name: 'Plate Pinch', primaryMuscle: MuscleGroup.forearms, instructions: 'Pinch two plates together with fingers. Hold for time.', difficulty: 'intermediate', category: 'isolation'),
  ];

  /// Get exercises filtered by muscle group
  static List<Exercise> getByMuscle(MuscleGroup muscle) =>
      exercises.where((e) => e.primaryMuscle == muscle).toList();

  /// Get exercises filtered by equipment
  static List<Exercise> getByEquipment(Equipment equip) =>
      exercises.where((e) => e.equipmentOptions.contains(equip)).toList();

  /// Get exercise by ID
  static Exercise? getById(String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search exercises by name
  static List<Exercise> search(String query) {
    final lower = query.toLowerCase();
    return exercises
        .where((e) =>
            e.name.toLowerCase().contains(lower) ||
            e.primaryMuscle.label.toLowerCase().contains(lower))
        .toList();
  }

  /// Get a swap alternative for an exercise (same muscle group)
  static Exercise? getSwapAlternative(Exercise current) {
    final alternatives = exercises
        .where((e) =>
            e.primaryMuscle == current.primaryMuscle && e.id != current.id)
        .toList();
    if (alternatives.isEmpty) return null;
    alternatives.shuffle();
    return alternatives.first;
  }
}
