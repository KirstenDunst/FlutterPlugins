/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:10:12
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-18 10:27:38
 * @Description: 
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/model/manifest_net_model.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadOp {
  factory DownloadOp() => _getInstance();
  static DownloadOp get instance => _getInstance();
  static DownloadOp? _instance;
  static DownloadOp _getInstance() {
    return _instance ??= DownloadOp._internal();
  }

  late Dio _dio;
  late String _manifestUrl;

  DownloadOp._internal() {
    _dio = FocusHttpUtil().rest;
  }

  @required
  set manifestUrl(String url) {
    _manifestUrl = url;
  }

  /// 下载文件保存本地
  /// url：下载文件的远端地址
  /// savePath： 保存本地的路径
  Future<bool> downloadFile(String url, String savePath) async {
    LogHelper.instance.logInfo('下载url:$url');
    bool status = await Permission.storage.isGranted;
    //判断如果还没拥有读写权限就申请获取权限
    if (!status) {
      await Permission.storage.request().isGranted;
    }
    Response response;
    try {
      response = await _dio.download(
        url, savePath,
        // onReceiveProgress: (count, total) => LogHelper.instance
        //     .logInfo('$url下载进度:count:$count, total: $total')
      );
      if (response.statusCode == 200) {
        LogHelper.instance.logInfo('下载$url请求成功');
        return true;
      } else {
        LogHelper.instance.logInfo('接口出错:$response');
        return false;
      }
    } catch (e) {
      LogHelper.instance.logInfo('服务器出错或网络连接失败:$e');
      return false;
    }
  }

  /// 请求远端json文件的内容获取
  Future<bool> getJsonUrlContent() async {
    Response response;
    try {
      response = await _dio.get(_manifestUrl);
      if (response.statusCode == 200) {
        LogHelper.instance.logInfo('jsonUrl请求成功:${response.data}');
        var model = ManifestNetModel.fromJson(response.data);
        ConfigHelp.instance.changeManifestModel = model;
        return true;
      } else {
        LogHelper.instance.logInfo('json接口:$_manifestUrl出错:$response');
        return false;
      }
    } catch (e) {
      LogHelper.instance.logInfo('json服务器出错或网络连接失败:$e');
      return false;
    }
  }

  void dispose() {
    _dio.close(force: true);
    _instance = null;
  }
}
