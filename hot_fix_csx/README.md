<!--
 * @Author: Cao Shixin
 * @Date: 2022-01-19 14:57:55
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-21 15:16:56
 * @Description: 
-->
# hot_fix_csx

The update of the project's large resource pack does not require the repair tool of the app's re-release.

## Getting Started
//首先设置基础参数
HotFixManager.setParam();
//然后调用启动函数(这里单独再开一个方法，而不是设置完之后自动执行，是为了方便开发调试，debug的时候留一个按钮调用这个方法开发测试)
HotFixManager.start();

//项目中的使用,监听资源更新流，实时获取最新的文件路径来使用
```
StreamBuilder(
        stream: HotFixManager.instance.refreshStream,
        builder: (context, snapData) {
                //这里便是热更新之后的可用资源目录，一般属于你的zip解压之后的手机本地文件夹目录地址,
                //需要注意的是：需要判断路径不为空的时候才有效。第一次的路径为默认参数值（空字符串）
          var localPath = HotFixManager.instance.availablePath;
          print('刷新路径:>>>>>>>>>>>$localPath');
           },
      ),
```


### 其他权限问题
1. For Android 需要支持本地文件的读写权限


## Alert
1.不要将重要的文件存储在：Android:({{getExternalStorageDirectory}}/HotFix/),iOS:({{getApplicationDocumentsDirectory}}/HotFix/)下面，避免版本升级的时候被此插件清理

## 其他关于项目可使用的工具类以及功能
```
import 'package:hot_fix_csx/hot_fix_csx.dart';
```
导入头文件还可以做下面这些事：

1. 资源下载工具（下载管理）
```
//常用的两个方法
//1.获取url对应的本地资源路径
var localPath = await ResourceProvider.instance
        .loadResource(ResourceModel(
            url: downloadUrl, name: '开星果大脑+apk', showDownloadList: true));
//2.批量下载资源到本地（预下载）,返回模型里面有需要的进度和状态等信息
var downloadModel = await ResourceProvider.instance.batchDownResource([resourceModel]);

// alert to user
1. 项目依赖flutter_downloader,所以需要其相关配置
2. 项目依赖bot_toast（主要在downloade_manager里面），所以需要相关配置
// 使用资源下载管理工具，记得在app启动的那些初始化的地方调用这两个方法初始化工具:
ResourceProvider.instance.initData();
await ResourceProvider.instance.loadBaseData();
```

2. 文件获取md5值(原生获取文件md5，减少flutter因大文件读取导致的内存问题)：
```
var md5Str = await Md5Helper.getFileMd5(filePath);
```

3. 项目资源拷贝到手机
```
var basePath = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getExternalStorageDirectory();
var baseZipPath = basePath!.path + '/origin_resource.zip';
var result = await HotFixCsx.copyResourceToDevice('dist.zip',baseZipPath);
```

4. 项目资源解压到手机本地
```
var basePath = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getExternalStorageDirectory();
var baseZipPath = basePath!.path + '/resource';
var result = await HotFixCsx.unzipResource('dist.zip',baseZipPath);
```

5. 普通本地文件解压到本地
```
ZipHelper.unZipFile(ConfigHelp.instance.getBaseZipPath(),
        PathOp.instance.baseDirectoryPath());
```

6. url中文字符转码形成一个新的url,针对iOS的相关路径加载问题需要
```
var newUri = UrlEncodeUtil.urlEncode('http:www.baidu.com/你猜猜.png');
```

7. 计算内存的显示，字节自动转换成对应的kb、m、g、t单位显示
```
var result = 1234567.byteFormat();
```

8. 获取当前代码的堆栈信息(工具)
```
TraceTool.nowClass();
TraceTool.nowMethod();
TraceTool.nowFile();
TraceTool.nowFileName();
TraceTool.nowLine();
```

