# icon_replance_csx

A new Flutter plugin project.

## Getting Started

### iOS 接入项目
建议使用 flutter_launcher_icons 生成icon比较便捷，可以将Assets里面需要的保存一份重命名成想要的名称，然后再执行命令“dart run flutter_launcher_icons”，新生成的icon资源会覆盖默认的AppIcon文件中的内容。
生成icon系列图标的名称（不能重复）

配置项目 在build setting里配置Include All App Icon Assets为YES，debug/release都需要设为yes，

### Android  接入项目
建议使用 flutter_launcher_icons 生成icon比较便捷，可以在运行命令“dart run flutter_launcher_icons”之前修改flutter_launcher_icons.yaml文件中的 android: "launcher_icon"，修改为想要生成的图片文件名成，eg：android: "launcher_icon_1".

1. 在app文件夹下的AndroidManifest.xml里面删除mainActivity
```dart
（<application>的<activity>里面）标签的<categoryandroid:name="android.intent.category.LAUNCHER" />属性

//但是这样会导致clean之后首次flutter run的时候flutter校验manifest报错，因为flutter_tools里面的android包文件application_package.dart校验只检查了activity标签里面的MAIN和LAUNCHER，不会校验activity-alias里面的（问题一直还在官方也未解决https://github.com/flutter/flutter/issues/38965）（这位网友解了一半未完成被关闭掉了https://github.com/flutter/flutter/pull/146548/commits），至此有两个解决方案：
1.运行前先执行一次build，或者先把activity标签里面MAIN和LAUNCHER都设置。然后再关掉之后再次run就绕过了mainfest的校验就不影响了。
2. 移除节点“tools:node="remove"”
把activity里面的LAUNCHER移除：<category android:name="android.intent.category.LAUNCHER" tools:node="remove"/>


```

2. 创建多个<activity-alias>,每一个的targetActivity没有特殊需要可以都指向mainActivity, android:label="",如果没有特殊变化应用名称则不需要配置，示例代码里面也没有设置
```xml
<activity-alias
            android:name=".AppIcon"
            android:enabled="true"
            android:exported="true"
            android:icon="@mipmap/launcher_icon"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
        <activity-alias
            android:name=".AppIcon1"
            android:enabled="false"
            android:exported="true"
            android:icon="@mipmap/launcher_icon1"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
        <activity-alias
            android:name=".AppIcon2"
            android:enabled="false"
            android:exported="true"
            android:icon="@mipmap/launcher_icon2"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
```


## 使用
```dart
IconReplanceCsx().changeIcon('icon1',aliasNames: ['AppIcon', 'AppIcon1', 'AppIcon2']);

/// 如果需要隐藏iOS系统的替换弹窗提示，可以在替换代码前执行
IconReplanceCsx().removeSysAlert();
```

## 安卓注意事项
activity-alias字段介绍地址：https://developer.android.google.cn/guide/topics/manifest/activity-alias-element.html?hl=zh-cn 

1. 权限：
确保您的应用具有足够的权限来更改组件状态。
2. 谨慎使用：
频繁更改应用图标和名称可能会使用户困惑，因此请谨慎使用这样的功能。

### 可能的坑
1. 动态替换icon，只能替换本地内置的icon，无法从服务器端获取来更新icon；(网易云音乐应该也是)
2. 动态替换icon以后，应用内更新的时候必须要切换到原始icon），否则可能导致更新安装失败(崩溃)(AS上表现为adb运行会失败)，或者升级后应用图标出现多个甚至应用图标都不显示的情况（可以通过下面【5】规则解决掉，所以这是一个坑点，不是肯定会发生的问题。）；
3. Android系统动态替换app icon会有延迟，在不同的手机系统上刷新icon的时间不一样，大概在10秒左右，在这个时间内点击icon会提示应用未安装(提示可能会有差别，有些厂商或者机型点了没有反应）；
4. 更换icon的代码运行后一会应用就闪退了，或者导致显示中的Dialog和PopupWindow报错崩溃（这个问题和第二个问题有很大的相关性，按下面【5】给出的规则实行的话是可以解决的。
5. 本地编译代码进行覆盖安装或者升级包会：
```
Error while executing: am start -n "com.heng.changeiconapp/com.heng.changeiconapp.MainActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
Starting: Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] cmp=com.xxxx.changeiconapp/.MainActivity }
Error type 3
Error: Activity class {com.heng.changeiconapp/com.xxxx.changeiconapp.MainActivity} does not exist.

Error while Launching activity
Failed to launch an application on all devices
```
要Clean Project。接着再选择 Rebuild Project，在设备上卸载旧版本的应用，然后重新安装新版本。

apk覆盖安装或者升级包无影响。

### 防坑专用
1. 关于 Activity 的 android:enabled 属性

不建议在代码中动态设置 Activity 的 android:enabled 属性。这种做法可能在图标切换过程中导致应用闪退，经过测试发现，小米、华为以及官方模拟器均存在此问题。

2. 清单文件中的 android:enabled 设置

在清单文件中将 Activity 的 android:enabled 属性设置为 false，并在后续版本中保持此值不变。如果在后续版本中将其设置为 true，可能会导致应用升级后出现多个图标的情况。

3. 设置默认的 Activity-alias

为应用配置一个默认的 Activity-alias，以确保图标的唯一显示。此设置可替代第一点中提到的将 Activity 的 android:enabled 设置为 false 可能导致桌面上无应用图标的问题。

4. Activity-alias 的动态管理

对于 android:enabled="true" 的默认显示项，尽量避免在中途进行更改。如果确实需要更新默认值，应通过代码进行动态管理。

5. 避免多个 Activity-alias

不要为 android:enabled="true" 的 Activity-alias 设置多个实例。若通过代码尝试隐藏其中一个或多个，可能会导致图标消失，此问题在第二点中已有提及。

6. 新版本中的 Activity-alias 设置

在后续版本中新增的 Activity-alias 必须设置 android:enabled="false"，并在清单文件中保持此值，然后通过代码动态更新。

7. 保留旧版本的 Activity-alias

新版本的 Activity-alias 必须包含所有旧版本的 Activity-alias，以防止在覆盖安装后出现应用图标消失或者崩溃的情况。

8. 关于 enabled=false 的 Activity 的限制

设置为 enabled=false 的 Activity 无法通过显式 Intent 进行调用，这将导致错误。例如，如果在应用中推送服务发送了打开 SplashActivity 的通知，而该 SplashActivity 设置为 enabled=false，则无法打开，并会出现错误日志。为避免此问题，建议将启动入口的 Activity 单独定义，确保其仅作为启动入口使用，避免被其他地方调用。
