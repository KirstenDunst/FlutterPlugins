/*
 * @Author: Cao Shixin
 * @Date: 2022-01-19 14:57:55
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-22 18:04:59
 * @Description: 
 */
export 'base/hotfix_manager.dart';
export 'model/resource_model.dart';
export 'helper/md5_helper.dart';
export 'helper/zip_helper.dart';
export 'util/url_encode_util.dart';
export 'download_manager/resource_provider.dart';
export 'base/safe_notifier.dart';
export 'ext/num_ext.dart';
export 'util/trace_util.dart';

// 扩展，暂未用到，对外开放
export 'util/stream_util.dart';

//DownloadManagerScreen查看你的下载内容及状态
export 'download_manager/download_manager.dart';
//hotfix最近70条记录显示器
export 'base/log_widget.dart';

import 'package:flutter/services.dart';
import 'dart:ffi'; // For FFI
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'base/allocation.dart'; // For Platform.isX

final DynamicLibrary hotFixCsx = Platform.isAndroid
    ? DynamicLibrary.open("libhot_fix_csx.so")
    : DynamicLibrary.process();

final int Function(int x, int y) nativeAdd = hotFixCsx
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();

final int Function(int x, Pointer<Pointer<Utf8>> y) bsdiff = hotFixCsx
    .lookup<NativeFunction<Int32 Function(Int32, Pointer<Pointer<Utf8>>)>>(
        "bsdiff")
    .asFunction();

final int Function(int x, Pointer<Pointer<Utf8>> y) bspatch = hotFixCsx
    .lookup<NativeFunction<Int32 Function(Int32, Pointer<Pointer<Utf8>>)>>(
        "bspatch")
    .asFunction();

class HotFixCsx {
  static const MethodChannel _channel = MethodChannel('hot_fix_csx');

  /// 解压项目资源，返回是否解压成功
  /// resourseName:待解压的项目资源文件（iOS项目直接拖入项目主目录的资源，Android:主项目下面assets文件夹中存放的资源）名称
  /// targetDirectPath:需要解压到的手机本地路径
  static Future<bool> unzipResource(
      String resourseName, String targetDirectPath) async {
    return (await _channel.invokeMethod('unzip_resource', {
          'resourseName': resourseName,
          'targetDirectPath': targetDirectPath
        }) ??
        false);
  }

  /// 拷贝项目资源到手机本地
  /// resourseName 待拷贝的项目资源文件（iOS项目直接拖入项目主目录的资源，Android:主项目下面assets文件夹中存放的资源）名称
  /// targetPath: 本机目标路径
  static Future<bool> copyResourceToDevice(
      String resourseName, String targetPath) async {
    var result = await _channel.invokeMethod('move_resource',
        {'resourseName': resourseName, 'targetPath': targetPath});
    return result ?? false;
  }

  /// 拆分包
  /// 返回0: 成功， 1:失败
  /// source：字符串数组（四个元素）：
  /// 元素1:固定“bsdiff”
  /// 元素2:需要比对的原始zip包路径地址
  /// 元素3:新的zip包的路径地址
  /// 元素4:增量包.patch的生成文件路径
  static int bsDiffWithC(List<String> source) {
    Pointer<Pointer<Utf8>> argv =
        allocate(totalSize: source.length * sizeOf<Pointer<Utf8>>());
    for (var i = 0; i < source.length; i++) {
      argv[i] = source[i].toNativeUtf8();
    }
    var result = bsdiff(source.length, argv);
    free(argv);
    return result;
  }

  /// 合并包
  /// 返回0: 成功， 1:失败
  /// source：字符串数组（四个元素）：
  /// 元素1:固定“bspatch”
  /// 元素2:需要增量的原zip包路径地址
  /// 元素3:合并之后生成新zip包的路径地址
  /// 元素4:增量包.patch的文件路径
  static int bsPatchWithC(List<String> source) {
    Pointer<Pointer<Utf8>> argv =
        allocate(totalSize: source.length * sizeOf<Pointer<Utf8>>());
    for (var i = 0; i < source.length; i++) {
      argv[i] = source[i].toNativeUtf8();
    }
    var result = bspatch(source.length, argv);
    free(argv);
    return result;
  }
}
