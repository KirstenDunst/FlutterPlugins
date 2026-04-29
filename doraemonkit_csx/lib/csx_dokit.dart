import 'dart:async';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'apm/crash_kit.dart';
import 'apm/log_kit.dart';
import 'common/biz.dart';
import 'engine/dokit_binding.dart';
import 'model/dokit_model.dart';
import 'page/dokit_app.dart';
import 'page/dokit_btn.dart';
import 'page/kit_manage.dart';
import 'utils/file_operation.dart';
import 'utils/time_util.dart';

const String dkPackageName = 'doraemonkit_csx';
const String dkPackageVersion = '1.0.1+1';

//记录当前zone
Zone? _zone;

typedef CustomCallback = Function(BuildContext context, dynamic value);

class CsxDokit {
  // 初始化方法,app或者appCreator必须设置一个
  static Future<void> run(
      {DoKitApp? app,
      bool useRunZoned = true,
      Future<IDoKitApp> Function()? appCreator,
      bool useInRelease = false,
      Function(String)? logCallback,
      Function(dynamic, StackTrace)? exceptionCallback,
      List<String> methodChannelBlackList = const <String>[],
      Function? releaseAction}) async {
    assert(
        app != null || appCreator != null, 'app and appCreator are both null');
    if (kReleaseMode && !useInRelease) {
      if (releaseAction != null) {
        releaseAction.call();
      } else {
        if (app != null) {
          runApp(app.origin);
        } else {
          runApp((await appCreator!()).origin);
        }
      }
      return;
    }
    blackList = methodChannelBlackList;

    if (!useRunZoned) {
      await runZonedGuarded(
        () async => <void>{
          _ensureDoKitBinding(app ?? await appCreator!(),
              useInRelease: useInRelease),
          _zone = Zone.current
        },
        (Object obj, StackTrace stack) {
          _collectError(obj, stack);
          if (exceptionCallback != null) {
            _zone?.runBinary(exceptionCallback, obj, stack);
          }
        },
        zoneSpecification: ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
            _collectLog(line); //手机日志
            parent.print(zone, line);
            if (logCallback != null) {
              _zone?.runUnary(logCallback, line);
            }
          },
        ),
      );
    } else {
      Future<Set<void>> f() async => {
            _ensureDoKitBinding(app ?? await appCreator!(),
                useInRelease: useInRelease),
            _zone = Zone.current
          };
      await f();
    }
  }

  /// 暴露出来的除[run]外的所有接口
  static final i = _DoKitInterfaces._instance;
}

abstract class IDoKit {/* Just empty. */}

class _DoKitInterfaces extends IDoKit with _BizKitMixin, _LeaksDoctorMixin {
  _DoKitInterfaces._();

  static final _DoKitInterfaces _instance = _DoKitInterfaces._();

  BuildContext? get overlayContext => doKitOverlayKey.currentState?.context;

  Function(bool)? callback;
  Function(String)? toast;
  //记录外附回调
  Map<DokitCallType, CustomCallback>? doCustomCallMap;

  /// doKit是否打开了页面（只要是通过doKit打开的页面）
  void isDoKitPageShow(Function(bool)? callback) => this.callback = callback;

  void toastCall(Function(String)? callback) => toast = callback;

  // 自定义显示回调
  void addCustomCallMap(Map<DokitCallType, CustomCallback>? customCallMap) =>
      doCustomCallMap = customCallMap;
}

