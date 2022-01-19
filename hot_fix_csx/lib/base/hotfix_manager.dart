/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:06:56
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-30 14:00:09
 * @Description: 热更新资源管理
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:hot_fix_csx/helper/download_helper.dart';
import 'package:hot_fix_csx/helper/hotfix_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/helper/md5_helper.dart';
import 'package:hot_fix_csx/helper/zip_helper.dart';
import 'package:hot_fix_csx/model/resource_model.dart';
import 'package:hot_fix_csx/operation/check_resource_op.dart';
import 'package:hot_fix_csx/operation/compare_md5_op.dart';
import 'package:hot_fix_csx/operation/download_op.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

import 'common.dart';
import 'constant.dart';
import 'enum.dart';

class HotFixManager with WidgetsBindingObserver {
  factory HotFixManager() => _getInstance();
  static HotFixManager get instance => _getInstance();
  static HotFixManager? _instance;
  static HotFixManager _getInstance() {
    return _instance ??= new HotFixManager._internal();
  }

  VoidCallback get needRefresh => _needRefresh;
  late VoidCallback _needRefresh;

  HotFixManager._internal() {
    WidgetsBinding.instance?.addObserver(this);
    _isResourceIntegrityCheck = false;
  }

  @required
  Future setParam(
    String manifestUrl,
    ResourceModel resourceModel, {
    LogInfoCall? logInfo,
  }) async {
    DownloadOp.instance.manifestUrl = manifestUrl;
    LogHelper.instance.logCall = logInfo;
    await PathOp.instance.initBase();
    await ConfigHelp.instance.initData(resourceModel);
  }

  /// 当应用生命周期发生变化时 , 会回调该方法
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    /*
     * AppLifecycleState.paused:进入后台
     * AppLifecycleState.resumed:进入前台
     * AppLifecycleState.inactive:应用进入非活动状态 , 如来了个电话 , 电话应用进入前台
     * AppLifecycleState.detached:应用程序仍然在 Flutter 引擎上运行 , 但是与宿主 View 组件分离
     */
    LogHelper.instance.logInfo('应用活跃状态：$state');
    if (state == AppLifecycleState.resumed) {
      //应用进入前台
      var timeSpe = Constant.hotfixSpeceTime * 60;
      if (!ConfigHelp.instance.configModel.isFirst &&
          DateTime.now().second -
                  int.parse(ConfigHelp.instance.configModel.lastHotfixTime) >
              timeSpe) {
        startHotFix();
      }
    }
  }

  /* 开启资源监听，
   * hasNewResource：有新资源的回调
   */
  @required
  Future start() async {
    LogHelper.instance.logInfo('开启资源检测');
    _readyResource().then((value) {
      if (value) {
        startHotFix();
      }
    });
  }

  /*
   * 校验是否需要进行资源包更新
   */
  Future<bool> _readyResource() async {
    if (!ConfigHelp.instance.configModel.isFirst) {
      _needRefresh();
      return _checkRecource(HotFixResourceIntegrityType.After);
    } else if (await HotFixHelper.isCompletedUnarchiveBase()) {
      LogHelper.instance.logInfo('首次解压成功');
      await ConfigHelp.instance
          .updateAvailableResourceType(HotFixValidResource.Base);
      _needRefresh();
      return _checkRecource(HotFixResourceIntegrityType.First);
    } else {
      //走到这里，说明无可用资源，这是不合理的，安卓那边会做一下全量下载（可能仍然不行）最合理的是走单元测试，让代码永远不要进入这里。
      //给自己留一后手，大招，保命用！
      //全量下载
      readyTotalDownloadOperation(true);
      return false;
    }
  }

  /*
   * 进行资源包处理
   */
  Future startHotFix() async {
    ConfigHelp.instance.updateHotfixTime();
    await ConfigHelp.instance.refreshManifest();
    if (ConfigHelp.instance.manifestNetModel.bundleManifestChecksum !=
        (await Md5Helper.getFileMd5(PathOp.instance.localManifestJsonPath()) ??
            '')) {
//增量下载
      _startDiffDownloadOperation();
    }
  }

