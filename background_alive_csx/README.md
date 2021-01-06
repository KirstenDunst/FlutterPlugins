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
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //自动处理后台保活机制
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        BackgroundAliveCsx.stopBackgroundTask();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        BackgroundAliveCsx.openBackgroundTask();
        break;
      case AppLifecycleState.detached: // 申请将暂时停止
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
	  // 手动处理后台保活机制
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Text('手动开启后台保活'),
                onTap: () async {
                  await BackgroundAliveCsx.openBackgroundTask();
                },
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                child: Text('手动结束结束保活'),
                onTap: () async {
                  await BackgroundAliveCsx.stopBackgroundTask();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