mixin _BizKitMixin on IDoKit {
  /// 更新group信息，详见[addKitGroupTip]
  void updateKitGroupTip(String name, String tip) {
    BizKitManager.instance.updateBizKitGroupTip(name, tip);
  }

  /// 详见[addBizKit]
  void addKit<S extends BizKit>({String? key, required S kit}) {
    BizKitManager.instance.addBizKit<S>(key, kit);
  }

  /// 详见[addBizKits]
  void addBizKits(List<BizKit> bizKits) {
    BizKitManager.instance.addBizKits(bizKits);
  }

  /// 创建BizKit对象
  T newBizKit<T extends BizKit>(
      {String? key,
      required String name,
      String? icon,
      required String group,
      String? desc,
      KitPageBuilder? kitBuilder,
      Function? action}) {
    return BizKitManager.instance.createBizKit(name, group,
        key: key,
        icon: icon,
        desc: desc,
        action: action,
        kitBuilder: kitBuilder);
  }

  /// [key] kit的唯一标识，全局不可重复，不传则默认使用[BizKit._defaultKey];
  /// [name] kit显示的名字;
  /// [icon] kit的显示的图标，不传则使用默认图标;
  /// [group] kit归属的组，如果该组不存在，则会自动创建;
  /// [desc] kit的描述信息，不会以任何形式显示出来;
  /// [kitBuilder] kit对应的页面的WidgetBuilder，点击该kit的图标后跳转到的Widget页面，不要求有Navigator，详见[BizKit.tapAction].
  void buildBizKit(
      {String? key,
      required String name,
      String? icon,
      required String group,
      String? desc,
      KitPageBuilder? kitBuilder,
      Function? action}) {
    BizKitManager.instance.buildBizKit(name, group,
        key: key,
        icon: icon,
        desc: desc,
        kitBuilder: kitBuilder,
        action: action);
  }
}

mixin _LeaksDoctorMixin on IDoKit {
  // // 初始化内存泄漏检测功能
  // void initLeaks(BuildContext Function() func,
  //     {int maxRetainingPathLimit = 300}) {
  //   LeaksDoctor().init(func, maxRetainingPathLimit: maxRetainingPathLimit);
  // }

  // // 监听内存泄漏结果数据
  // void listenLeaksData(Function(LeaksMsgInfo? info)? callback) {
  //   LeaksDoctor().onLeakedStream.listen((LeaksMsgInfo? info) {
  //     // print((info?.toString()) ?? '暂未发现泄漏');
  //     // print('发现泄漏对象实例个数 = ${(info?.leaksInstanceCounts) ?? "0"}');
  //     if (callback != null) {
  //       callback(info);
  //     }
  //   });
  // }

  // // 监听内存泄漏节点事件
  // void listenLeaksEvent(Function(LeaksDoctorEvent event)? callback) {
  //   LeaksDoctor().onEventStream.listen((LeaksDoctorEvent event) {
  //     if (callback != null) {
  //       callback(event);
  //     }
  //   });
  // }

  // // 添加要观察的对象
  // void addObserved(Object obj,
  //     {String group = 'manual', int? expectedTotalCount}) {
  //   LeaksDoctor()
  //       .addObserved(obj, group: group, expectedTotalCount: expectedTotalCount);
  // }

  // // 触发内存泄漏扫描
  // void scanLeaks({String? group, int delay = 500}) {
  //   LeaksDoctor().memoryLeakScan(group: group, delay: delay);
  // }

  // // 显示泄漏信息汇总页面
  // void showLeaksInfoPage() {
  //   LeaksDoctor().showLeaksPageWhenClick();
  // }
}

// 如果在runApp之前执行了WidgetsFlutterBinding.ensureInitialized，会导致methodchannel功能不可用，可以在runApp前先调用一下ensureDoKitBinding
void _ensureDoKitBinding(IDoKitApp wrapper, {bool useInRelease = false}) {
  if (!kReleaseMode || useInRelease) {
    DoKitWidgetsFlutterBinding.ensureInitialized();
  }
  var binding = DoKitWidgetsFlutterBinding.ensureInitialized();
  if (binding != null) {
    var defaultWidget = binding.wrapWithDefaultView(wrapper);
    binding.attachRootWidget(defaultWidget);
    binding.scheduleWarmUpFrame();
  }
  addEntrance();
}

void _collectLog(String line) {
  LogManager.instance.addLog(LogBean.typeInfo, line);
}

void _collectError(Object? details, Object? stack) {
  LogManager.instance.addLog(
      LogBean.typeError, '${details?.toString()}\n${stack?.toString()}');
  if (CrashLogManager.instance.crashSwitch) {
    var dateTime = DateTime.now();
    FileUtil.shared.writeCounter('carshDoc',
        '[${TimeUtils.toDateString(dateTime.millisecondsSinceEpoch)}] ${details.toString()}\n${stack.toString()}');
  }
}

void addEntrance() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final floatBtn = DoKitBtn(CsxDokit.i.callback);
    floatBtn.addToOverlay();
    KitPageManager.instance.loadCache();
  });
}

void dispose(BuildContext context) {
  doKitOverlayKey.currentState?.widget.initialEntries
      .forEach((element) => element.remove());
}
