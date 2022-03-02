/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:24:54
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-02 09:28:16
 * @Description: 
 */
import 'dart:convert';
import 'dart:io';

import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/model/config_model.dart';
import 'package:hot_fix_csx/model/manifest_net_model.dart';
import 'package:hot_fix_csx/model/resource_model.dart';
import 'package:hot_fix_csx/operation/download_op.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

class ConfigHelp {
  factory ConfigHelp() => _getInstance();
  static ConfigHelp get instance => _getInstance();
  static ConfigHelp? _instance;
  static ConfigHelp _getInstance() {
    return _instance ??= ConfigHelp._internal();
  }

  ConfigModel get configModel => _configModel;
  ManifestNetModel get manifestNetModel => _manifestNetModel;
  ResourceModel get resourceModel => _resourceModel;
  late ConfigModel _configModel;
  late ManifestNetModel _manifestNetModel;
  late ResourceModel _resourceModel;

  ConfigHelp._internal() {
    _configModel = ConfigModel();
    _resourceModel = ResourceModel();
  }
  Future initData(ResourceModel model) async {
    _resourceModel = model;
    var value = await File(PathOp.instance.localRecodJsonPath()).readAsString();
    _configModel = ConfigModel.fromJson(jsonDecode(value));
  }

  set changeManifestModel(ManifestNetModel model) {
    _manifestNetModel = model;
  }

  /// 修改不是第一次加载的记录
  Future theVersionHasLoad() async {
    _configModel.isFirst = false;
    await _saveChange();
  }

  /// 更新热更新资源下载的时间
  Future updateHotfixTime() async {
    _configModel.lastHotfixTime = '${DateTime.now().second}';
    await _saveChange();
  }

  /// 更新资源可用的类型
  Future updateAvailableResourceType(HotFixValidResource type) async {
    _configModel.currentValidResource = type.index;
    await _saveChange();
  }

  /// 更新本地记录资源
  Future _saveChange() async {
    var value = PathOp.instance.localRecodJsonPath();
    var _buffer = StringBuffer();
    _buffer.write(_configModel.toJson());
    await File(value).writeAsString(_buffer.toString(), mode: FileMode.write);
  }

  Future refreshManifest() async {
    var result = await DownloadOp.instance.getJsonUrlContent();
    if (result == null) {
      //数据请求异常
    } else {
      _manifestNetModel = result;
    }
  }
}
