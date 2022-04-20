/*
 * @Author: Cao Shixin
 * @Date: 2021-02-23 20:08:28
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 14:56:23
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

//下载状态
import 'dart:async';
import 'dart:convert' as convert;
import 'package:hot_fix_csx/ext/num_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ResourceModel {
  //是否需要展示在下载管理界面列表中(不会影响ResourceProvider的一系列功能使用),默认不显示在列表中
  bool showDownloadList;

  //文件的远端地址
  String url;

  //文件的显示名称
  String name;

  //文件的归类名称(用作下载列表中的集合展示，不是一系列的不用设置)
  String kindName;

  //文件的时长（秒为单位）
  int timeInSecond;

  //（文件大小和校验值可不传，不传内部会请求远端获取）
  //资源大小，byte
  int? resourceSize;

  //文件唯一校验值，例如文件的md5
  String? verificationNumberStr;

  String get timeInSecondStr => (timeInSecond).timeFormat();

  ResourceModel(
      {this.url = '',
      this.showDownloadList = false,
      this.name = '',
      this.timeInSecond = 0,
      this.kindName = '',
      this.resourceSize,
      this.verificationNumberStr});

  factory ResourceModel.fromJson(Map json) {
    return ResourceModel(
        url: json['url'] ?? '',
        showDownloadList: json['showDownloadList'] ?? false,
        name: json['name'] ?? '',
        kindName: json['kindName'] ?? '',
        timeInSecond: json['timeInSecond'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['url'] = url;
    data['showDownloadList'] = showDownloadList;
    data['name'] = name;
    data['kindName'] = kindName;
    data['timeInSecond'] = timeInSecond;
    return data;
  }

  @override
  String toString() {
    return 'ResourceModel{showDownloadList: $showDownloadList, url: $url, name: $name, kindName: $kindName, timeInSecond: $timeInSecond}';
  }
}

class LocalResourceModel {
  //文件的远端地址
  String url;

  //下载任务的id
  String taskId;

  //任务的状态,1:下载成功，0:下载中（具体等待或者下载中可以根据下载的progress来判断）
  int isLoadSuccess;

  //文件的名称
  String fileName;

  //资源信息
  ResourceModel resourceModel;

  // 文件校验远端是否有改动，目前采用etag，有条件可以统一使用文件的md5
  String verifyStr;

  //资源的大小（byte单位）,外部设置无效，能够实时请求获取大小
  int resourceByte;

  String get resourceByteStr => (resourceByte).byteFormat();

  //是否展示在下载列表里面,1:在下载列表中展示，0:不展示在下载列表中
  int isShowList;

  //以下不会计入数据库，每次启动根据FlutterDownloader的任务变化
  //任务状态
  DownloadTaskStatus get status => _status ?? DownloadTaskStatus.running;

  //任务进度
  int get progress => _progress ?? 0;

  StreamController get refreshStreamControl => _refreshStreamControl;

  DownloadTaskStatus? _status;
  int? _progress;
  StreamController _refreshStreamControl;

  LocalResourceModel({
    this.url = '',
    this.taskId = '',
    this.isLoadSuccess = 0,
    this.fileName = '',
    this.resourceByte = 0,
    this.verifyStr = '',
    this.isShowList = 0,
    ResourceModel? resourceModel,
  })  : resourceModel = resourceModel ??= ResourceModel(),
        _refreshStreamControl = StreamController.broadcast();

  void changeProgressStatu({int? newProgress, DownloadTaskStatus? taskStatus}) {
    if (newProgress != null) {
      _progress = newProgress;
    }
    if (taskStatus != null) {
      _status = taskStatus;
    }
  }

  factory LocalResourceModel.fromJson(Map json) {
    return LocalResourceModel(
      url: json['url'],
      isShowList: json['isShowList'] ?? 0,
      taskId: json['taskId'],
      isLoadSuccess: json['isLoadSuccess'],
      fileName: json['fileName'] ?? '',
      resourceByte: json['resourceByte'] ?? 0,
      verifyStr: json['verifyStr'] ?? '',
      resourceModel: json.containsKey('resourceModel')
          ? ResourceModel.fromJson(convert.jsonDecode(json['resourceModel']))
          : ResourceModel(),
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['url'] = url;
    data['isShowList'] = isShowList;
    data['taskId'] = taskId;
    data['isLoadSuccess'] = isLoadSuccess;
    data['fileName'] = fileName;
    data['resourceByte'] = resourceByte;
    data['verifyStr'] = verifyStr;
    data['resourceModel'] = convert.jsonEncode(resourceModel.toJson());
    return data;
  }

  @override
  String toString() {
    return 'LocalResourceModel{url: $url, taskId: $taskId, isLoadSuccess: $isLoadSuccess, fileName: $fileName, resourceModel: $resourceModel, verifyStr: $verifyStr, resourceByte: $resourceByte, isShowList: $isShowList, _status: $_status, _progress: $_progress, _refreshStreamControl: $_refreshStreamControl}';
  }
}

//url校验参数返回
class HeadVerifyModel {
  String verifyStr;
  int byteNum;

  HeadVerifyModel({this.byteNum = 0, this.verifyStr = ''});

  @override
  String toString() {
    return 'HeadVerifyModel{verifyStr: $verifyStr, byteNum: $byteNum}';
  }
}

//下载成功界面展示的模型
class DownLoadShowModel {
  //名称
  String title;

  //下载地址
  String url;

  //下面的时间或者共有几项文字
  String timeOrCount;

  //存储占有b、kb、m、g、t
  int memoryByte;

  String get memoryStr => (memoryByte).byteFormat();

  DownLoadShowModel(
      {this.title = '',
      this.url = '',
      this.timeOrCount = '',
      this.memoryByte = 0});
}

class DownLoadedModel {
  //总 内存占有
  int memoryByte;

  String get memoryStr => (memoryByte).byteFormat();

  //列表
  List<DownLoadShowModel> showModels;

  DownLoadedModel({this.memoryByte = 0, required this.showModels});
}

class DownloaddingModel {
  // 下载中的数量
  int loaddingNum;

  //所有加入可显示下载队列的数量
  int allLoadddingNum;

  // 合计内存数量
  int memoryByte;

  String get memoryByteStr => (memoryByte).byteFormat();

  DownloaddingModel(
      {required this.loaddingNum,
      required this.allLoadddingNum,
      required this.memoryByte});
}

//下载中的每个cell处理模型
class DownloaddingCellModel {
  //状态字符串
  String stateStr;
  String memoryProgressStr;
  String statePicStr;
  TextStyle stateStrStyle;
  int progress;
  DownloadTaskStatus state;

  DownloaddingCellModel({
    required this.stateStr,
    required this.memoryProgressStr,
    required this.statePicStr,
    required this.stateStrStyle,
    required this.progress,
    required this.state,
  });
}

//批量下载整合进度模型
class DownloadStateModel {
  //当批量中任意一个下载失败就会触发这个状态为true，但是不影响其他的任务继续下载
  //如果模型初始即为true，可以理解为下载未开始，
  //应作为首要判定条件，如果为true，那么其他参数的数值将是不准确的。
  bool get isError => _isError;

  //全部资源的总字节数，单位byte
  num get allByte => _allByte;

  String get allByteStr => (_allByte).byteFormat();

  //是否下载完成的判断
  bool get isProgressArchive {
    var temp = true;
    _taskProgressMap.values.toList().forEach((progres) {
      if (progres != 100) {
        temp = false;
      }
    });
    return !_isError && temp;
  }

//是一个0～1的进度值,根据此值判定是否现在完成应使用（(downloadStateModel.progress - 1).abs() <= double.minPositive）,
//或者直接使用上面的isProgressArchive属性
  double get progress {
    var progress = 0;
    _taskProgressMap.values.toList().forEach((progres) {
      progress += progres;
    });
    return progress / (_taskProgressMap.length * 100);
  }

  //值有更新的流通知
  StreamController get valueChangeStreamControl => _valueChangeStreamControl;

  //url和进度
  Map<String, int> get taskProgressMap => _taskProgressMap;

  late bool _isError;
  late Map<String, int> _taskProgressMap;
  // ignore: close_sinks
  late StreamController _valueChangeStreamControl;
  late num _allByte;

  DownloadStateModel() {
    _allByte = 0;
    _taskProgressMap = <String, int>{};
    _isError = false;
    _valueChangeStreamControl = StreamController.broadcast();
  }

  void changeErrorState({bool errorState = false}) {
    _isError = errorState;
  }

  void addByte({num increment = 0}) {
    _allByte += increment;
  }
}

enum DownloadModelType {
  //无特殊状态
  UnSelect,
  //选中
  Select,
  //下载完成
  Download,
}

//下载弹窗dialog模型
class DownloadDialogModel {
  //图片地址
  String picUrl;

  //下载资源地址
  ResourceModel resourceModel;

  //下载的类型，调用showdialog的时候传入的参数可以不设置，内部会统一判定并修改
  DownloadModelType modelType;

  DownloadDialogModel(
      {required this.resourceModel,
      this.picUrl = '',
      this.modelType = DownloadModelType.UnSelect});
}
