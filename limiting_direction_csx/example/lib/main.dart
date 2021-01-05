/*
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:12:15
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 15:35:17
 * @Description: 
 */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:limiting_direction_csx/limiting_direction_csx.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await LimitingDirectionCsx.setUpScreenDirection(
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('ios 屏幕旋转 example'),
        ),
      ),
    );
  }
}
