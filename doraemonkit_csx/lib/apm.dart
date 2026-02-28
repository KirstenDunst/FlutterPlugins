import 'package:flutter/material.dart';

import 'apm/crash_kit.dart';
import 'apm/fps_kit.dart';
import 'apm/http_kit.dart';
import 'apm/log_kit.dart';
import 'apm/memory_kit.dart';
import 'apm/method_channel_kit.dart';
import 'apm/route_kit.dart';
import 'apm/source_code_kit.dart';
import 'kit.dart';
import 'page/kits_page.dart';

class ApmKitManager {
  Map<String, ApmKit> kitMap = { ApmKitName.kitLog: LogKit(),
    ApmKitName.kitChannel: MethodChannelKit(),
    ApmKitName.kitRoute: RouteKit(),
    ApmKitName.kitFps: FpsKit(),
    ApmKitName.kitMemory: MemoryKit(),
    ApmKitName.kitHttp: HttpKit(),
    ApmKitName.kitSourceCode: SourceCodeKit(),
    ApmKitName.kitCarsh: CrashKit()};

  ApmKitManager._privateConstructor();

  static final ApmKitManager _instance = ApmKitManager._privateConstructor();

  static ApmKitManager get instance => _instance;

  // 如果想要自定义实现，可以用这个方式进行覆盖。后续扩展入口
  void addKit(String tag, ApmKit kit) {
    kitMap[tag] = kit;
  }

  T? getKit<T extends ApmKit>(String name) {
    if (kitMap.containsKey(name)) {
      return kitMap[name] as T;
    }
    return null;
  }

  void startUp() {
    kitMap.forEach((key, kit) {
      kit.start();
    });
  }
}

abstract class ApmKit implements IKit {
  late IStorage storage;

  void start();

  void stop();

  IStorage createStorage();

  Widget createDisplayPage();

  ApmKit() {
    storage = createStorage();
  }

  @override
  void tabAction() {
    KitsPage.tag = getKitName();
  }

  bool save(IInfo? info) {
    return info != null && !storage.contains(info) && storage.save(info);
  }

  bool removeAllItem() {
    storage.clear();
    return true;
  }

  IStorage getStorage() {
    return storage;
  }
}

class ApmKitName {
  static const String kitFps = '帧率';
  static const String kitMemory = '内存';
  static const String kitLog = '日志查看';
  static const String kitRoute = '路由信息';
  static const String kitChannel = '方法通道';
  static const String kitHttp = '网络请求';
  static const String kitSourceCode = '查看源码';
  static const String kitPageLaunch = '启动耗时';
  static const String kitCarsh = '崩溃检测';
}
