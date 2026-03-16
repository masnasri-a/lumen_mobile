# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# google_sign_in
-keep class com.google.android.gms.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.android.gms.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# General
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
