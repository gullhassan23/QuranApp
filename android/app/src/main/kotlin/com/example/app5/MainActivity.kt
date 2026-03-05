package com.example.app5

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSplashScreen().setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }
        super.onCreate(savedInstanceState)
    }
}
