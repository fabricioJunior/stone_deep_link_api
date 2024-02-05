package com.example.stone_deep_link_example

import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mainDeeplinkChannel"
    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        this.flutterEngine = flutterEngine
    }



    private fun handleDeepLinkResponse(intent: Intent) {
        try {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("pagamentoFinalizado",  intent.data.toString())

            Log.i("onNewIntent", intent?.data.toString())
            if (intent?.data != null) {
                Toast.makeText(this, intent.data.toString(), Toast.LENGTH_LONG).show()
                Log.i("DeeplinkPay Response", intent.data.toString())
            }
        } catch (e: Exception) {
            Toast.makeText(this, e.toString(), Toast.LENGTH_LONG).show()
            Log.e("Deeplink error", e.toString())
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)


        if (intent.action === Intent.ACTION_VIEW) {
            handleDeepLinkResponse(intent)
        }
    }
}
