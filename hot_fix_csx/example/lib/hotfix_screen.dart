/*
 * @Author: Cao Shixin
 * @Date: 2022-03-02 09:40:23
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-11 10:24:44
 * @Description: 
 */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hot_fix_csx_example/channel_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HotFixScreen extends StatefulWidget {
  const HotFixScreen({Key? key}) : super(key: key);

  @override
  _HotFixScreenState createState() => _HotFixScreenState();
}

class _HotFixScreenState extends State<HotFixScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      var basePath = await getApplicationDocumentsDirectory();
      var baseDirectory = basePath.path + '/HotFix';
      if (!await Directory(baseDirectory).exists()) {
        await Directory(baseDirectory).create(recursive: true);
      }
      var baseZipPath = baseDirectory + '/web.zip';
      await ChannelUtil.copyBaseResource(baseZipPath);
      await HotFixManager.instance.setParam(
          'https://app.brainco.cn/focus-autism/mobile/hotfix/debug/2.9.0/update-manifest.json?time=${DateTime.now().millisecondsSinceEpoch}',
          ResourceModel(baseZipPath: baseZipPath));
      HotFixManager.instance.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热更新页面'),
      ),
      body: StreamBuilder(
        stream: HotFixManager.instance.refreshStream,
        builder: (context, snapData) {
          var localPath = HotFixManager.instance.availablePath + '/index.html';
          print('刷新路径:>>>>>>>>>>>$localPath');
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: WebView(
                  initialUrl: localPath,
                ),
              ),
              Text(localPath),
            ],
          );
        },
      ),
    );
  }
}
