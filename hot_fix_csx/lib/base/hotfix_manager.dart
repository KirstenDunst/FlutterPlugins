/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:06:56
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-22 18:16:19
 * @Description: 热更新资源管理
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/clear_helper.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:hot_fix_csx/helper/file_system_helper.dart';
import 'package:hot_fix_csx/helper/hotfix_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/helper/zip_helper.dart';
import 'package:hot_fix_csx/model/resource_model.dart';
import 'package:hot_fix_csx/operation/download_op.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

class HotFixManager with WidgetsBindingObserver {
  factory HotFixManager() => _getInstance();
  static HotFixManager get instance => _getInstance();
  static HotFixManager? _instance;
  static HotFixManager _getInstance() {
    return _instance ??= HotFixManager._internal();
  }

  /// 可用资源路径（压缩包解压的文件夹路径）
  /// 使用判断是否为空，不为空的时候才为有效路径,(新版本解压的时候会存在空的事件)
  String get availablePath => _availablePath;

  /// 配合上面路径获取使用，进行流事件监听，有更新会通过刷新流通知外部
  Stream<String> get refreshStream => _refreshStreamController.stream;

  late StreamController<String> _refreshStreamController;
  late String _availablePath;
  late List<StreamSubscription> _streamSubscriptions;

  HotFixManager._internal() {
    WidgetsBinding.instance?.addObserver(this);
    _availablePath = '';
    _streamSubscriptions = <StreamSubscription>[];
    _refreshStreamController = StreamController<String>.broadcast();
    _streamSubscriptions.add(_refreshStreamController.stream.listen((event) {
      _availablePath = event;
    }));
  }

  /// 设置参数
  /// manifestUrl
  /// resourceModel
  /// logInfo：可选参数，默认单独存在hotFixLog文件内，如果设置，则需要单独处理存储事宜
  Future setParam(
    String manifestUrl,
    HotFixModel resourceModel, {
    LogInfoCall? logInfo,
  }) async {
    DownloadOp.instance.manifestUrl = manifestUrl;
    LogHelper.instance.logCall = logInfo;
    await PathOp.instance.initBase();
    await ConfigHelp.instance.initData(resourceModel, _refreshStreamController);
  }

  /// 开启资源监听，需要在[setParam]方法执行完成之后调用
  Future start() => ClearHelp.clearOldData().then((_) {
        LogHelper.instance.logInfo('开启资源检测');
        unawaited(_readyResource().then((readyResource) {
          if (readyResource) {
            HotFixHelper.startHotFix();
          }
        }));
      });

  /// 当应用生命周期发生变化时 , 会回调该方法
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    LogHelper.instance.logInfo('应用活跃状态:$state');
    if (state == AppLifecycleState.resumed) {
      var timeSpe = Constant.hotfixSpeceTime * 60 * 1000;
      if (!ConfigHelp.instance.configModel.isFirst &&
          DateTime.now().millisecondsSinceEpoch -
                  int.parse(ConfigHelp.instance.configModel.lastHotfixTime) >
              timeSpe) {
        HotFixHelper.startHotFix();
      }
    }
  }

  /// 校验是否需要进行资源包更新
  Future<bool> _readyResource() async {
    //清单文件不存在同步解压基准包
    var exist = await FileSystemHelper.isExistsFile(
        PathOp.instance.currentManifestPath());
    if (ConfigHelp.instance.configModel.isFirst || !exist) {
      var baseComplate = await ZipHelper.unZipFile(
          ConfigHelp.instance.getBaseZipPath(),
          PathOp.instance.baseDirectoryPath());
      if (baseComplate) {
        LogHelper.instance.logInfo('首次解压成功');
        await ConfigHelp.instance.theVersionHasLoad();
        ConfigHelp.instance.updateResourcePath();
        unawaited(HotFixHelper.checkRecource());
        return true;
      } else {
        LogHelper.instance.logInfo('项目基准资源不完整，可以调用单元测试查看基准包不完备的具体原因');
        //无可用资源，这是不合理的，做一下全量下载（可能仍然不行）最合理的是走单元测试，让代码永远不要进入这里。
        //全量下载
        await HotFixHelper.readyTotalDownloadOperation(true);
        return false;
      }
    } else {
      ConfigHelp.instance.updateResourcePath();
      return HotFixHelper.checkRecource(isAgain: true);
    }
  }

  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    DownloadOp.instance.dispose();
    PathOp.instance.dispose();
    ConfigHelp.instance.dispose();
    _refreshStreamController.close();
    for (var element in _streamSubscriptions) {
      element.cancel();
    }
    LogHelper.instance.dispose();
    _instance = null;
  }
}
