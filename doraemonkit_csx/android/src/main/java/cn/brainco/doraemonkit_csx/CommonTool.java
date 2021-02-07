package cn.brainco.doraemonkit_csx;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.FeatureInfo;
import android.content.pm.PackageManager;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.os.Build;
import android.os.Debug;
import android.os.Environment;
import android.os.Process;
import android.os.StatFs;
import android.content.ContentResolver;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class CommonTool {
    private static final String TAG = "SystemUtil";

    private static final Pattern VERSION_NAME_PATTERN = Pattern.compile("(\\d+\\.\\d+\\.\\d+)-*.*");
    private static String sAppVersion;
    private static int sAppVersionCode = -1;
    private static String sPackageName;
    private static String sAppName;

    public static String getVersionName(Context context) {
        if (!TextUtils.isEmpty(sAppVersion)) {
            return sAppVersion;
        } else {
            String appVersion = "";
            try {
                String pkgName = context.getApplicationInfo().packageName;
                appVersion = context.getPackageManager().getPackageInfo(pkgName, 0).versionName;
                if (appVersion != null && appVersion.length() > 0) {
                    Matcher matcher = VERSION_NAME_PATTERN.matcher(appVersion);
                    if (matcher.matches()) {
                        appVersion = matcher.group(1);
                        sAppVersion = appVersion;
                    }
                }
            } catch (Throwable t) {
                Log.e(TAG, t.toString());
            }

            return appVersion;
        }
    }

    public static int getVersionCode(Context context) {
        if (sAppVersionCode != -1) {
            return sAppVersionCode;
        } else {
            int versionCode;

            try {
                String pkgName = context.getApplicationInfo().packageName;
                versionCode = context.getPackageManager().getPackageInfo(pkgName, 0).versionCode;
                if (versionCode != -1) {
                    sAppVersionCode = versionCode;
                }
            } catch (Throwable t) {
                Log.e(TAG, t.toString());
            }

            return sAppVersionCode;
        }
    }

    public static String getPackageName(Context context) {
        if (TextUtils.isEmpty(sPackageName)) {
            sPackageName = context.getPackageName();
        }
        return sPackageName;
    }

    public static String getAppName(Context context) {
        if (!TextUtils.isEmpty(sAppName)) {
            return sAppName;
        } else {
            PackageManager packageManager = null;
            ApplicationInfo applicationInfo = null;
            packageManager = context.getPackageManager();
            try {
                applicationInfo = packageManager.getApplicationInfo(context.getPackageName(), 0);
            } catch (PackageManager.NameNotFoundException e) {
                Log.e(TAG, e.toString());
            }
            sAppName = (String) packageManager.getApplicationLabel(applicationInfo);
            return sAppName;
        }
    }

    public static String obtainProcessName(Context context) {
        final int pid = android.os.Process.myPid();
        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> listTaskInfo = am.getRunningAppProcesses();
        if (listTaskInfo != null && !listTaskInfo.isEmpty()) {
            for (ActivityManager.RunningAppProcessInfo info : listTaskInfo) {
                if (info != null && info.pid == pid) {
                    return info.processName;
                }
            }
        }
        return null;
    }


    /**
     * 是否是系统main activity
     *
     * @return boolean
     */
    public static boolean isMainLaunchActivity(Activity activity) {
        PackageManager packageManager = activity.getApplication().getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(activity.getPackageName());
        if (intent == null) {
            return false;
        }
        ComponentName launchComponentName = intent.getComponent();
        ComponentName componentName = activity.getComponentName();
        if (launchComponentName != null && componentName.toString().equals(launchComponentName.toString())) {
            return true;
        }
        return false;
    }


    /**
     * 是否是系统启动第一次调用mainActivity 页面回退不算
     *
     * @return boolean
     */
//    public static boolean isOnlyFirstLaunchActivity(Activity activity) {
//        boolean isMainActivity = isMainLaunchActivity(activity);
//        ActivityLifecycleInfo activityLifecycleInfo = DoKitConstant.ACTIVITY_LIFECYCLE_INFOS.get(activity.getClass().getCanonicalName());
//        return activityLifecycleInfo != null && isMainActivity && !activityLifecycleInfo.isInvokeStopMethod();
//    }


    /**
     * 打开开发者模式界面 https://blog.csdn.net/ouzhuangzhuang/article/details/84029295
     */
    public static void startDevelopmentActivity(Context context) {
        try {
            Intent intent = new Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Exception e) {
            try {
                ComponentName componentName = new ComponentName("com.android.settings", "com.android.settings.DevelopmentSettings");
                Intent intent = new Intent();
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.setComponent(componentName);
                intent.setAction("android.intent.action.View");
                context.startActivity(intent);
            } catch (Exception e1) {
                try {
                    //部分小米手机采用这种方式跳转
                    Intent intent = new Intent("com.android.settings.APPLICATION_DEVELOPMENT_SETTINGS");
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);
                } catch (Exception e2) {
                    e2.printStackTrace();
                }

            }
        }
    }


    /**
     * 打开系统语言设置页面
     *
     * @param context
     */
    public static void startLocalActivity(Context context) {
        try {
            Intent intent = new Intent(Settings.ACTION_LOCALE_SETTINGS);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static final String[] EMPTY_STRING_LIST = new String[]{};

    public static Map<String, Object> getAndroidDeviceInfo(Context context, ContentResolver contentResolver, PackageManager packageManager) {
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
        build.put("androidId", getAndroidId(contentResolver));

        build.put("systemFeatures", Arrays.asList(getSystemFeatures(packageManager)));

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
        inflateDeviceRAM(storage, context);

        //设备ROM信息
        inflateDeviceROM(storage);

        //当前进程的总内存占用情况
        inflatePss(storage, context);

        //jvm内存使用情况
        inflateJvmMemory(storage);

        build.put("storage", storage);
        return build;
    }

    /**
     * Returns the Android hardware device ID that is unique between the device + user and app
     * signing. This key will change if the app is uninstalled or its data is cleared. Device factory
     * reset will also result in a value change.
     *
     * @return The android ID
     */
    @SuppressLint("HardwareIds")
    private static String getAndroidId(ContentResolver contentResolver) {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID);
    }

    /**
     * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy
     * detection systems
     */
    private static boolean isEmulator() {
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

    //    private PackageManager packageManager;
    private static String[] getSystemFeatures(PackageManager packageManager) {
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

    private static void inflateJvmMemory(Map<String, Object> storage) {
        long maxMem = Runtime.getRuntime().maxMemory();//当前虚拟机可用的最大内存
        long totalMem = Runtime.getRuntime().totalMemory();//当前虚拟机已分配的内存
        long freeMemory = Runtime.getRuntime().freeMemory();//当前虚拟机已分配内存中未使用的部分
        long currentMemUsage = totalMem - freeMemory;
        storage.put("jvmUseB", currentMemUsage);
        storage.put("jvmMaxB", maxMem);
        storage.put("jvmTotalB", totalMem);
        storage.put("jvmFreeB", freeMemory);
    }

    private static void inflateDeviceROM(Map<String, Object> storage) {
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

    private static void inflateDeviceRAM(Map<String, Object> storage, Context applicationContext) {
        ActivityManager activityManager = (ActivityManager) applicationContext.getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        storage.put("ramUseB", memoryInfo.totalMem - memoryInfo.availMem);
        storage.put("ramAllB", memoryInfo.totalMem);
        storage.put("ramAvailableB", memoryInfo.availMem);
        storage.put("ramThreshold", memoryInfo.threshold); // availMem 的阈值，低于此值系统会开始杀进程，后台服务
        storage.put("lowMemory", memoryInfo.lowMemory);// 是否为低内存
    }

    private static void inflatePss(Map<String, Object> storage, Context applicationContext) {
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


    /**
     * 打开正在运行的服务界面 https://www.jianshu.com/p/dd491235d113
     */
    public static void startServiceRunningActivity(Context context) {
        try {
            ComponentName componentName;
            if (getBrand().equalsIgnoreCase(PHONE_VIVO)) {
                componentName = new ComponentName("com.android.settings", "com.vivo.settings.VivoSubSettingsForImmersiveBar");
            } else {
                componentName = new ComponentName("com.android.settings", "com.android.settings.CleanSubSettings");
            }
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setComponent(componentName);
            intent.setAction("android.intent.action.View");
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static String getBrand() {
        return android.os.Build.BRAND;
    }

    /**
     * 手机品牌
     */
    // 小米
    public static final String PHONE_XIAOMI = "xiaomi";
    // 华为
    public static final String PHONE_HUAWEI = "HUAWEI";
    // 华为
    public static final String PHONE_HONOR = "HONOR";
    // 魅族
    public static final String PHONE_MEIZU = "Meizu";
    // 索尼
    public static final String PHONE_SONY = "sony";
    // 三星
    public static final String PHONE_SAMSUNG = "samsung";
    // LG
    public static final String PHONE_LG = "lg";
    // HTC
    public static final String PHONE_HTC = "htc";
    // NOVA
    public static final String PHONE_NOVA = "nova";
    // OPPO
    public static final String PHONE_OPPO = "oppo";
    // vivo
    public static final String PHONE_VIVO = "vivo";
    // 乐视
    public static final String PHONE_LeMobile = "LeMobile";
    // 联想
    public static final String PHONE_LENOVO = "lenovo";
}
