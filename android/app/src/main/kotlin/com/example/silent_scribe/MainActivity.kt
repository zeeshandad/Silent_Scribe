package com.example.silent_scribe

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.pathprovider.PathProviderPlugin
import com.llfbandit.record.RecordPlugin
import net.nativemind.flutter_llama.FlutterLlamaPlugin
import com.antonkarpenko.ffmpegkit.FFmpegKitFlutterPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Explicitly register all plugins to prevent MissingPluginException in release builds
        try {
            val registry = flutterEngine.getPlugins()
            
            // Record Plugin
            if (!registry.has(RecordPlugin::class.java)) {
                registry.add(RecordPlugin())
            }
            
            // Path Provider Plugin
            if (!registry.has(PathProviderPlugin::class.java)) {
                registry.add(PathProviderPlugin())
            }
            
            // Flutter Llama Plugin
            if (!registry.has(FlutterLlamaPlugin::class.java)) {
                registry.add(FlutterLlamaPlugin())
            }
            
        } catch (e: Exception) {
            // Log error if needed
        }
    }
}
