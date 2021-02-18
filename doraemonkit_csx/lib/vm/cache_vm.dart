/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 09:27:42
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:34:22
 * @Description: 
 */

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:doraemonkit_csx/util/util.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/* path_provider 中获取文件夹的方法
 * getExternalStorageDirectory();  // 在iOS上，抛出异常，在Android上，这是getExternalStorageDirectory的返回值
 * getTemporaryDirectory();  // 在iOS上，对应NSTemporaryDirectory（）返回的值，在Android上，这是getCacheDir的返回值。
 * getApplicationDocumentsDirectory();  // 在iOS上，这对应NSDocumentsDirectory，在Android上，这是AppData目录
 */

class CacheVM {
  //获取缓存大小
  static Future<String> loadCache() async {
    var value = 0;
    Directory tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      value = await _getTotalSizeOfFilesInDir(tempDir);
    }
    var cacheSizeStr = value.byteFormat();
    return cacheSizeStr;
  }

  static Future<int> _getTotalSizeOfFilesInDir(FileSystemEntity file) async {
    if (file is File) {
      int length = await file.length();
      return length;
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      var total = 0;
      if (children != null)
        for (final FileSystemEntity child in children)
          total += await _getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

  //清除缓存
  static Future clearCache({VoidCallback callback}) async {
    Directory tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      //删除缓存目录
      await _delDir(tempDir);
    }
    if (callback != null) {
      callback();
    }
    BotToast.showText(text: '清除缓存成功');
  }

  ///递归方式删除目录
  static Future _delDir(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delDir(child);
      }
    } else {
      await file.delete();
    }
  }
}
