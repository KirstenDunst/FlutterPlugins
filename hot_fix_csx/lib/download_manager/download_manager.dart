/*
 * @Author: Cao Shixin
 * @Date: 2022-04-22 16:41:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-24 11:06:12
 * @Description: 下载管理页面（用于开发检测查看使用）
 */
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hot_fix_csx/ext/num_ext.dart';

import 'downloader_model.dart';
import 'resource_provider.dart';

class DownloadManagerScreen extends StatefulWidget {
  const DownloadManagerScreen({Key? key}) : super(key: key);

  @override
  State<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends State<DownloadManagerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        backgroundColor: Colors.grey.withOpacity(0.4),
        body: StreamBuilder(
          stream: StreamGroup.merge([
            ResourceProvider.instance.resourceMapLoaddingStreamControl.stream,
            ResourceProvider.instance.resourceMapLoadedStreamControl.stream
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  TabBar(controller: _tabController, tabs: [
                    Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                            '已完成${ResourceProvider.instance.resourceMapLoaded.length}')),
                    Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                            '下载中${ResourceProvider.instance.resourceMapLoadding.length}'))
                  ]),
                  SizedBox(
                    height: constraints.maxHeight - 40,
                    child: TabBarView(controller: _tabController, children: [
                      StreamBuilder(
                          stream: ResourceProvider
                              .instance.resourceMapLoadedStreamControl.stream,
                          initialData:
                              ResourceProvider.instance.resourceMapLoaded,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            var tempArr = (snapshot.data
                                    as Map<String, LocalResourceModel>)
                                .values
                                .toList();
                            return ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                var model = tempArr[index];
                                return SizedBox(
                                    height: 72,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.resourceModel.name,
                                              style: TextStyle(
                                                  color: model.resourceModel
                                                          .showDownloadList
                                                      ? Colors.black
                                                      : Colors.grey),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${model.resourceModel.kindName} | ${model.resourceByte.byteFormat()}',
                                            ),
                                          ],
                                        ),
                                        Text('saveName:${model.fileName}')
                                      ],
                                    ));
                              },
                              itemCount: tempArr.length,
                            );
                          }),
                      StreamBuilder(
                          stream: ResourceProvider
                              .instance.resourceMapLoaddingStreamControl.stream,
                          initialData:
                              ResourceProvider.instance.resourceMapLoadding,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            var tempArr = (snapshot.data
                                    as Map<String, LocalResourceModel>)
                                .values
                                .toList();
                            return ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                var model = tempArr[index];
                                return _downloadNowWidget(model);
                              },
                              itemCount: tempArr.length,
                            );
                          })
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _downloadNowWidget(LocalResourceModel resourceModel) {
    return StreamBuilder(
      stream: resourceModel.refreshStreamControl.stream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var model = DownloadTool.getLoaddingCell(resourceModel.progress,
            resourceModel.status, resourceModel.resourceByte);
        return Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resourceModel.resourceModel.name,
                    style: TextStyle(
                        color: resourceModel.resourceModel.showDownloadList
                            ? Colors.black
                            : Colors.grey),
                  ),
                  Container(
                    height: 7,
                    width: 80,
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(3.5)),
                    child: LinearProgressIndicator(
                        value: model.progress / 100,
                        backgroundColor: Colors.grey,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green)),
                  ),
                  Text(
                    model.stateStr +
                        '|' +
                        model.memoryProgressStr +
                        '|' +
                        'saveName:${resourceModel.fileName}',
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (model.state == DownloadTaskStatus.running) {
                  //暂停
                  await ResourceProvider.instance
                      .pauseTasks(urls: [resourceModel.url]);
                } else if (model.state == DownloadTaskStatus.paused) {
                  //resume方法
                  await ResourceProvider.instance
                      .resumeTasks(urls: [resourceModel.url]);
                } else {
                  //重试方法
                  await ResourceProvider.instance
                      .retryTasks(urls: [resourceModel.url]);
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 72,
                width: 32,
                child: Text(
                  model.stateStr,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                //取消下载
                BotToast.showText(text: '取消下载');
                ResourceProvider.instance
                    .deleteTask([resourceModel.url], isComplete: false);
              },
              child: Container(
                alignment: Alignment.center,
                height: 72,
                width: 32,
                child: const Text(
                  '取消下载',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

//下载中的每个cell处理模型
class DownloaddingCellModel {
  //状态字符串
  String stateStr;
  String memoryProgressStr;
  int progress;
  DownloadTaskStatus state;

  DownloaddingCellModel({
    required this.stateStr,
    required this.memoryProgressStr,
    required this.progress,
    required this.state,
  });
}

class DownloadTool {
  static DownloaddingCellModel getLoaddingCell(
      int progress, DownloadTaskStatus state, int byteAll) {
    progress = max(progress, 0);
    var memoryProgressStr =
        '${(byteAll * (progress / 100)).byteFormat()}/${byteAll.byteFormat()}';
    var stateStr = '等待中';
    if (state == DownloadTaskStatus.paused) {
      stateStr = '已暂停';
    } else if (state == DownloadTaskStatus.running) {
      stateStr = progress > 0 ? '下载中' : '等待中';
    } else if (state == DownloadTaskStatus.failed ||
        state == DownloadTaskStatus.canceled) {
      stateStr = '下载失败';
    }
    return DownloaddingCellModel(
        progress: progress,
        state: state,
        memoryProgressStr: memoryProgressStr,
        stateStr: stateStr);
  }
}
