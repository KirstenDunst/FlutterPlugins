<!--
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:10:47
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-18 11:18:45
 * @Description: 
-->
# limiting_direction_csx
flutter强制某些界面横屏，特殊界面--特殊的可支持设备旋转方位。解决目前所有的flutter不能操作iOS的问题！

支持内部陀螺仪读取设备的当前偏向：上、下、左、右、倒扣、正向朝上。的6个方位(注意：陀螺仪的使用需要取消屏幕锁定)

（注意：根据使用的功能做相应的配置，不用到的功能可以不用配置直接使用代码即可；）


# iOS项目横屏使用配置
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


# 设备陀螺仪读取（这个无需配置）
```
//直接读取当前陀螺仪方位（直接读取不建议使用在项目刚启动的地方）：
LimitingDirectionCsx().currentDeviceOrientation

//流的方式监听陀螺仪：LimitingDirectionCsx().getDeviceDirectionStream()
StreamBuilder<UIDeviceOrientation>(
            stream: LimitingDirectionCsx().getDeviceDirectionStream(),
            builder: (context, AsyncSnapshot snapshot) {
              return Text('结果：${snapshot.data}');
            },
          )

//future的方式主动一次性获取陀螺仪转向
LimitingDirectionCsx().getNowDeviceDirection();

```
