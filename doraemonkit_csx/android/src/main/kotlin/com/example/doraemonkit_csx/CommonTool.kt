package com.example.doraemonkit_csx

import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.content.ComponentName
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.FeatureInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.os.Environment
import android.os.Process
import android.os.StatFs
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import java.util.Arrays
import java.util.HashMap
import java.util.regex.Pattern

object CommonTool {
    private const val TAG = "SystemUtil"

    private val VERSION_NAME_PATTERN = Pattern.compile("(\\d+\\.\\d+\\.\\d+)-*.*")
    private var sAppVersion: String? = null
    private var sAppVersionCode = -1
    private var sPackageName: String? = null
    private var sAppName: String? = null

    fun startDevelopmentActivity(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            try {
                val componentName = ComponentName("com.android.settings", "com.android.settings.DevelopmentSettings")
                val intent = Intent().apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    component = componentName
                    action = "android.intent.action.View"
                }
                context.startActivity(intent)
            } catch (e1: Exception) {
                try {
                    val intent = Intent("com.android.settings.APPLICATION_DEVELOPMENT_SETTINGS").apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    context.startActivity(intent)
                } catch (e2: Exception) {
                    e2.printStackTrace()
                }
            }
        }
    }

    fun startLocalActivity(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_LOCALE_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
