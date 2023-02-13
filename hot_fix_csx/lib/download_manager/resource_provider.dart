/*
 * @Author: Cao Shixin
 * @Date: 2021-02-23 16:52:35
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-13 17:32:15
 * @Description: 网络资源处理工具
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_enhanced/device_info_enhanced.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:synchronized/extension.dart';
import 'download_share_key.dart';
import 'downloader_model.dart';
import 'downloader_path.dart';
import 'resource_provider_tool.dart';
import 'sqflite_util.dart';

class ResourceProvider extends ChangeNotifier with SafeNotifier {
  // 工厂模式
  factory ResourceProvider() => _getInstance();
  static ResourceProvider get instance => _getInstance();
  static ResourceProvider? _instance;
  ResourceProvider._internal();

  static ResourceProvider _getInstance() {
    _instance ??= ResourceProvider._internal();
    return _instance!;
  }

  //已下载完成的map，url为key
  Map<String, LocalResourceModel> get resourceMapLoaded => _resourceMapLoaded;
  StreamController<Map<String, LocalResourceModel>>
      get resourceMapLoadedStreamControl => _resourceMapLoadedStreamControl;
  //下载中的map，taskid为key
  Map<String, LocalResourceModel> get resourceMapLoadding =>
      _resourceMapLoadding;
  StreamController<Map<String, LocalResourceModel>>
      get resourceMapLoaddingStreamControl => _resourceMapLoaddingStreamControl;
  //当前网络连接的类型
  ConnectivityResult? get connectResult => _connectResult;
  //网络变化流
  Stream<ConnectivityResult> get connectResultStream => _connectResultStream;

  //_resourceMapLoadding是taskid为key、     _resourceMapLoaded是网络地址url为key
  late Map<String, LocalResourceModel> _resourceMapLoadding, _resourceMapLoaded;
  late StreamController<Map<String, LocalResourceModel>>
      _resourceMapLoadedStreamControl, _resourceMapLoaddingStreamControl;
  late String _saveListParentPath, _saveTmpParentPath;
  String? _sqflitePath;
  //下载资源的表名
  final String _tableName = 'ResourceTable';
  ReceivePort? _receivePort;
  //网络连接
  ConnectivityResult? _connectResult;
  late Stream<ConnectivityResult> _connectResultStream;

  late List<StreamSubscription> _connectSubscriptions;
  String? _oomMessage;
  int? _oomByte;

  // 初始化
  void initData(
      {String oomMessage = '当前设备存储空间不足,请检查设备存储之后重试',
      int oomByte = 5 * 1024 * 1024}) {
    _oomMessage = oomMessage;
    _oomByte = oomByte;
    _resourceMapLoadding = <String, LocalResourceModel>{};
    _resourceMapLoaded = <String, LocalResourceModel>{};
    _resourceMapLoadedStreamControl = StreamController.broadcast();
    _resourceMapLoaddingStreamControl = StreamController.broadcast();
    _connectResultStream =
        Connectivity().onConnectivityChanged.asBroadcastStream();
    _connectSubscriptions = <StreamSubscription>[
      _resourceMapLoadedStreamControl.stream.listen((data) {
        _resourceMapLoaded = data;
      }),
      _resourceMapLoaddingStreamControl.stream.listen((data) {
        _resourceMapLoadding = data;
      }),
      _connectResultStream.listen((ConnectivityResult result) async {
        _connectResult = result;
        switch (result) {
          case ConnectivityResult.wifi:
            //非Wi-Fi的时候第一次下载给提醒，不切换网络的情况下，下次下载就不会提醒。如果切换了wifi，那么等下次下载再遇到非wifi的时候再提醒
            await SharedPreferenceService.instance
                .set(DownloadShareKey.downloadConnectNotWifi, false);
            break;
          case ConnectivityResult.mobile:
            break;
          case ConnectivityResult.none:
            break;
          default:
        }
      }),
    ];
  }

  //需要在启动的时候调用来预加载本地数据
  Future loadBaseData() async {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
    _connectResult = await (Connectivity().checkConnectivity());
    _saveListParentPath = await DownLoaderPath.getBasePath(true);
    _saveTmpParentPath = await DownLoaderPath.getBasePath(false);
    _sqflitePath = await DownLoaderPath.getSqflitePath();
    //数据库初始化
    await sqfliteUtil.initlize(basePath: _sqflitePath);
    //创建数据库
    await sqfliteUtil.bcCreateTableName(
        LocalResourceModel(resourceModel: ResourceModel()).toJson(),
        tableName: _tableName);
    //数据库迁移
    await ResourceProviderTool.alertSqlColumn(sqfliteUtil, _tableName);
    //初始化本地数据
    await _loadLocalData();
    //注册回调以及接收
    _downloadCallBackAndDeal();
  }

  //加载本地数据
  Future _loadLocalData() async {
    //重新启动还在下载中的任务。
    var taskRuningIds = (await FlutterDownloader.loadTasks())
        ?.where((element) => element.status == DownloadTaskStatus.running)
        .map((task) => task.taskId)
        .toList();
    var allMaps =
        (await sqfliteUtil.bcSelectDataForTab({}, tableName: _tableName))
            .map((map) => LocalResourceModel.fromJson(map))
            .toList();
    var allSqlFileNames = <String>[];
    //数据库数据读取,loading,loaded赋值
    for (var item in allMaps) {
      if (item.fileName.isNotEmpty) {
        var filePath = _getFileAbsolutePath(item.isShowList, item.fileName);
        if (item.isLoadSuccess == 1) {
          if (await File(filePath).exists()) {
            allSqlFileNames.add(item.fileName);
            _resourceMapLoaded.addAll({item.url: item});
          } else {
            await sqfliteUtil
                .bcDeleteDataForTable({'url': item.url}, tableName: _tableName);
          }
        } else {
          if (taskRuningIds?.contains(item.taskId) ?? false) {
            allSqlFileNames.add(item.fileName);
            _resourceMapLoadding.addAll({item.taskId: item});
          } else {
            //本地数据库记录未成功的如果也不在重新启动的下载中task里面，就清除数据库记录，校准。
            await sqfliteUtil.bcDeleteDataForTable({'taskId': item.taskId},
                tableName: _tableName);
          }
        }
      }
    }
    _reloadArrStream();
    //清除多余存储
    await ResourceProviderTool.deleteNoUseSaveFile(
        _saveListParentPath, _saveTmpParentPath, allSqlFileNames);
  }

  //注册下载进度回调以及数据处理
  void _downloadCallBackAndDeal() {
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(
        _receivePort!.sendPort, 'downloader_send_port');
    _receivePort!.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1] as int);
      int progress = data[2];
      var tempModel = _resourceMapLoadding[id];
      if (tempModel != null) {
        LogUtil.log(
            '${tempModel.resourceModel.kindName}--${tempModel.resourceModel.name}--${tempModel.url}任务下载: id:$id, status:$status, progress:$progress');
        var tempProgress = (progress == 100)
            ? (status == DownloadTaskStatus.complete ? 100 : 99)
            : progress;
        tempProgress = max(tempProgress, 0);
        tempModel.changeProgressStatu(
            newProgress: tempProgress, taskStatus: status);
        //在下载中数组内部找到记录
        if (status == DownloadTaskStatus.complete) {
          _resourceMapLoadding.remove(id);
          _resourceMapLoaded
              .addAll({tempModel.url: tempModel..isLoadSuccess = 1});
          sqfliteUtil.bcChangeDataWithTableName(
              {'isLoadSuccess': 1}, {'url': tempModel.url},
              tableName: _tableName);
          _reloadArrStream();
        }
        tempModel.refreshStreamControl.sink.add(null);
      } else {
        FlutterDownloader.loadTasksWithRawQuery(
                query: 'SELECT * FROM task WHERE task_id=$id')
            .then((result) {
          var url = '';
          try {
            url = (result?.isNotEmpty ?? false) ? result!.first.url : '';
          } catch (e) {
            url = e.toString();
          }
          LogUtil.log(
              '普通任务下载-$url: id:$id, status:$status, progress:$progress');
        });
      }
    });
    FlutterDownloader.registerCallback(ResourceProviderTool.downloadCallback);
  }

  //数据源更新，需要通知流
  void _reloadArrStream() {
    _resourceMapLoaddingStreamControl.add(_resourceMapLoadding);
    _resourceMapLoadedStreamControl.add(_resourceMapLoaded);
  }

  /*
   * 加载资源，会根据url进行本地资源的查找，如果存在将直接返回本地资源路径
   * autoDownLoad:为true则如果没有会去下载，并将下载成功之后的本地路径地址回调。（返回null:流量下载提醒不被允许、网络地址错误404、）
   *               为false则本地没有就直接返回null
   */
  Future<String?> loadResource(ResourceModel model,
      {bool autoDownLoad = false}) async {
    LogUtil.log('loadResource >>> start ${model.url}');
    if (_resourceMapLoaded.containsKey(model.url)) {
      var tempModel = _resourceMapLoaded[model.url]!;
      var headerModel = await ResourceProviderTool.getUrlHeadVerify(model.url,
          resourceSize: model.resourceSize,
          verificationNumberStr: model.verificationNumberStr);
      var path = _getFileAbsolutePath(tempModel.isShowList, tempModel.fileName);
      var contentAndVerity = await ResourceProviderTool.contentAndVerityPass(
          tempModel, path, headerModel);
      if (contentAndVerity) {
        LogUtil.log('loadResource >>> end ${model.url}-$path');
        return path;
      } else {
        //清除本地sql和loaded的资源指引
        await deleteTask([tempModel.url], isComplete: true);
        //询问自动下载，
        var result = await _loadResourceAutoDownload(model,
            autoDownLoad: autoDownLoad, headerModel: headerModel);
        LogUtil.log('loadResource >>> end ${model.url}-$result');
        return result;
      }
    } else {
      //询问自动下载
      var result =
          await _loadResourceAutoDownload(model, autoDownLoad: autoDownLoad);
      LogUtil.log('loadResource >>> end ${model.url}-$result');
      return result;
    }
  }

  /* ALERT:强制下载方法
   * 流量下载提醒选择不被允许，返回null
   * 下载文件,无感知,已知本地不存在或强制下载, 返回任务id。
   * model为空:开启_resourceMapLoadding中的FlutterDownloader下载失败,取消、未定义的任务,那么返回为null
   */
  Future<String?> downResource(
      {ResourceModel? model, HeadVerifyModel? headerModel}) async {
    var canEnter = await _checkOOM();
    if (!canEnter) {
      return null;
    }
    if (model != null) {
      //校验网络切换弹窗
      var canDownload =
          await ResourceProviderTool.checkDownloadDialog(_connectResult!);
      if (canDownload) {
        var isLoading = false;
        var loaddingTaskId = '';
        _resourceMapLoadding.forEach((key, tempModel) async {
          if (tempModel.url == model.url) {
            if ([DownloadTaskStatus.running, DownloadTaskStatus.enqueued]
                .contains(tempModel.status)) {
              isLoading = true;
              loaddingTaskId = key;
            } else {
              await FlutterDownloader.cancel(taskId: tempModel.taskId);
              await sqfliteUtil.bcDeleteDataForTable(
                  {'taskId': tempModel.taskId},
                  tableName: _tableName);
              _resourceMapLoadding.remove(tempModel.taskId);
              _reloadArrStream();
            }
          }
        });
        if (!isLoading) {
          //下载到本地，并记录到数据库
          var parentDir =
              model.showDownloadList ? _saveListParentPath : _saveTmpParentPath;
          var fileName = Md5Helper.urlMd5ToName(model.url);
          headerModel ??= await ResourceProviderTool.getUrlHeadVerify(model.url,
              resourceSize: model.resourceSize,
              verificationNumberStr: model.verificationNumberStr);
          if (headerModel.byteNum == 0 && headerModel.verifyStr == '') {
            return null;
          } else {
            loaddingTaskId = await FlutterDownloader.enqueue(
                  url: Uri.encodeFull(model.url),
                  savedDir: parentDir,
                  fileName: fileName,
                  showNotification: false,
                  openFileFromNotification: false,
                ) ??
                '';
            var tempModel = LocalResourceModel(
              url: model.url,
              isShowList: model.showDownloadList ? 1 : 0,
              taskId: loaddingTaskId,
              isLoadSuccess: 0,
              fileName: fileName,
              resourceByte: headerModel.byteNum,
              verifyStr: headerModel.verifyStr,
              resourceModel: model,
            );
            //防止url不变，资源更换，可能出现的下载失败，数据库还保留之前的url已完成，出现错误，这里直接删除之前这个url的记录
            _resourceMapLoaded.remove(model.url);
            await sqfliteUtil.bcDeleteDataForTable({'url': model.url},
                tableName: _tableName);
            _resourceMapLoadding.addAll({loaddingTaskId: tempModel});
            await sqfliteUtil
                .bcAddDataForTable([tempModel.toJson()], tableName: _tableName);
            _reloadArrStream();
          }
        }
        return loaddingTaskId;
      } else {
        return null;
      }
    } else {
      unawaited(retryTasks());
      return null;
    }
  }

  Future<bool> _checkOOM() async {
    num romUseB = 0, romAllB = 0;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoEnhanced.androidInfo();
      romAllB = androidInfo.storage.romAllB;
      romUseB = androidInfo.storage.romUseB;
    } else {
      var iosInfo = await DeviceInfoEnhanced.iosInfo();
      romAllB = iosInfo.storage.romAllB;
      romUseB = iosInfo.storage.romUseB;
    }
    //阈值默认5M
    var thresholdValue = _oomByte ?? (5 * 1024 * 1024);
    if (romAllB != 0 && (romAllB - romUseB < thresholdValue)) {
      BotToast.showText(text: _oomMessage ?? '当前设备存储空间不足,请检查设备存储之后重试');
      return false;
    }
    return true;
  }

  /*
   * 批量下载资源,有感知（DownloadStateModel里面有记录进度和状态）
   * 
   * 注意:1.在订阅其流之前先判断一下相应的状态。对象返回前，内部的状态和进度参数有相应的基本赋值操作。
   *        isError拿到对象即为true的话表示网络请求被拒绝了。可以先判断之后再做订阅值变化的流，否则流将一直不会有回调。
   *        progress有可能拿到对象就是1（表示传入的url都是之前已经下载好的）
   */
  Future<DownloadStateModel> batchDownResource(
      List<ResourceModel> models) async {
    var _downloadStateModel = DownloadStateModel();
    var streamSubscribes = <StreamSubscription>[];
    streamSubscribes.add(
        _downloadStateModel.valueChangeStreamControl.stream.listen((value) {
      if (_downloadStateModel.isProgressArchive ||
          _downloadStateModel.isError) {
        //下载完成或者中途失败就把订阅全部取消，需要重新调用批量下载
        for (var subscribe in streamSubscribes) {
          subscribe.cancel();
        }
      }
    }));
    //需要下载的模型
    var needDownModels = <ResourceModel>[];
    //需要下载模型的对应的头文件
    var downHeaderDic = <String, HeadVerifyModel>{};
    for (var i = 0; i < models.length; i++) {
      var model = models[i];
      var headerModel = await ResourceProviderTool.getUrlHeadVerify(model.url,
          resourceSize: model.resourceSize,
          verificationNumberStr: model.verificationNumberStr);
      _downloadStateModel.changeProgressMap(model.url, 0);
      _downloadStateModel.changeByteMap(model.url, headerModel.byteNum);
      downHeaderDic[model.url] = headerModel;
      if (_resourceMapLoaded.containsKey(model.url)) {
        var tempModel = _resourceMapLoaded[model.url]!;
        var path =
            _getFileAbsolutePath(tempModel.isShowList, tempModel.fileName);
        var contentAndVerity = await ResourceProviderTool.contentAndVerityPass(
            tempModel, path, headerModel);
        if (contentAndVerity) {
          _downloadStateModel.changeProgressMap(model.url, 100);
          continue;
        } else {
          //清除本地sql、loaded、资源指引
          unawaited(deleteTask([tempModel.url], isComplete: true));
          needDownModels.add(model);
        }
      } else {
        needDownModels.add(model);
      }
    }
    for (var i = 0; i < needDownModels.length; i++) {
      var model = needDownModels[i];
      var headerModel = downHeaderDic[model.url];
      var taskId = await downResource(model: model, headerModel: headerModel);
      if (taskId != null) {
        var tempModel = _resourceMapLoadding[taskId]!;
        _downloadStateModel.changeProgressMap(
            tempModel.url, tempModel.progress);
        //共享资源
        streamSubscribes
            .add(tempModel.refreshStreamControl.stream.listen((value) {
          _downloadStateModel.changeProgressMap(
              tempModel.url, tempModel.progress);
          if (ResourceProviderTool.isErrorTaskState(tempModel.status)) {
            _downloadStateModel.changeErrorState(errorState: true);
          }
          _downloadStateModel.valueChangeStreamControl.add(null);
        }));
      } else {
        _downloadStateModel.changeErrorState(errorState: true);
        //考虑到批量下载，流量下载弹框不用重复提醒的问题，如果taskid为null返回，这里就表示是执行了取消流量下载，那么就不再执行下面的循环，直接结束
        break;
      }
    }
    return _downloadStateModel;
  }

  //loadResource的小函数，用于决定自动下载的url下载等待返回本地路径操作
  Future<String?> _loadResourceAutoDownload(ResourceModel model,
      {bool autoDownLoad = false, HeadVerifyModel? headerModel}) async {
    if (autoDownLoad) {
      var selectTaskId =
          await downResource(model: model, headerModel: headerModel);
      if (selectTaskId == null) {
        return null;
      }
      var tempModel = _resourceMapLoadding[selectTaskId];
      //等待非下载中或者在下载队列的任意一个状态返回
      await tempModel?.refreshStreamControl.stream.firstWhere((value) {
        return ![DownloadTaskStatus.enqueued, DownloadTaskStatus.running]
            .contains(tempModel.status);
      }, orElse: () => null);
      if (tempModel?.status == DownloadTaskStatus.complete) {
        var tempModel = _resourceMapLoaded[model.url]!;
        return _getFileAbsolutePath(tempModel.isShowList, tempModel.fileName);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /* 提供外部审查本地数据库的工具方法，获取某些url对应sql的存储数据内容，不传将读取所有数据库内容
   * urls: 想要查询的url字符串数组
   */
  Future<List<Map>> getLocalSqlContent({List<String>? urls}) {
    urls ??= <String>[];
    var result = sqfliteUtil.bcSelectDataForTab(
        urls.isEmpty ? {} : {'url': urls},
        tableName: _tableName);
    return result;
  }

  /*
   * 删除任务
   * taskId,任务id，
   * url, 下载任务的url
   * isComplete 是否是已经下载完成的任务，默认下载中的任务
   */
  Future<bool> deleteTask(List<String> urls, {bool isComplete = false}) async {
    if (urls.isEmpty) {
      BotToast.showText(text: '删除文件url不能为空');
      return false;
    }
    await synchronized(() =>
        sqfliteUtil.bcDeleteDataForTable({'url': urls}, tableName: _tableName));
    if (isComplete) {
      for (var url in urls) {
        await synchronized(() async {
          var tempModel = _resourceMapLoaded[url];
          var path = tempModel == null
              ? null
              : _getFileAbsolutePath(tempModel.isShowList, tempModel.fileName);
          if (path != null && await File(path).exists()) {
            var result = await DownLoaderPath.deleteFile(path);
            if (!result) {
              _reloadArrStream();
              BotToast.showText(text: '文件删除失败请重试!');
            }
          }
          _resourceMapLoaded.remove(url);
          _reloadArrStream();
        });
      }
    } else {
      var urlTomodels = <LocalResourceModel>[];
      for (var model in _resourceMapLoadding.values) {
        if (urls.contains(model.url)) {
          urlTomodels.add(model);
        }
      }
      if (urlTomodels.isNotEmpty) {
        for (var urlTomodel in urlTomodels) {
          await FlutterDownloader.cancel(taskId: urlTomodel.taskId);
          _resourceMapLoadding.remove(urlTomodel.taskId);
          _reloadArrStream();
        }
      }
    }
    return true;
  }

  /*
   * 继续的任务,针对暂停的状态的任务
   * urls是指需要继续的任务，不传或者空数组将表示所有ResourceProvider执行的下载继续
   */
  Future resumeTasks({List<String>? urls}) async {
    var tasks = await FlutterDownloader.loadTasks();
    var pausedTasks = tasks
        ?.where((element) => element.status == DownloadTaskStatus.paused)
        .toList();
    if (urls != null && urls.isNotEmpty) {
      pausedTasks?.forEach((element) async {
        if (urls.contains(element.url)) {
          await _resumeTaskTool(element);
        }
      });
    } else {
      pausedTasks?.forEach(
        (element) async {
          await _resumeTaskTool(element);
        },
      );
    }
  }

  Future _resumeTaskTool(DownloadTask task) async {
    var oldTaskId = task.taskId;
    if (_resourceMapLoadding.containsKey(oldTaskId)) {
      var newTaskId = await FlutterDownloader.resume(taskId: oldTaskId);
      if (newTaskId != null) {
        await _changeTaskId(oldTaskId, newTaskId);
      }
    }
    //如果不存在下载列表中的，无法获取之前下载的ResurceModel信息,无法执行下载，或者说执行了下载也无法读取得到，这里就不执行下载˝
  }

  /*
   * 暂停任务，针对下载中的状态的任务
   * urls是指需要暂停的任务，不传或者空数组将表示所有ResourceProvider执行的下载暂停
   */
  Future pauseTasks({List<String>? urls}) async {
    var tasks = await FlutterDownloader.loadTasks();
    var runingTasks = tasks
        ?.where((element) => [
              DownloadTaskStatus.running,
              DownloadTaskStatus.enqueued
            ].contains(element.status))
        .toList();
    if (urls != null && urls.isNotEmpty) {
      runingTasks?.forEach((element) async {
        if (urls.contains(element.url)) {
          await FlutterDownloader.pause(taskId: element.taskId);
        }
      });
    } else {
      runingTasks?.forEach((element) async {
        await FlutterDownloader.pause(taskId: element.taskId);
      });
    }
  }

  /*
   * 重试任务,针对所有下载未成功的状态的任务
   * urls是指需要重试的任务，不传或者空数组将表示所有ResourceProvider执行的下载重试
   */
  Future retryTasks({List<String>? urls}) async {
    var tasks = await FlutterDownloader.loadTasks();
    var canRetryTask = tasks
        ?.where((element) => [
              DownloadTaskStatus.undefined,
              DownloadTaskStatus.canceled,
              DownloadTaskStatus.failed,
            ].contains(element.status))
        .toList();
    if (urls != null && urls.isNotEmpty) {
      canRetryTask?.forEach((element) async {
        if (urls.contains(element.url)) {
          await _retryTaskTool(element);
        }
      });
    } else {
      canRetryTask?.forEach((element) async {
        await _retryTaskTool(element);
      });
    }
  }

  Future _retryTaskTool(DownloadTask task) async {
    var oldTaskId = task.taskId;
    if (_resourceMapLoadding.containsKey(oldTaskId)) {
      var newTaskId = await FlutterDownloader.retry(taskId: oldTaskId);
      if (newTaskId != null) {
        await _changeTaskId(oldTaskId, newTaskId);
      }
    }
    //如果不存在下载列表中的，无法获取之前下载的ResurceModel信息,无法执行下载，或者说执行了下载也无法读取得到，这里就不执行下载
  }

/*
 * 更换taskid
 */
  Future _changeTaskId(String oldTaskId, String newTaskId) async {
    var tempModel = _resourceMapLoadding[oldTaskId]!;
    tempModel.taskId = newTaskId;
    _resourceMapLoadding.remove(oldTaskId);
    _resourceMapLoadding.addAll({newTaskId: tempModel});
    var result = await sqfliteUtil
        .bcSelectDataForTab({'taskId': oldTaskId}, tableName: _tableName);
    if (result.isNotEmpty) {
      await sqfliteUtil.bcChangeDataWithTableName(
          {'taskId': newTaskId}, {'taskId': oldTaskId},
          tableName: _tableName);
    } else {
      await sqfliteUtil
          .bcAddDataForTable([tempModel.toJson()], tableName: _tableName);
    }
    _reloadArrStream();
  }

  //获取文件的全路径
  String _getFileAbsolutePath(int? isShowList, String fileName) {
    return ((isShowList != null && isShowList == 1)
            ? _saveListParentPath
            : _saveTmpParentPath) +
        '/' +
        fileName;
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _receivePort?.close();
    for (var subscription in _connectSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

//lazy
  SqfliteUtil? _sqfliteUtil;
  SqfliteUtil get sqfliteUtil {
    if (_sqfliteUtil == null) {
      _sqfliteUtil = SqfliteUtil(dbName: 'brainco_download.db');
      _sqfliteUtil!.printSqlScene(scene: false);
      if (_sqflitePath != null) {
        _sqfliteUtil!.initlize(basePath: _sqflitePath);
      } else {
        DownLoaderPath.getSqflitePath().then((path) {
          _sqfliteUtil!.initlize(basePath: path);
        });
      }
    }
    return _sqfliteUtil!;
  }
}
