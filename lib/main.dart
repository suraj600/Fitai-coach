/// FitAI Coach — AI-powered personal fitness trainer app.
///
/// Entry point: initializes Firebase & launches the app with Riverpod.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'screens/app_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141414),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Note: In production, add:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: FitAIApp()));
}

class FitAIApp extends ConsumerWidget {
  const FitAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FitAI Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

/// Routes user based on auth state:
/// 1. Not logged in & not skipped → LoginScreen
/// 2. Logged in / skipped but no profile → OnboardingScreen
/// 3. Has complete profile → AppShell
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSkipped = ref.watch(authSkippedProvider);
    final authState = ref.watch(authStateProvider);
    final profile = ref.watch(userProfileProvider);

    // If auth was skipped, go straight to demo flow
    if (authSkipped) {
      if (profile != null && profile.onboardingComplete) {
        return const AppShell();
      }
      return const OnboardingScreen();
    }

    // Check Firebase auth
    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        // User is logged in — check profile
        if (profile != null && profile.onboardingComplete) {
          return const AppShell();
        }
        return const OnboardingScreen();
      },
      loading: () => const _SplashScreen(),
      error: (_, __) {
        // Firebase not initialized — show login anyway
        return const LoginScreen();
      },
    );
  }
}

/// Splash screen shown while checking auth state
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                size: 64, color: AppColors.accent),
            const SizedBox(height: 16),
            Text('FitAI Coach',
                style: AppTextStyles.h1.copyWith(color: AppColors.accent)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
