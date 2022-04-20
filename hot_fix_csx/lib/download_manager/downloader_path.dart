/*
 * @Author: Cao Shixin
 * @Date: 2021-02-23 18:28:16
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-10-28 17:34:11
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'dart:io';

import 'package:flutter_utils/flutter_utils.dart';
import 'package:path_provider/path_provider.dart';

class DownLoaderPath {
  //数据库基本目录
  static Future<String> getSqflitePath() async {
    var directory = Platform.isAndroid
        ? (await getExternalStorageDirectory())!
        : await getApplicationDocumentsDirectory();
    var tempPath = directory.path + '/Download';
    if (!await Directory(tempPath).exists()) {
      await Directory(tempPath).create(recursive: true);
    }
    return tempPath;
  }

  //列表音频的基本目录，更新到Document/Download/Music/下,
  //不在列表展示的，存储在Library/Caches/audios/下
  static Future getBasePath(bool isShowDownloadList) async {
    if (isShowDownloadList) {
      var sqflitePath = await getSqflitePath();
      var tempPath = sqflitePath + '/course';
      if (!await Directory(tempPath).exists()) {
        await Directory(tempPath).create(recursive: true);
      }
      LogUtil.log('////固定存储路径:$tempPath');
      return tempPath;
    } else {
      var temp = await getTemporaryDirectory();
      var tempPath = temp.path + '/audios';
      if (!await Directory(tempPath).exists()) {
        Directory(tempPath).createSync(recursive: true);
      }
      LogUtil.log('////暂存路径:$tempPath');
      return tempPath;
    }
  }

  /*
   * 删除指定路径的文件
   */
  static Future<bool> deleteFile(String filePath) async {
    var file = File(filePath);
    var exist = await file.exists();
    if (exist) {
      await file.delete(recursive: true);
    }
    return (await file.exists()) == false;
  }

  /*
   * 删除指定路径下的文件夹以及内部所有的文件，文件夹
   */
  static Future<bool> deleteDirectory(String directoryPath) async {
    var dir = Directory(directoryPath);
    var exist = await dir.exists();
    if (exist) {
      await dir.delete(recursive: true);
    }
    return (await dir.exists()) == false;
  }
}
