package cn.brainco.limiting_direction_csx;

import androidx.appcompat.app.AppCompatActivity;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity implements SensorEventListener {
    private SensorManager mSensorManager;
    private Sensor mAccelerometer;
    public static final float mGravity = 9.8f;
    //屏幕旋转字符串
    private String orientationStr;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    }

    @Override
    protected void onResume() {
        super.onResume();
        mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_NORMAL);
    }

    @Override
    protected void onPause() {
        super.onPause();
        mSensorManager.unregisterListener(this);
    }
   @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        Log.d("","触发了");
        float xValue = sensorEvent.values[0];// Acceleration minus Gx on the x-axis
        float yValue = sensorEvent.values[1];//Acceleration minus Gy on the y-axis
        float zValue = sensorEvent.values[2];
        orientationStr = "0";//Acceleration minus Gz on the z-axis
        if (yValue > mGravity) {
            //重力指向设备下边
            orientationStr = "1";
        } else if (yValue < -mGravity) {
            //重力指向设备上边
            orientationStr = "2";
        } else if (xValue > mGravity) {
            //重力指向设备左边
            orientationStr = "3";
        } else if (xValue < -mGravity) {
            //重力指向设备右边
            orientationStr = "4";
        } else if (zValue > mGravity) {
            //屏幕朝上
            orientationStr = "5";
        } else if (zValue < -mGravity) {
            //屏幕朝下
            orientationStr = "6";
        }
        channel.invokeMethod("orientationCallback", orientationStr);
    }
}