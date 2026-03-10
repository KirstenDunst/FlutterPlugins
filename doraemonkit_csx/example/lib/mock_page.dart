import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:doraemonkit_csx/csx_kit.dart';
import 'package:doraemonkit_csx/engine/dio_log_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'global_static.dart';

class MockPage extends StatefulWidget {
  const MockPage({super.key});

  @override
  State<MockPage> createState() => _MockPageState();
}

class _MockPageState extends State<MockPage> {
  @override
  void initState() {
    super.initState();
    CsxKitShare.instance.init(
      (msg) => BotToast.showText(text: msg),
      print,
      context,
      GlobalStatic.navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Do kit trans Csx Kit')),
      body: Column(
        children: [
          Row(),
          ElevatedButton(
            onPressed: () => mockHttpPost(),
            child: const Text('mock netWork timer'),
          ),
          ElevatedButton(onPressed: stopAll, child: const Text('stopAllt')),
          ElevatedButton(
            onPressed: () async {
              var dioObj = Dio();
              dioObj.interceptors.add(AppLogInterceptor());
              var response = await dioObj.requestUri(
                Uri.parse(
                  // 'https://pinzhi.didichuxing.com/kop_stable/gateway?api=hhh',
                  'https://noa-test.hyxicloud.com/gfnbqgateway/hyx-plant/system/v1/getPlantDataDictionary?dataType=3,7,11,12,13,16,17,24,25',
                ),
                onReceiveProgress: (count, total) {
                  if (kDebugMode) {
                    print('>>>>>receive progress:${count / total}');
                  }
                },
              );
              if (kDebugMode) {
                print('>1>>>>>>$response');
              }
            },
            child: Text('dio mock'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    CsxKitShare.instance.close();
    super.dispose();
  }

  Timer? timer;

  void stopAll() {
    if (kDebugMode) {
      print('stopAll');
    }
    timer?.cancel();
    timer = null;
  }

  void mockHttpPost() async {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var client = HttpClient();
      var url =
          'https://noa-test.hyxicloud.com/gfnbqgateway/hyx-plant/system/v1/getPlantDataDictionary?dataType=3,7,11,12,13,16,17,24,25';
      // 'https://pinzhi.didichuxing.com/kop_stable/gateway?api=hhh';
      var request = await client.postUrl(Uri.parse(url));
      var map1 = <String, String>{};
      map1['v'] = '1.0';
      map1['month'] = '7';
      map1['day'] = '25';
      map1['key'] = 'bd6e35a2691ae5bb8425c8631e475c2a';
      request.add(utf8.encode(json.encode(map1)));
      request.add(utf8.encode(json.encode(map1)));
      var response = await request.close();
      var responseBody = await response.transform(utf8.decoder).join();
      if (kDebugMode) {
        print('>>>>>>>$responseBody');
      }
    });
  }

  void mockHttpGet() async {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var client = HttpClient();
      var url = 'https://www.baidu.com';
      var request = await client.postUrl(Uri.parse(url));
      var response = await request.close();
      var responseBody = await response.transform(utf8.decoder).join();
      if (kDebugMode) {
        print('>>>>>>>$responseBody');
      }
    });
  }
}
