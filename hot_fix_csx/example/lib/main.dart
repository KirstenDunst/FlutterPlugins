/*
 * @Author: Cao Shixin
 * @Date: 2022-01-18 15:50:25
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-21 15:09:36
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    getApplicationDocumentsDirectory().then((value) async {
      print('路径：${value.path}');

      try {
        var filePath = value.path + '/bsdiff_Test';
        // await File(filePath).create(recursive: true);
        // //查分包
        // var result = NativeAdd.bsDiffWithC([
        //   'bsdiff',
        //   '${value.path}/ios-www1.zip',
        //   '${value.path}/ios-www2.zip',
        //   filePath
        // ]);
        // print('>>>>>>>>>$result');

        //合并包
        var result1 = HotFixCsx.bsPatchWithC([
          'bspatch',
          '${value.path}/ios-www1.zip',
          '${value.path}/ios-wwwnew.zip',
          filePath
        ]);
        print('>>>>>>>>>$result1');
      } catch (e) {
        print('error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('1+2=${nativeAdd(1, 2)}'),
        ),
      ),
    );
  }
}
