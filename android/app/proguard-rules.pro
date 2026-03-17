# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Google Fonts
-keep class com.google.android.gms.** { *; }

# Keep Supabase / OkHttp / Retrofit
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep DIO
-keep class io.dio.** { *; }

# Prevent stripping of open_filex
-keep class com.crazecoder.openfile.** { *; }
