package com.aiche.aiche

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import me.carda.awesome_notifications.AwesomeNotificationsPlugin
import android.os.Bundle

class MainActivity: FlutterActivity() {
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // AwesomeNotifications plugin is automatically registered in newer versions
        // No need to call setLicenseKey() as it's deprecated
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
