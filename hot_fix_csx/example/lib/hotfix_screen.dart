/*
 * @Author: Cao Shixin
 * @Date: 2022-03-02 09:40:23
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-02 15:19:28
 * @Description: 
 */
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
      var baseZipPath = basePath.path + '/HotFix/web.zip';
      await ChannelUtil.copyBaseResource(baseZipPath);
      HotFixManager.instance.setParam(
          'https://app.brainco.cn/focus-autism/mobile/hotfix/debug/',
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
        builder: (context, snapData) => WebView(
          initialUrl: HotFixManager.instance.availablePath + '/index.html',
        ),
      ),
    );
  }
}
