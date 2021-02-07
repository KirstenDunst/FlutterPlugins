/*
 * @Author: Cao Shixin
 * @Date: 2021-02-04 17:28:14
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-05 14:34:41
 * @Description:
 */
package cn.brainco.doraemonkit_csx;

import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * DoraemonkitCsxPlugin
 */
public class DoraemonkitCsxPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;
    private ContentResolver contentResolver;
    private PackageManager packageManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        contentResolver = flutterPluginBinding.getApplicationContext().getContentResolver();
        packageManager = flutterPluginBinding.getApplicationContext().getPackageManager();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "doraemonkit_csx");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("openDeveloperOptions")) {
            CommonTool.startDevelopmentActivity(context);
        } else if (call.method.equals("openLocalLanguagesPage")) {
            CommonTool.startLocalActivity(context);
        } else if (call.method.equals("getAndroidDeviceInfo")) {
            result.success(CommonTool.getAndroidDeviceInfo(context, contentResolver, packageManager));
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
