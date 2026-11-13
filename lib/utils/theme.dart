/// FitAI Coach dark gym theme
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentDark,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.background,
          onSecondary: AppColors.background,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textPrimary,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.divider),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.surfaceLight,
          thumbColor: AppColors.accent,
          overlayColor: AppColors.accentSubtle,
          valueIndicatorColor: AppColors.accent,
          valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.background,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedColor: AppColors.accentSubtle,
          labelStyle: AppTextStyles.bodySmall,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          contentTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
          linearTrackColor: AppColors.surfaceLight,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.accent;
            return AppColors.textTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.accentSubtle;
            return AppColors.surfaceLight;
          }),
        ),
      );
}
