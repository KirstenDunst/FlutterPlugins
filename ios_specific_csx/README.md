# ios_specific_csx

旨在专注于iOS特有方面的插件开发

## Getting Started

### 项目配置
主项目的info.plist引入权限配置描述信息
![health配置信息](https://github.com/KirstenDunst/FlutterPlugins/tree/main/ios_specific_csx/plist.png)
在项目中添加HealthKit的capability并勾选（这里还需要生成相应的配置文件和相关的证书，自动签名的话可以忽略这里的提醒证书配置问题）
![health capability](https://github.com/KirstenDunst/FlutterPlugins/tree/main/ios_specific_csx/config.png)

### 插件代码使用方法

1.加入到健康的正念训练
```flutter
//添加正念时长，返回结果：是否成功，以及失败的原因
IosSpecificCsx.addHealthMindfulness(
                        DateTime(2021, 3, 26, 14, 10),
                        DateTime(2021, 3, 26, 14, 20))
                    .then((result) {
                  print('mindfulness加入结果：${result.toJson()}');
                });
```
```flutter
//获取健康正念的操作权限
IosSpecificCsx.getHealthAuthorityStatus(
                        HealthAppSubclassification.Mindfulness)
                    .then((result) {
                  print('mindfulness权限：$result');
                });
```
