# Keep Flutter and plugin classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.llfbandit.record.** { *; }
-keep class net.nativemind.flutter_llama.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JNI entry points for FFmpeg and others
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.example.silent_scribe.** { *; }
