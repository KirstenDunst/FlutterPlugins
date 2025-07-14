# icon_replance_csx

A new Flutter plugin project.

## Getting Started

### iOS 接入项目
建议使用 flutter_launcher_icons 生成icon比较便捷，可以将Assets里面需要的保存一份重命名成想要的名称，然后再执行命令“dart run flutter_launcher_icons”，新生成的icon资源会覆盖默认的AppIcon文件中的内容。
生成icon系列图标的名称（不能重复）

配置项目 在build setting里配置Include All App Icon Assets为YES，debug/release都需要设为yes，

### Android  接入项目
建议使用 flutter_launcher_icons 生成icon比较便捷，可以在运行命令“dart run flutter_launcher_icons”之前修改flutter_launcher_icons.yaml文件中的 android: "launcher_icon"，修改为想要生成的图片文件名成，eg：android: "launcher_icon_1".

1. 在app文件夹下的AndroidManifest.xml里面删除mainActivity（<application>的<activity>里面）标签的<categoryandroid:name="android.intent.category.LAUNCHER" />属性

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
