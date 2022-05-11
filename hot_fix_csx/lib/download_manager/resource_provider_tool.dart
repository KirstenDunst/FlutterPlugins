/*
 * @Author: Cao Shixin
 * @Date: 2021-03-18 15:03:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-05-11 09:15:38
 * @Description: 
 */
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'download_share_key.dart';
import 'downloader_model.dart';
import 'sqflite_util.dart';

class ResourceProviderTool {
  static Completer<bool>? checkDownloadDialogCompleter;

  /*非Wi-Fi的时候第一次下载给提醒，不切换网络的情况下，下次下载就不会提醒。如果切换了wifi，那么等下次下载再遇到非wifi的时候再提醒
   * 检测下载，并且需要的情况下弹窗提醒
   * 返回:能够下载
   */
  static Future<bool> checkDownloadDialog(
      ConnectivityResult connectResult) async {
    var canDownload = true;
    if (connectResult == ConnectivityResult.mobile &&
        !await SharedPreferenceService.instance
            .get<bool>(DownloadShareKey.downloadConnectNotWifi, false)) {
      if (checkDownloadDialogCompleter?.isCompleted ?? true) {
        checkDownloadDialogCompleter = Completer<bool>();
        //做提醒弹窗
        await SharedPreferenceService.instance
            .set(DownloadShareKey.downloadConnectNotWifi, true);
        await showNotWifiDialog(
            content: '当前处于非Wi-Fi网络状态,是否继续下载?',
            onConfirm: () => checkDownloadDialogCompleter!.complete(true),
            cancel: () => checkDownloadDialogCompleter!.complete(false));
      } else {
        canDownload = await checkDownloadDialogCompleter!.future;
      }
    }
    return canDownload;
  }

  /*
   * 数据库扩展
   */
  static Future alertSqlColumn(
      SqfliteUtil sqfliteUtil, String tableName) async {
    // var tempGetColumnMap = {'url': '临时的'};
    // await sqfliteUtil
    //     .bcAddDataForTable([tempGetColumnMap], tableName: tableName);
    // var result =
    //     await sqfliteUtil.bcSelectFirstDataForTab(tableName: tableName);
    // //1.2.0之后数据库迁移
    // var alertMap = <String, dynamic>{
    //   'verifyStr': '',
    //   'resourceByte': 0,
    //   'isShowList': 0,
    //   'fileName': ''
    // };
    // var addKeys = alertMap.keys.toList();
    // addKeys.forEach((key) {
    //   if (result.first.keys.contains(key)) {
    //     alertMap.remove(key);
    //   }
    // });
    // //扩展数据库
    // await sqfliteUtil.bcAlterTableAddForTable(alertMap, tableName: tableName);
    // await sqfliteUtil.bcDeleteDataForTable(tempGetColumnMap,
    //     tableName: tableName);
  }

  /*
   * 是否有新版本
   */
  static bool haveNewVersion(String newVersion, String old) {
    if (newVersion.isEmpty || old.isEmpty) return false;
    int newVersionInt, oldVersion;
    var newList = newVersion.split('.');
    var oldList = old.split('.');
    if (newList.isEmpty || oldList.isEmpty) {
      return false;
    }
    for (var i = 0; i < newList.length; i++) {
      newVersionInt = int.parse(newList[i]);
      oldVersion = int.parse(oldList[i]);
      if (newVersionInt > oldVersion) {
        return true;
      } else if (newVersionInt < oldVersion) {
        return false;
      }
    }
    return false;
  }

  /*
   * 下载任务的状态是否归类到下载失败
   */
  static bool isErrorTaskState(DownloadTaskStatus state) {
    return [
      DownloadTaskStatus.undefined,
      DownloadTaskStatus.canceled,
      DownloadTaskStatus.failed,
      DownloadTaskStatus.paused
    ].contains(state);
  }

  /*
   * 获取远端资源的head信息，用于校验本地资源
   */
  static Future<HeadVerifyModel> getUrlHeadVerify(String url,
      {int? resourceSize, String? verificationNumberStr}) async {
    var fileByte = 0;
    var vertifyStr = '';
    if (resourceSize == null ||
        resourceSize == 0 ||
        verificationNumberStr == null ||
        verificationNumberStr.isEmpty) {
      try {
        var byteDio = FocusHttpUtil().rest;
        var headers = (await byteDio.head(Uri.encodeFull(url))).headers;
        fileByte = int.parse(headers.value(Headers.contentLengthHeader) ?? '');
        vertifyStr = headers.map['etag']?.first ?? '';
      } catch (e) {
        LogUtil.log('$url head vertify get fail: $e');
      }
    } else {
      fileByte = resourceSize;
      vertifyStr = verificationNumberStr;
    }
    return HeadVerifyModel(byteNum: fileByte, verifyStr: vertifyStr);
  }

  //校验本地资源是否存在并且和远端文件内容没有差异
  static Future<bool> contentAndVerityPass(LocalResourceModel tempModel,
      String path, HeadVerifyModel headerModel) async {
    //校验头文件获取失败的资源也不认定为存在的
    if (tempModel.resourceByte == 0 || tempModel.verifyStr.isEmpty) {
      return false;
    }
    if (headerModel.verifyStr == tempModel.verifyStr) {
      //为了防止临时库文件被清理的判断
      if (await File(path).exists()) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /*
   * 清理多余存储
   */
  static Future deleteNoUseSaveFile(
      String listPath, String tempPath, List<String> useFileNames) async {
    Directory(listPath).listSync().forEach((fileSys) {
      if (!useFileNames.contains(fileSys.path.split('/').last)) {
        fileSys.deleteSync();
      }
    });
    Directory(tempPath).listSync().forEach((fileSys) {
      if (!useFileNames.contains(fileSys.path.split('/').last)) {
        fileSys.deleteSync();
      }
    });
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    var send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}

///
Future showNotWifiDialog(
    {required String content,
    required Function onConfirm,
    Function? cancel}) async {
  BotToast.showWidget(toastBuilder: (cancelFunc) {
    return Container(
        color: Colors.black38,
        child: Center(
          child: AlertDialog(
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: cancelFunc,
                child: Text(
                  '取消',
                  style: const TextStyle(color: Color(0xff707070))
                      .copyWith(decoration: TextDecoration.none),
                ),
              ),
              TextButton(
                onPressed: () {
                  onConfirm();
                  cancelFunc();
                },
                child: Text(
                  '继续',
                  style: const TextStyle(color: Colors.blue)
                      .copyWith(decoration: TextDecoration.none),
                ),
              )
            ],
          ),
        ));
  });
}
