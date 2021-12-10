<!--
 * @Author: Cao Shixin
 * @Date: 2021-12-10 09:13:35
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-12-10 11:33:58
 * @Description: 
-->
# common_plugin_csx

A small collection of generic plug-ins.

## Getting Started

### 1.添加文件md5的计算
```
For Android:
在manifest中添加权限
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
For iOS: 不需要额外配置
```
```
使用：
var md5Str = await CommonPluginCsx.getFileMd5(pickedFile.path);
```

