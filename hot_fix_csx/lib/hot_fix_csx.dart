/*
 * @Author: Cao Shixin
 * @Date: 2022-01-19 14:57:55
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-02 10:09:38
 * @Description: 
 */
export 'base/hotfix_manager.dart';
export 'model/resource_model.dart';

import 'package:flutter/services.dart';
import 'dart:ffi'; // For FFI
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'base/allocation.dart'; // For Platform.isX

final DynamicLibrary nativeAddLib = Platform.isAndroid
    ? DynamicLibrary.open("libhot_fix_csx.so")
    : DynamicLibrary.process();

final int Function(int x, int y) nativeAdd = nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();

final int Function(int x, Pointer<Pointer<Utf8>> y) bsdiff = nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Pointer<Pointer<Utf8>>)>>(
        "bsdiff")
    .asFunction();

final int Function(int x, Pointer<Pointer<Utf8>> y) bspatch = nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Pointer<Pointer<Utf8>>)>>(
        "bspatch")
    .asFunction();

class HotFixCsx {
  static const MethodChannel _channel = MethodChannel('hot_fix_csx');

  ///解压本地资源，返回是否解压成功
  ///zipPath:解压文件的路径
  ///targetPath:需要解压到的文件路径
  static Future<bool> unzipResource(String zipPath, String targetPath) async {
    return (await _channel.invokeMethod(
            'unzip_resource', {'zipPath': zipPath, 'targetPath': targetPath}) ??
        false);
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
