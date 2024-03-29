/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:24:54
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-22 18:16:14
 * @Description: 
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/model/config_model.dart';
import 'package:hot_fix_csx/model/manifest_net_model.dart';
import 'package:hot_fix_csx/model/resource_model.dart';
import 'package:hot_fix_csx/operation/path_op.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigHelp {
  factory ConfigHelp() => _getInstance();
  static ConfigHelp get instance => _getInstance();
  static ConfigHelp? _instance;
  static ConfigHelp _getInstance() {
    return _instance ??= ConfigHelp._internal();
  }

  ConfigModel get configModel => _configModel;
  ManifestNetModel get manifestNetModel => _manifestNetModel;
  HotFixModel get resourceModel => _resourceModel;
  // StreamController get refreshStreamController => _refreshStreamController;

  late ConfigModel _configModel;
  late ManifestNetModel _manifestNetModel;
  late HotFixModel _resourceModel;
  late StreamController _refreshStreamController;
  late PackageInfo _packageInfo;

  ConfigHelp._internal() {
    _configModel = ConfigModel('', true, '');
    _resourceModel = HotFixModel(baseZipPath: '', unzipDirName: '');
  }

  Future initData(
      HotFixModel model, StreamController refreshStreamController) async {
    _resourceModel = model;
    _refreshStreamController = refreshStreamController;
    var localRecordFile = File(PathOp.instance.localRecodJsonPath());
    if (await localRecordFile.exists()) {
      var value = await localRecordFile.readAsString();
      LogHelper.instance.logInfo('本地记录操作json:$value');
      if (value.isNotEmpty) {
        _configModel = ConfigModel.fromJson(jsonDecode(value));
      }
    }
    LogHelper.instance.logInfo('本地模型配置结果:${_configModel.toJson()}');
    _packageInfo = await PackageInfo.fromPlatform();
  }

  set changeManifestModel(ManifestNetModel model) {
    _manifestNetModel = model;
  }

  void updateResourcePath() {
    _refreshStreamController.sink.add(
        '${PathOp.instance.baseDirectoryPath()}/${_resourceModel.unzipDirName}');
  }

  /// 获取项目基准资源包文件地址
  String getBaseZipPath() {
    return _resourceModel.baseZipPath;
  }

  String get nowAppVersion => _packageInfo.version;

  /// 修改不是第一次加载的记录
  Future theVersionHasLoad() async {
    _configModel.isFirst = false;
    _configModel.appVersion = nowAppVersion;
    await _saveChange();
  }

  /// 更新热更新资源下载的时间
  Future updateHotfixTime() async {
    _configModel.lastHotfixTime = '${DateTime.now().millisecondsSinceEpoch}';
    await _saveChange();
  }

  /// 更新本地记录资源
  Future _saveChange() async {
    var value = PathOp.instance.localRecodJsonPath();
    if (!await File(value).exists()) {
      await File(value).create(recursive: true);
    }
    var saveJsonStr = jsonEncode(_configModel.toJson());
    LogHelper.instance.logInfo('更新本地记录:$saveJsonStr');
    await File(value).writeAsString(saveJsonStr);
  }

  void dispose() {
    _instance = null;
  }
}
