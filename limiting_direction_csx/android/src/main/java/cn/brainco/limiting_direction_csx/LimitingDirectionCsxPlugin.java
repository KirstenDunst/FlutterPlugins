package cn.brainco.limiting_direction_csx;

import static android.content.Context.*;
import android.content.Context;
//import android.hardware.Sensor;
//import android.hardware.SensorEvent;
//import android.hardware.SensorEventListener;
//import android.hardware.SensorManager;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * LimitingDirectionCsxPlugin
 */
// ,SensorEventListener
public class LimitingDirectionCsxPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native
    /// Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine
    /// and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    // private SensorManager mSensorManager;
    // private Sensor mAccelerometer;
    public static final float mGravity = 9.8f;
    // 屏幕旋转字符串
    private String orientationStr;
    // private Context applicationContext;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "limiting_direction_csx");
        channel.setMethodCallHandler(this);
        orientationStr = "0";
        // this.applicationContext = flutterPluginBinding.getApplicationContext();
        // mSensorManager = (SensorManager)
        // applicationContext.getSystemService(SENSOR_SERVICE);
        // mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        // mSensorManager.registerListener(this, mAccelerometer,
        // SensorManager.SENSOR_DELAY_NORMAL);
    }
    //
    // @Override
    // public void onAccuracyChanged(Sensor sensor, int accuracy) {
    // }

    // @Override
    // public void onSensorChanged(SensorEvent sensorEvent) {
    // float xValue = sensorEvent.values[0];// Acceleration minus Gx on the x-axis
    // float yValue = sensorEvent.values[1];//Acceleration minus Gy on the y-axis
    // float zValue = sensorEvent.values[2];
    // //Acceleration minus Gz on the z-axis
    // if (yValue > mGravity) {
    // //重力指向设备下边
    // orientationStr = "1";
    // } else if (yValue < -mGravity) {
    // //重力指向设备上边
    // orientationStr = "2";
    // } else if (xValue > mGravity) {
    // //重力指向设备左边
    // orientationStr = "3";
    // } else if (xValue < -mGravity) {
    // //重力指向设备右边
    // orientationStr = "4";
    // } else if (zValue > mGravity) {
    // //屏幕朝上
    // orientationStr = "5";
    // } else if (zValue < -mGravity) {
    // //屏幕朝下
    // orientationStr = "6";
    // }
    // channel.invokeMethod("orientationCallback", orientationStr);
    // }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getNowDeviceDirection")) {
            result.success(orientationStr);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        // mSensorManager.unregisterListener(this);
    }
}
