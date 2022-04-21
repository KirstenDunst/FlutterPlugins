/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:49:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 16:33:28
 * @Description: 路径操作
 * HotFix
 *       base
 *              基准包解压缩之后的文件资源（文件夹）
 *       fix
 *              解压缩之后的文件资源（文件夹）
 *       fixtemp
 *              解压缩之后的文件资源（文件夹）
 *       config
 *               manifest.json
 *               config.json
 *       download
 *               diff
 *               total.zip
 *               makeup.zip
 *               latest.zip
 */

import 'dart:io';
import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:path_provider/path_provider.dart';

class PathOp {
  factory PathOp() => _getInstance();
  static PathOp get instance => _getInstance();
  static PathOp? _instance;
  static PathOp _getInstance() {
    return _instance ??= PathOp._internal();
  }

  String get baseDirectory => _baseDirectory;
  late String _baseDirectory;

  PathOp._internal() {
    _baseDirectory = '';
  }

  /// 获取热更新基准
  Future<String> _getBasePath() async {
    var path = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
    var hotfixDirextory = path!.path + '/HotFix';
    if (!(await Directory(hotfixDirextory).exists())) {
      Directory(hotfixDirextory).create(recursive: true);
    }
    return hotfixDirextory;
  }

  Future initBase() async {
    _baseDirectory = await _getBasePath();
  }

  /// 当前资源文件的清单文件路径
  String currentManifestPath() {
    var parentPath = baseDirectoryPath();
    return '$parentPath/${ConfigHelp.instance.resourceModel.unzipDirName}/${Constant.hotfixResourceListFile}';
  }

  /// 本地热更新记录json
  String localRecodJsonPath() {
    return _baseDirectory +
        '/${Constant.hotfixConfigDirName}/${Constant.hotfixConfigJsonFile}';
  }

  /// 文件存储文件夹
  String baseDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixBaseResourceDirName}';
  }

  /// 热更新文件夹1
  String fixDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixFixResourceDirName}';
  }

  /// 热更新中转操作的临时文件夹
  String fixtempDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixFixTempResourceDirName}';
  }

  /// 全量文件地址
  String totalDownloadFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixTotalResourceFile}';
  }

  /// 差量文件本地路径
  String diffDownloadFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixDiffDirName}';
  }

  /// 增量合并之后的文件路径
  String makeupZipFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixMakeupResourceFile}';
  }

  /// 最新文件地址，所有有效文件的最终归宿
  String latestZipFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}';
  }

  void dispose() {
    _instance = null;
  }
}
