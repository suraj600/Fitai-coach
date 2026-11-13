# FitAI Coach 💪🤖

AI-powered personal fitness coach mobile app built with Flutter & Firebase.

## Features

- **Personalized Body Profiling** — 5-step onboarding captures height, weight, goals, experience, measurements, and diet preferences
- **Muscle Imbalance Detection** — Color-coded body map with balance scoring and AI recommendations
- **AI Workout Plans** — Auto-generated PPL/Upper-Lower/Full Body splits based on your profile
- **Workout Tracking** — Live session timer, set logging (weight/reps/RPE), rest timer, progressive overload suggestions
- **Progress Dashboard** — Strength charts (Big 3 lifts), weight trend, consistency heatmap, AI insights
- **Photo Calorie Tracking** — Snap a meal photo → AI estimates calories and macros instantly
- **24/7 AI Coach** — Context-aware chat with suggestion chips, knows your data and plan
- **Water Tracker** — Simple glass counter on the nutrition screen
- **120+ Exercise Database** — Organized by 12 muscle groups with swap alternatives

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod (StateNotifier, StateProvider, StreamProvider) |
| Backend | Firebase (Auth, Firestore, Storage) |
| AI | Google Gemini API (with mock fallbacks) |
| Charts | fl_chart |
| Design | Dark theme (#0A0A0A) + Neon Green (#C8FF00) accent |

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── utils/
│   ├── constants.dart                 # Colors, text styles, enums, API config
│   └── theme.dart                     # Dark ThemeData
├── models/
│   ├── user_profile.dart              # User profile + calorie calculator
│   ├── exercise.dart                  # Exercise & PlannedExercise models
│   ├── workout.dart                   # WorkoutPlan, WorkoutLog, SetLog
│   ├── nutrition.dart                 # MealLog, DailyNutrition
│   └── chat_message.dart             # Chat message with suggestion chips
├── services/
│   ├── auth_service.dart              # Firebase Auth (Google + Email)
│   ├── firestore_service.dart         # Firestore CRUD operations
│   └── ai_service.dart               # Gemini API + mock fallbacks
├── data/
│   ├── exercise_database.dart         # 120+ exercises across 12 muscle groups
│   └── demo_data.dart                 # Demo user "Rohan" + 4 weeks of logs
├── providers/
│   └── providers.dart                 # All Riverpod providers
├── widgets/
│   └── common.dart                    # Reusable UI components
└── screens/
    ├── app_shell.dart                 # Bottom nav + floating Coach button
    ├── onboarding/
    │   └── onboarding_screen.dart     # 5-step onboarding flow
    ├── home/
    │   └── home_screen.dart           # Dashboard with today's overview
    ├── body_analysis/
    │   └── body_analysis_screen.dart  # Muscle balance map + AI tips
    ├── workout/
    │   ├── workout_screen.dart        # Weekly plan + exercise list
    │   └── workout_session_screen.dart# Live workout logging
    ├── progress/
    │   └── progress_screen.dart       # 4-tab: Strength/Body/Consistency/AI
    ├── nutrition/
    │   └── nutrition_screen.dart      # Calorie ring, macros, photo logger
    ├── coach/
    │   └── coach_screen.dart          # AI chat interface
    └── profile/
        └── profile_screen.dart        # Settings & account
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.16+ ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Xcode
- A Firebase project (optional — app works with demo data)

### 1. Clone & Install

```bash
cd fitai_coach
flutter pub get
```

### 2. Firebase Setup (Optional)

The app runs fully with mock/demo data. To enable real Firebase:

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Add Android + iOS apps
3. Download `google-services.json` → `android/app/`
4. Download `GoogleService-Info.plist` → `ios/Runner/`
5. Uncomment `Firebase.initializeApp()` in `lib/main.dart`

### 3. Gemini API Key (Optional)

To enable real AI responses instead of mocks:

1. Get a key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Update `lib/utils/constants.dart`:
   ```dart
   static const geminiApiKey = 'YOUR_KEY_HERE';
   ```

### 4. Run

```bash
flutter run
```

## Demo Data

The app auto-loads demo data for user **"Rohan"**:
- 22 years old, 175cm, 72kg, muscle gain goal
- Intermediate level, MAS Gym with full equipment
- 4 weeks of PPL workout history with progressive volume
- Indian meal examples (egg omelette, chicken+rice+dal, whey shake)
- 28-day weight trend simulating ~0.5kg/week gain

## Design System

| Token | Value |
|-------|-------|
| Background | `#0A0A0A` |
| Surface | `#141414` |
| Card | `#1E1E1E` |
| Accent (Neon Green) | `#C8FF00` |
| Text Primary | `#FFFFFF` |
| Text Secondary | `#A0A0A0` |
| Success | `#00E676` |
| Warning | `#FFB300` |
| Error | `#FF5252` |
| Info | `#448AFF` |

## Calorie Calculation

Uses the **Mifflin-St Jeor equation**:
- Male: `(10 × weight_kg) + (6.25 × height_cm) − (5 × age) + 5`
- Female: `(10 × weight_kg) + (6.25 × height_cm) − (5 × age) − 161`

Multiplied by activity factor (1.2–1.725) and adjusted ±300–500 kcal based on goal.

## License

MIT
