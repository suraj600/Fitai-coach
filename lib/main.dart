/// FitAI Coach — AI-powered personal fitness trainer app.
///
/// Entry point: initializes Firebase & launches the app with Riverpod.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/theme.dart';
import 'screens/app_shell.dart';
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
    final profile = ref.watch(userProfileProvider);

    return MaterialApp(
      title: 'FitAI Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: profile != null && profile.onboardingComplete
          ? const AppShell()
          : const OnboardingScreen(),
    );
  }
}
