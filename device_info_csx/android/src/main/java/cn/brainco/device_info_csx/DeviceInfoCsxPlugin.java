package cn.brainco.device_info_csx;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.pm.FeatureInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * DeviceInfoCsxPlugin
 */
public class DeviceInfoCsxPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    /**
     * Substitute for missing values.
     */
    private static final String[] EMPTY_STRING_LIST = new String[]{};

    private ContentResolver contentResolver;
    private PackageManager packageManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "device_info_csx");
        this.contentResolver = flutterPluginBinding.getApplicationContext().getContentResolver();
        this.packageManager = flutterPluginBinding.getApplicationContext().getPackageManager();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getAndroidDeviceInfo")) {
            Map<String, Object> build = new HashMap<>();
            build.put("board", Build.BOARD);
            build.put("bootloader", Build.BOOTLOADER);
            build.put("brand", Build.BRAND);
            build.put("device", Build.DEVICE);
            build.put("display", Build.DISPLAY);
            build.put("fingerprint", Build.FINGERPRINT);
            build.put("hardware", Build.HARDWARE);
            build.put("host", Build.HOST);
            build.put("id", Build.ID);
            build.put("manufacturer", Build.MANUFACTURER);
            build.put("model", Build.MODEL);
            build.put("product", Build.PRODUCT);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                build.put("supported32BitAbis", Arrays.asList(Build.SUPPORTED_32_BIT_ABIS));
                build.put("supported64BitAbis", Arrays.asList(Build.SUPPORTED_64_BIT_ABIS));
                build.put("supportedAbis", Arrays.asList(Build.SUPPORTED_ABIS));
            } else {
                build.put("supported32BitAbis", Arrays.asList(EMPTY_STRING_LIST));
                build.put("supported64BitAbis", Arrays.asList(EMPTY_STRING_LIST));
                build.put("supportedAbis", Arrays.asList(EMPTY_STRING_LIST));
            }
            build.put("tags", Build.TAGS);
            build.put("type", Build.TYPE);
            build.put("isPhysicalDevice", !isEmulator());
            build.put("androidId", getAndroidId());

            build.put("systemFeatures", Arrays.asList(getSystemFeatures()));

            Map<String, Object> version = new HashMap<>();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                version.put("baseOS", Build.VERSION.BASE_OS);
                version.put("previewSdkInt", Build.VERSION.PREVIEW_SDK_INT);
                version.put("securityPatch", Build.VERSION.SECURITY_PATCH);
            }
            version.put("codename", Build.VERSION.CODENAME);
            version.put("incremental", Build.VERSION.INCREMENTAL);
            version.put("release", Build.VERSION.RELEASE);
            version.put("sdkInt", Build.VERSION.SDK_INT);
            build.put("version", version);

            Map<String, Object> storage = new HashMap<>();
            storage.put("ramUseB", getRamUseB());
            storage.put("ramAllB", getRamAllB());
            storage.put("romUseB", getRomUseB());
            storage.put("romAllB", getRomAllB());
            build.put("storage", storage);

            result.success(build);
        } else {
            result.notImplemented();
        }
    }

    /**
     * 已使用的ram，单位byte
     */
    private double getRamUseB() {
        return 0.0;
    }

    /**
     * 全部的ram容量，单位byte
     */
    private double getRamAllB() {
        return 0.0;
    }

    /**
     * 已使用的rom，单位byte
     */
    private double getRomUseB() {
        return 0.0;
    }

    /**
     * 全部的rom容量，单位byte
     */
    private double getRomAllB() {
        return 0.0;
    }

    private String[] getSystemFeatures() {
        FeatureInfo[] featureInfos = packageManager.getSystemAvailableFeatures();
        if (featureInfos == null) {
            return EMPTY_STRING_LIST;
        }
        String[] features = new String[featureInfos.length];
        for (int i = 0; i < featureInfos.length; i++) {
            features[i] = featureInfos[i].name;
        }
        return features;
    }

    /**
     * Returns the Android hardware device ID that is unique between the device + user and app
     * signing. This key will change if the app is uninstalled or its data is cleared. Device factory
     * reset will also result in a value change.
     *
     * @return The android ID
     */
    @SuppressLint("HardwareIds")
    private String getAndroidId() {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID);
    }

    /**
     * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy
     * detection systems
     */
    private boolean isEmulator() {
        return (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.PRODUCT.contains("sdk_google")
                || Build.PRODUCT.contains("google_sdk")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("sdk_x86")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.contains("emulator")
                || Build.PRODUCT.contains("simulator");
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }
}
