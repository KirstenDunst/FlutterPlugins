# background_alive_csx

Short time maintenance treatment in the background:


## Methods

**iOS:** Background audio playback to preserve processing operations, other push, VOIP and other functions of the special background processing do not use this processing method to ensure the background alive.

**Android:** 


## Project configuration
**iOS**
1.需要打开支持后台模式
在主项目的info.plist中添加
```
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
	<string>fetch</string>
</array>
```
或者在xcode打开主项目的Signing&Capabilities下的Background Modes下勾选上两个对勾（Audio、Airplay、and Picture in Picture和Background fetch）
![ios配置图片](https://github.com/KirstenDunst/FlutterPlugins/blob/main/background_alive_csx/iosConfiguration.png)

2.第一次发布AppStore的时候需要提供使用后台的场景视频介绍，不然审核会被拒掉。



## Instruction For Use
```
/// 在需要的地方开启
await BackgroundAliveCsx.keepBackgroundAlive();
```

