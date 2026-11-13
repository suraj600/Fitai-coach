# ProGuard / R8 rules for FitAI Coach
# Add these to android/app/proguard-rules.pro after flutter create

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep model classes for Firestore serialization
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName *;
}

# Keep Gson / JSON serialization
-keepattributes Signature
-keepattributes *Annotation*

# Prevent stripping of security-critical classes
-keep class io.flutter.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
