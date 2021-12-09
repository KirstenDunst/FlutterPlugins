package cn.brainco.device_info_csx;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.FeatureInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Debug;
import android.os.Environment;
import android.os.Process;
import android.os.StatFs;
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
    private Context applicationContext;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "device_info_csx");
        this.contentResolver = flutterPluginBinding.getApplicationContext().getContentResolver();
        this.packageManager = flutterPluginBinding.getApplicationContext().getPackageManager();
        this.applicationContext = flutterPluginBinding.getApplicationContext();
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

            //设备RAM信息
            inflateDeviceRAM(storage);

            //设备ROM信息
            inflateDeviceROM(storage);

            //当前进程的总内存占用情况
            inflatePss(storage);

            //jvm内存使用情况
            inflateJvmMemory(storage);

            build.put("storage", storage);
            result.success(build);
        } else {
            result.notImplemented();
        }
    }

    private void inflateJvmMemory(Map<String, Object> storage) {
        long maxMem = Runtime.getRuntime().maxMemory();//当前虚拟机可用的最大内存
        long totalMem = Runtime.getRuntime().totalMemory();//当前虚拟机已分配的内存
        long freeMemory = Runtime.getRuntime().freeMemory();//当前虚拟机已分配内存中未使用的部分
        long currentMemUsage = totalMem - freeMemory;
        storage.put("jvmUseB", currentMemUsage);
        storage.put("jvmMaxB", maxMem);
        storage.put("jvmTotalB", totalMem);
        storage.put("jvmFreeB", freeMemory);
    }

    private void inflateDeviceROM(Map<String, Object> storage) {
        StatFs statFs = new StatFs(Environment.getDataDirectory().getPath());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            long totalCounts = statFs.getBlockCountLong();
            long availableCounts = statFs.getAvailableBlocksLong();
            long size = statFs.getBlockSizeLong();
            long availROMSize = availableCounts * size;
            long totalROMSize = totalCounts * size;
            storage.put("romAllB", totalROMSize);
            storage.put("romUseB", totalROMSize - availROMSize);
        } else {
            long totalCounts = statFs.getBlockCount();
            long availableCounts = statFs.getAvailableBlocks();
            long size = statFs.getBlockSize();
            long availROMSize = availableCounts * size;
            long totalROMSize = totalCounts * size;
            storage.put("romAllB", totalROMSize);
            storage.put("romUseB", totalROMSize - availROMSize);
        }
    }

    private void inflateDeviceRAM(Map<String, Object> storage) {
        ActivityManager activityManager = (ActivityManager) applicationContext.getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        storage.put("ramUseB", memoryInfo.totalMem - memoryInfo.availMem);
        storage.put("ramAllB", memoryInfo.totalMem);
        storage.put("ramAvailableB", memoryInfo.availMem);
        storage.put("ramThreshold", memoryInfo.threshold); // availMem 的阈值，低于此值系统会开始杀进程，后台服务
        storage.put("lowMemory", memoryInfo.lowMemory);// 是否为低内存
    }

    private void inflatePss(Map<String, Object> storage) {
        ActivityManager activityManager = (ActivityManager) applicationContext.getSystemService(Context.ACTIVITY_SERVICE);
        Debug.MemoryInfo[] memInfo = activityManager.getProcessMemoryInfo(new int[]{Process.myPid()});
        if (memInfo.length > 0) {
            //AndroidQ 版本对这个 API 增加了限制，当采样率较高时，会一直返回一个相同的值
            //包括了虚拟机的内存占用情况，还包括原生层和其它内存占用，这也是在手机连接至电脑时，使用 ADB 指令查看到的内存占用信息。
            // TotalPss = dalvikPss + nativePss + otherPss, in KB
            Debug.MemoryInfo info = memInfo[0];
            long totalPss = info.getTotalPss();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Map<String, String> memoryStats = info.getMemoryStats();
                int other = Integer.parseInt(memoryStats.get("summary.private-other"));
                storage.put("summaryJavaHeap", Integer.parseInt(memoryStats.get("summary.java-heap")) << 10);
                storage.put("summaryNativeHeap", Integer.parseInt(memoryStats.get("summary.native-heap")) << 10);
                storage.put("summaryCode", Integer.parseInt(memoryStats.get("summary.code")) << 10);
                storage.put("summaryStack", Integer.parseInt(memoryStats.get("summary.stack")) << 10);
                storage.put("summaryGraphics", Integer.parseInt(memoryStats.get("summary.graphics")) << 10);
                storage.put("summaryPrivateOther", Integer.parseInt(memoryStats.get("summary.private-other")) << 10);
                storage.put("summarySystem", Integer.parseInt(memoryStats.get("summary.system")) << 10);
                storage.put("summaryTotalSwap", Integer.parseInt(memoryStats.get("summary.total-swap")) << 10);
            }
            storage.put("totalPssB", totalPss << 10);
        }
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
