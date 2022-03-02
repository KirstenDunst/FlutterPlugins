/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:49:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-01 14:58:50
 * @Description: 路径操作
 * HotFix
 *       base
 *              基准包解压缩之后的文件资源（文件夹）
 *       fix
 *              解压缩之后的文件资源（文件夹）
 *       fixtmp
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

  /*
   * 获取热更新基准
   */
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

  /*
   * 本地热更新记录json
   */
  String localRecodJsonPath() {
    return _baseDirectory +
        '/${Constant.hotfixConfigDirName}/${Constant.hotfixConfigJsonFile}';
  }

  /*
   * 本地保存上次的manifest的json数据
   */
  String localManifestJsonPath() {
    return _baseDirectory +
        '/${Constant.hotfixConfigDirName}/${Constant.hotfixNetWorkJsonFile}';
  }

  /*
   * 文件存储文件夹
   */
  String baseDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixBaseResourceDirName}';
  }

  String fixDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixFixResourceDirName}';
  }

  String fixtmpDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixFixTmpResourceDirName}';
  }

  String fixtempDirectoryPath() {
    return _baseDirectory + '/${Constant.hotfixFixTempResourceDirName}';
  }

  /*
   * 下载资源的包地址
   */
  String totalDownloadFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixTotalResourceFile}';
  }

  String diffDownloadFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixDiffDirName}';
  }

  String makeupZipFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixMakeupResourceFile}';
  }

  String latestZipFilePath() {
    return _baseDirectory +
        '/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}';
  }
}
