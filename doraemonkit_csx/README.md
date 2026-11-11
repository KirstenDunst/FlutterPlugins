# doraemonkit_csx

基于滴滴 [DoraemonKit](https://github.com/didi/DoraemonKit) 思路实现的 Flutter 研发调试工具集（纯 Flutter 实现，Android / iOS 双端可用）。

接入后单击悬浮球即可打开调试面板，内含性能检测、网络抓包与 Mock、日志、路由、方法通道、沙盒浏览等常用能力，并支持业务方注册自己的调试入口（BizKit）。

- 包名：`doraemonkit_csx`
- 支持平台：Android、iOS

## 特性一览

### 性能检测工具（APM）

| 工具 | 说明 |
| --- | --- |
| 网络请求 | 基于 dio 拦截器记录请求 Uri、Method、Header、Query、Body、状态码、耗时、响应体；长按单条记录可复制全文，右上角按钮可将该请求一键转为 Mock 规则 |
| 日志查看 | 通过 Zone 捕获 `print` 和未捕获异常，支持"只显示异常"过滤、长按复制、点击展开 |
| Mock | dio 请求级 Mock，支持按 path / 请求方式 / query / body 匹配，可开关、编辑、删除，配置持久化到本地 SharedPreferences |
| 帧率 | 采集 `FrameTiming`，展示最近 240 帧的耗时柱状图 |
| 内存 | 通过 VM Service 读取各 Isolate 的 Heap/External 占用，并支持输入类名查询对象数量与大小（release 模式不可用） |
| 路由信息 | 打印当前页面在每一层 Navigator 内的路由名称、参数及所在 Navigator |
| 方法通道 | 包装 `BinaryMessenger` 记录 Flutter 与原生之间的 MethodChannel / MessageChannel 调用及耗时，支持显示系统 Channel，支持黑名单过滤 |

### 基础工具（Common）

| 工具 | 平台 | 说明 |
| --- | --- | --- |
| 基本信息 | 全平台 | App 包名、版本号、设备信息；debug 下额外展示 CPU、Dart 版本、Flutter 版本、Isolate 列表 |
| 沙盒浏览 | 全平台 | 浏览应用沙盒目录与文件 |
| H5 任意门 | 全平台 | 内置 WebView，输入 / 扫码打开任意 H5，保存最多 10 条搜索历史 |
| 二维码生成器 | 全平台 | 输入文本生成二维码 |
| 清理缓存 | 全平台 | 查看并清理缓存数据 |
| UserDefaults | 全平台 | 查看 / 编辑 SharedPreferences（已过滤 `flutter.` 前缀，支持排序） |
| 开发者选项 | Android | 跳转系统开发者选项 |
| 本地语言 | Android | 跳转系统语言设置 |
| 应用设置 | iOS | 跳转 App 系统设置页 |

### 常驻工具 / 自定义工具

- 常驻工具：从"全部"页把图标拖入常驻区即可固定，最多 4 个，配置会持久化；面板底部即常驻工具 Tab。
- 自定义工具（BizKit）：业务方通过 `buildBizKit` / `newBizKit` / `addKit` / `addBizKits` 注册，可分组、可带分组提示文案，支持跳转自定义页面（`kitBuilder`）或仅执行动作（`action`）。

## 快速接入

### 1. 添加依赖

```yaml
dependencies:
  doraemonkit_csx:
    git:
      url: https://github.com/KirstenDunst/FlutterPlugins.git
      path: doraemonkit_csx
```

如使用网络请求面板 / Mock，需要同时引入 `dio`（本包已依赖，可直接使用）。

### 2. 改造入口

> 注意：入口 Widget 必须在主工程内声明（如 `MyApp`），否则 Flutter Inspector 的组件树会被折叠。
> 原因是 DoKit 需要用 `DoKitApp` 包一层，并用自定义 Binding 接管 root widget。

```dart
import 'package:doraemonkit_csx/csx_dokit.dart';
import 'package:doraemonkit_csx/page/dokit_app.dart';
import 'package:flutter/material.dart';

void main() {
  CsxDokit.run(
    app: DoKitApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
```

`CsxDokit.run` 也可用 `appCreator` 异步创建入口：

```dart
CsxDokit.run(appCreator: () async => DoKitApp(MyApp()));
```

`app` 与 `appCreator` 至少提供一个，否则断言失败。

### 3. 网络请求 / Mock 接入

给 `Dio` 实例添加拦截器即可自动记录请求，并让 Mock 规则生效：

```dart
import 'package:dio/dio.dart';
import 'package:doraemonkit_csx/engine/dio_log_interceptor.dart';

final dio = Dio()..interceptors.add(AppLogInterceptor());
```

在"网络请求"面板点击某条请求右上角的图标，可直接基于该请求生成 Mock 规则；也可在 "Mock" 面板手动新增。规则按 path、method、query、body 匹配（body 为 json 时采用"包含匹配"），命中的请求会被直接 resolve 为配置的假数据，并在列表中标记 `[Mock]`。

### 4. 注册自定义调试入口

```dart
// 直接注册一个点击后执行动作的入口
CsxDokit.i.buildBizKit(
  name: '切换环境',
  group: '业务专区',
  desc: '开发期环境切换',
  action: () => debugPrint('switch env'),
);

// 注册一个点击后跳转自定义页面的入口
CsxDokit.i.buildBizKit(
  name: '调试页',
  group: '业务专区',
  kitBuilder: () => const MyDebugPage(),
);

// 分组提示文案
CsxDokit.i.updateKitGroupTip('业务专区', '仅 debug 环境可见');

// 批量注册
final kits = [
  CsxDokit.i.newBizKit(name: 'A', group: '业务专区'),
  CsxDokit.i.newBizKit(name: 'B', group: '业务专区'),
];
CsxDokit.i.addBizKits(kits);
```

同一个 key / 同名同组同图标的 kit 不可重复注册（会触发断言）。

### 5. 其他常用能力

```dart
// 监听 doKit 面板展开 / 收起
CsxDokit.i.isDoKitPageShow((bool isShow) {});

// 显隐入口悬浮球
CsxDokit.i.switchEntrance(false);

// 轻提示（走 doKit 自己的 Overlay，不受宿主 SnackBar 影响）
CsxDokit.i.toastC('已保存');
```

## API 说明

### CsxDokit.run

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `app` | `DoKitApp?` | `null` | 包装后的入口 Widget，与 `appCreator` 二选一 |
| `appCreator` | `Future<IDoKitApp> Function()?` | `null` | 异步创建入口 Widget |
| `useRunZoned` | `bool` | `true` | 是否使用 `runZonedGuarded` 接管 `print` 与未捕获异常；关闭后日志面板不再自动采集 `print` |
| `useInRelease` | `bool` | `false` | release 模式下是否仍然启用 doKit。默认 `false`，即 release 包不注入任何调试能力（走原始 `runApp`） |
| `logCallback` | `Function(String)?` | `null` | 每条日志的回调。**回调内不要调用 `print`**，否则会循环捕获 |
| `exceptionCallback` | `Function(dynamic, StackTrace)?` | `null` | 未捕获异常回调 |
| `methodChannelBlackList` | `List<String>` | `[]` | 不记录的方法通道名，如高频的传感器 channel |
| `releaseAction` | `VoidCallback?` | `null` | release 模式下的自定义启动逻辑，优先级最高（不走 doKit） |
| `showEntrance` | `bool` | `true` | 是否展示入口悬浮球 |

### 扩展点

- `ApmKitManager.instance.addKit(tag, kit)`：覆盖 / 扩展内置 APM 工具（继承 `ApmKit` 实现 `start` / `stop` / `createStorage` / `createDisplayPage`）。
- `CommonKitManager.instance.addKit(tag, kit)`：扩展基础工具（继承 `CommonKit`）。
- `CsxDokit.i.buildBizKit / newBizKit / addKit / addBizKits`：业务自定义工具。

## 注意事项

- **内存、基本信息（VM 部分）依赖 VM Service**，仅在 debug / profile 可运行模式下有数据；release 包中 `Service.getInfo().serverUri` 为 `null`，页面会提示"获取数据失败"。
- **默认 release 不启用**：`useInRelease: false` 时 release 包只执行原始入口，不会插入悬浮球，也不会接管日志。若需要在 release 包中验证，请显式传 `useInRelease: true`，并在发版前移除。
- **性能影响**：方法通道面板通过包装 `BinaryMessenger` 实现，会拦截所有通道调用；高频通道（传感器、动画相关）请加入 `methodChannelBlackList`。日志 / 网络 / 方法通道的记录条数均有上限（如网络 60 条、日志 120 条、通道 240 条），超出自动淘汰旧数据。
- **入口重复添加**：`switchEntrance(true)` 做了去重，重复调用不会产生多个悬浮球。
- **Navigator 观测**：`DoKitApp` 在宿主为 `StatelessWidget` 且存在 `MaterialApp` 时会自动补充 `CsxKitNavObserver`；如果宿主结构较特殊（嵌套 Navigator、自建 App），手动添加 `CsxKitNavObserver` 到 `navigatorObservers` 更稳妥。
- **Android 16 / 16KB 页设备**：如遇启动即崩溃，优先检查 Flutter SDK（建议 3.27+）与所有原生依赖是否已支持 16 KB page size。


## License

见 [LICENSE](LICENSE)。
