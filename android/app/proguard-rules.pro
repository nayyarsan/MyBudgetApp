# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Drift / SQLite
-keep class androidx.sqlite.** { *; }
-dontwarn androidx.sqlite.**

# local_auth / BiometricPrompt
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# flutter_secure_storage — Android Keystore
-keep class androidx.security.crypto.** { *; }

# Keep Kotlin metadata for reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# Remove verbose logging in release
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
}