/*
 开始增量下载
 */
  Future _startDiffDownloadOperation() async {
    //增量包下载失败的话，全量下载
    if (await DownloadOp.instance.downloadFile(
        await DownloadHelper.getDiffUrl(),
        PathOp.instance.diffDownloadFilePath())) {
      //合并操作
      await HotFixHelper.makeupZip();
      //清理diff，否则会影响下次下载
      HotFixHelper.clearLastDiff();
      //对比操作zip文件的md5
      var result = await CompareMd5Op.compareMd5(
          PathOp.instance.makeupZipFilePath(),
          ConfigHelp.instance.manifestNetModel.bundleArchiveChecksum);
      if (result) {
//增量合并zip和配置文件md5一致
//解压缩zip文件
        var integrityType = await _unarchiveZip(false);
        //解压成功
        //同步校验完整性
        var checkResult = await _onlyCheckRecource();
        if (checkResult) {
          ConfigHelp.instance.configModel.currentValidResource =
              integrityType.index;
          _needRefresh();
          //清理将要不用的文件，防止影响新文件生成
          await HotFixHelper.clearLastZip();
          if (await HotFixHelper.mvMakeZipToLastZip()) {
            await HotFixHelper.clearMakeupZip();
          }
          //增量更新完成
        } else {
          readyTotalDownloadOperation(false);
        }
      } else {
        readyTotalDownloadOperation(false);
      }
    } else {
      readyTotalDownloadOperation(false);
    }
  }

  /*
   * 校验资源完备
   * integrityType 资源完备性校验的排次类型
   */
  late bool _isResourceIntegrityCheck;
  Future<bool> _checkRecource(HotFixResourceIntegrityType integrityType) async {
    if (_isResourceIntegrityCheck) {
      return false;
    } else {
      _isResourceIntegrityCheck = true;
      var resourceDirect = HotFixHelper.currentValidResourceBasePath();
      var value = await rootBundle
          .loadString(resourceDirect + Constant.hotfixResourceListFile);
      if (value.isNotEmpty) {
        var manifestJson = json.decode(value);
        CheckResourceOp.checkResourceFull(manifestJson, resourceDirect,
            (checkIsComplete, checkError) {
          _isResourceIntegrityCheck = false;
          if (checkIsComplete) {
            return true;
          } else {
            return _dealCheckIntegrityResourceType(integrityType);
          }
        });
      }
      return _dealCheckIntegrityResourceType(integrityType);
    }
  }

  Future<bool> _onlyCheckRecource() async {
    if (_isResourceIntegrityCheck) {
      return false;
    } else {
      _isResourceIntegrityCheck = true;
      var resourceDirect = HotFixHelper.currentValidResourceBasePath();
      var value = await rootBundle
          .loadString(resourceDirect + Constant.hotfixResourceListFile);
      if (value.isNotEmpty) {
        var manifestJson = json.decode(value);
        CheckResourceOp.checkResourceFull(manifestJson, resourceDirect,
            (checkIsComplete, checkError) {
          _isResourceIntegrityCheck = false;
          if (checkIsComplete) {
            return true;
          } else {
            return false;
          }
        });
      }
      return false;
    }
  }

  /*
   * 资源不完整的处理方案
   * integrityType 资源完备性校验的排次类型
   * block 资源是否可用
   */
  Future<bool> _dealCheckIntegrityResourceType(
      HotFixResourceIntegrityType integrityType) async {
    switch (integrityType) {
      case HotFixResourceIntegrityType.After:
        {
          //重新解压一次上一次的结果，并刷新页面，然后进行再一次异步校验
          var preRecourceType = await _unarchiveZip(true);
          ConfigHelp.instance.updateAvailableResourceType(preRecourceType);
          _needRefresh();
          File(PathOp.instance.latestZipFilePath()).delete();
          File(PathOp.instance.totalDownloadFilePath())
              .copy(PathOp.instance.latestZipFilePath());
          File(PathOp.instance.totalDownloadFilePath()).delete();
          var result =
              await _checkRecource(HotFixResourceIntegrityType.AfterAgain);
          return result;
        }
      case HotFixResourceIntegrityType.AfterAgain:
      case HotFixResourceIntegrityType.First:
        {
          readyTotalDownloadOperation(true);
          return false;
        }
    }
  }

  /*
   * 解压缩最新资源包资源
   * isTotalZip 是否是全量zip，否则是增量的合成包
   */
  Future<HotFixValidResource> _unarchiveZip(bool isTotalZip) async {
    var result = await _unarchiveZipPathAndType();
    var dirName = result['dirName'] as String;
    var preRecourceType = result['preRecourceType'] as HotFixValidResource;

    var isSuccess = false;
    if (isTotalZip) {
      isSuccess = await ZipHelper.unZipFile(
          PathOp.instance.totalDownloadFilePath(), dirName);
    } else {
      isSuccess = await ZipHelper.unZipFile(
          PathOp.instance.makeupZipFilePath(), dirName);
    }
    if (!isSuccess) {
      //异常处理，解压失败
      Directory(PathOp.instance.fixtempDirectoryPath()).rename(dirName);
    }
    Directory(PathOp.instance.fixtempDirectoryPath()).delete(recursive: true);

    return preRecourceType;
  }

  Future<Map> _unarchiveZipPathAndType() async {
    String dirName;
    HotFixValidResource preRecourceType;
    // fix和fixtmp文件相互替换，每次的热更新包都会交替循环的使用这两个文件夹
    if (ConfigHelp.instance.configModel.currentValidResourceType !=
        HotFixValidResource.Fix) {
      dirName = Constant.hotfixFixResourceDirName;
      preRecourceType = HotFixValidResource.Fix;
    } else {
      dirName = Constant.hotfixFixTmpResourceDirName;
      preRecourceType = HotFixValidResource.FixTmp;
    }
    if (await Directory(dirName).exists()) {
      await Directory(dirName).rename(Constant.hotfixFixTempResourceDirName);
    }
    return {'dirName': dirName, 'preRecourceType': preRecourceType};
  }

  /*
   * 全量下载
   */
  Future readyTotalDownloadOperation(bool needlLatest) async {
    if (needlLatest) {
      var model = await DownloadOp.instance.getJsonUrlContent();
      if (model == null) {
        return;
      }
      ConfigHelp.instance.changeManifestModel = model;
    }
    //获取全量下载地址
    var fullResourceZipUrl =
        ConfigHelp.instance.manifestNetModel.entireBundleUrl;
    if (fullResourceZipUrl.isEmpty) {
      //无下载地址，异常结束 TODO:异常结束-无全量下载地址
    }
    await startTotalDownloadOperation(fullResourceZipUrl);
  }

  /*
   * 开始全量下载操作，这是一个操作集合
   */
  Future startTotalDownloadOperation(String loadUrl) async {
    if (await DownloadOp.instance.downloadFile(
        ConfigHelp.instance.manifestNetModel.entireBundleUrl,
        DownloadHelper.getTotalUrl())) {
      if (await CompareMd5Op.compareMd5(
          ConfigHelp.instance.manifestNetModel.bundleArchiveChecksum,
          PathOp.instance.totalDownloadFilePath())) {
        var type = await _unarchiveZip(true);
        //全量zip解压完成--
        ConfigHelp.instance.updateAvailableResourceType(type);
        _needRefresh();
        File(PathOp.instance.totalDownloadFilePath())
            .rename(PathOp.instance.latestZipFilePath());
//全量更新完成---
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
  }
}
