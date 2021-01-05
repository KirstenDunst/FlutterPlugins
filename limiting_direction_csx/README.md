<!--
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:10:47
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 15:38:27
 * @Description: 
-->
# limiting_direction_csx
flutter强制某些界面横屏，特殊界面--特殊的可支持设备旋转方位。解决目前所有的flutter不能操作iOS的问题！


# iOS项目配置
## 1.调整主项目的info.plist文件添加
```
<key>UIRequiresFullScreen</key>
<true/>
```
(即xcode打开iOS项目，勾选中Targets->General->Deployment Info->Requires full screen(前面选中打勾☑️))
(这个配置主要针对pad的适配，需要添加，单纯的手机应用开发，这个配置可以不用勾选就可以实现其效果)

## 2.主项目的Main.storyboard的控制器类型class从FlutterViewController调整为MainViewController
![ios配置Main.storyboard，图片在根目录下的iosConfiguration.png](https://github.com/KirstenDunst/FlutterPlugins/blob/main/limiting_direction_csx/iosConfiguration.png)


# 使用代码介绍
```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    // 设置启动即强制横屏
    await LimitingDirectionCsx.setUpScreenDirection(
        DeviceDirectionMask.Landscape);
  } else {
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }
  runApp(MyApp());
}
```
```
//或者在需要的地方调用
if (Platform.isIOS) {
  await LimitingDirectionCsx.setUpScreenDirection(
      DeviceDirectionMask.Landscape);
}
//来设置枚举类型，选择自己想要的可支持方位
```

