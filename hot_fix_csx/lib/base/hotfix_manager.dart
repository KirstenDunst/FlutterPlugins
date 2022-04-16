/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:06:56
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-15 18:26:46
 * @Description: 热更新资源管理
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
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

  String get availablePath => PathOp.instance.currentValidResourceBasePath();
  Stream get refreshStream => _refreshStreamController.stream;
  late StreamController _refreshStreamController;

  HotFixManager._internal() {
    WidgetsBinding.instance?.addObserver(this);
    _refreshStreamController = StreamController.broadcast();
  }

  /// 设置参数
  /// manifestUrl
  /// resourceModel
  /// logInfo：可选参数，默认单独存在hotFixLog文件内，如果设置，则需要单独处理存储事宜
  Future setParam(
    String manifestUrl,
    ResourceModel resourceModel, {
    LogInfoCall? logInfo,
  }) async {
    DownloadOp.instance.manifestUrl = manifestUrl;
    LogHelper.instance.logCall = logInfo;
    await PathOp.instance.initBase();
    await ConfigHelp.instance.initData(resourceModel, _refreshStreamController);
  }

  /// 开启资源监听
  Future start() async {
    LogHelper.instance.logInfo('开启资源检测');
    var readyResource = await _readyResource();
    if (readyResource) {
      await HotFixHelper.startHotFix();
    }
  }

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
    if (ConfigHelp.instance.configModel.isFirst) {
      var baseComplate = await isCompletedUnarchiveBase();
      if (baseComplate) {
        LogHelper.instance.logInfo('首次解压成功');
        await ConfigHelp.instance
            .updateAvailableResourceType(HotFixValidResource.base);
        await ConfigHelp.instance.theVersionHasLoad();
        _refreshStreamController.sink.add(null);
        unawaited(
            HotFixHelper.checkRecource(HotFixResourceIntegrityType.first));
        return true;
      } else {
        LogHelper.instance.logInfo('项目基准资源不完整，可以调用单元测试查看基准包不完备的具体原因');
        //无可用资源，这是不合理的，做一下全量下载（可能仍然不行）最合理的是走单元测试，让代码永远不要进入这里。
        //全量下载
        await HotFixHelper.readyTotalDownloadOperation(true);
        return false;
      }
    } else {
      _refreshStreamController.sink.add(null);
      return HotFixHelper.checkRecource(HotFixResourceIntegrityType.after);
    }
  }

  Future<bool> isCompletedUnarchiveBase() async {
    return ZipHelper.unZipFile(ConfigHelp.instance.getBaseZipPath(),
        Constant.hotfixBaseResourceDirName);
  }

  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _refreshStreamController.close();
    _instance = null;
  }
}
