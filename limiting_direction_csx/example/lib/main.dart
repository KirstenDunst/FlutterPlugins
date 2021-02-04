/*
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:12:15
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-14 13:44:10
 * @Description: 
 */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:limiting_direction_csx/limiting_direction_csx.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await LimitingDirectionCsx.setScreenDirection(
        DeviceDirectionMask.Landscape);
  } else {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    print('>>>>>>>>>>>>>>>${LimitingDirectionCsx().currentDeviceOrientation}');
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Plugin example app'),
          ),
          body: StreamBuilder<UIDeviceOrientation>(
            stream: LimitingDirectionCsx().getDeviceDirectionStream(),
            builder: (context, AsyncSnapshot snapshot) {
              return Text('结果：${snapshot.data}');
            },
          )),
    );
  }
}
