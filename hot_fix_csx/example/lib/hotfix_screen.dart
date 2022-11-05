/*
 * @Author: Cao Shixin
 * @Date: 2022-03-02 09:40:23
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-11-05 10:13:48
 * @Description: 
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'web_server.dart';

class HotFixScreen extends StatefulWidget {
  const HotFixScreen({Key? key}) : super(key: key);

  @override
  _HotFixScreenState createState() => _HotFixScreenState();
}

class _HotFixScreenState extends State<HotFixScreen> {
  late String _localPath;
  late StreamSubscription _streamSubscription;
  WebViewController? _webViewController;
  @override
  void initState() {
    super.initState();
    _localPath = '';
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var basePath = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getExternalStorageDirectory();
      var baseDirectory = basePath!.path;
      if (!await Directory(baseDirectory).exists()) {
        await Directory(baseDirectory).create(recursive: true);
      }
      var baseZipPath = baseDirectory + '/origin_resource.zip';
      await HotFixCsx.copyResourceToDevice('dist.zip', baseZipPath);
      await HotFixManager.instance.setParam(
          'https://app.brainco.cn/focus-autism/mobile/hotfix/develop/3.1.1/update-manifest.json',
          HotFixModel(baseZipPath: baseZipPath, unzipDirName: 'dist'));
      _streamSubscription =
          HotFixManager.instance.refreshStream.listen((event) {
        var localPath = HotFixManager.instance.availablePath;
        if (localPath.isNotEmpty) {
          _localPath = localPath;
          WebServer.instance.directory = localPath;
          WebServer.instance
              .stopServer()
              .then((value) => WebServer.instance.startServer().then((_) {
                    print('服务开启成功');
                    setState(() {});
                  }));
        }
      });
      HotFixManager.instance.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热更新页面'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              HotFixManager.instance.start();
            },
            icon: const Icon(Icons.skip_next),
            label: const Text('热更新手动触发'),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_localPath.isNotEmpty)
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: WebView(
                  initialUrl: WebServer.instance.localWebUrl + 'teacher',
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController = webViewController;
                  },
                  backgroundColor: Colors.white,
                  initialMediaPlaybackPolicy:
                      AutoMediaPlaybackPolicy.always_allow,
                  allowsInlineMediaPlayback: true,
                  javascriptMode: JavascriptMode.unrestricted,
                  javascriptChannels: <JavascriptChannel>{
                    JavascriptChannel(
                        name: 'Starkids',
                        onMessageReceived: (JavascriptMessage message) {
                          final info = jsonDecode(message.message);
                          if (info is! Map<String, dynamic>) {
                            return;
                          }
                          final params = info['params'];
                          final cmd = info['cmd'];
                          print('>>>>>>>>>>>$cmd');
                          if (cmd == 'onPageRendered') {
                            _webViewController?.callJS('credential', params: {
                              'access_token':
                                  'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI2ODEzNDgiLCJpc3MiOiJ1YWMiLCJleHRVc2VySWQiOiIyZWUxZTQ0MS00OGFlLTRkYjAtYThjNC03ODQzZTk2MDlhYTUiLCJsb2dpbiI6ImJpbmdmYTAxIiwidXNlcklkIjo2ODEzNDgsImlkZW50aXR5UHJvdmlkZXIiOjAsImF1dGhvcml0aWVzIjpbInVzZXIiLCJ0ZWFjaGVyIl0sInBob25lIjoiMTk5OTk5OTk5OTkiLCJkb21haW4iOiJhdXRpc20tYXBwIiwic2NvcGUiOiJBUFAiLCJuaWNrbmFtZSI6ImQyZWE0Nzg4OCIsImlhdCI6MTY1MDQxOTI5NywianRpIjoiNTYxODUxOWQ1MTkzNDhjMGFjNzZiMzBjMzQyMGE2NzQiLCJlbWFpbCI6ImJpbmdmYTAwMUB5b3BtYWlsLmNvbSJ9.JXf1iz3EkqZFtmhjCFyBiV26WTwXKILhENrNoanZYvKbdNRNeAmlPJ5yCN9VR-eLwYl6AX1MMCSZAMAVFvhnkw3Ay3QAO4uVpkptBRYDFBnT55TeptsqPTJMfUBX4RrOkM9l8YVIMB-wlUlwi8XAQr1AdPZ3PdRxRlA2nVrPaVvZ60Uxgoe8um-y0qui7FJtKdU-uTncURk1odgGGXEDe_GPqdn5wyhlCgfrjPlAaGebn1iZOVms-GUuUDBGbQ6CwIoPJmCUE1V4WP4vynGkAs3e_Lw9c00wLWLO1RcON7SXSgo6I0TKNgYDMJewoN-4EZV4WZL5O8tp9AzRlsHlew'
                            });
                          }
                        })
                  }),
            ),
          Text(_localPath),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}

extension WebViewControllerExt on WebViewController {
  Future<String> callJS(String cmd, {dynamic params}) async {
    final info = params == null ? {'cmd': cmd} : {'cmd': cmd, 'params': params};
    final str = jsonEncode(info);
    print('callJS:$str');
    var ret = '';
    try {
      ret =
          await runJavascriptReturningResult('onReceivedFlutterMessage(`$str`)')
              .timeout(const Duration(seconds: 3));
    } catch (e, _) {
      print('$e');
    }
    return ret;
  }
}
