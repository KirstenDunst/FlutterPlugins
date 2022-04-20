/*
 * @Author: Cao Shixin
 * @Date: 2022-01-18 15:50:25
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 10:18:38
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import 'hotfix_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: const HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            getApplicationDocumentsDirectory().then((value) async {
              print('路径:${value.path}');

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
                var result = HotFixCsx.bsPatchWithC([
                  'bspatch',
                  '/Users/caoshixin/Library/Developer/CoreSimulator/Devices/B3792338-36F8-480C-BA8A-CC64D9E82FB3/data/Containers/Data/Application/3E611D6E-27A7-4FE9-B680-1FECA8740981/Documents/HotFix/web.zip',
                  '/Users/caoshixin/Library/Developer/CoreSimulator/Devices/B3792338-36F8-480C-BA8A-CC64D9E82FB3/data/Containers/Data/Application/3E611D6E-27A7-4FE9-B680-1FECA8740981/Documents/HotFix/download/makeup123.zip',
                  '/Users/caoshixin/Library/Developer/CoreSimulator/Devices/B3792338-36F8-480C-BA8A-CC64D9E82FB3/data/Containers/Data/Application/3E611D6E-27A7-4FE9-B680-1FECA8740981/Documents/HotFix/download/diff'
                ]);
                print('>>>>>>>>>>>>$result');
              } catch (e) {
                print('error: $e');
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('包合并'),
        ),
        Text('1+2=${nativeAdd(1, 2)}'),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HotFixScreen(),
            ),
          ),
          icon: const Icon(Icons.skip_next),
          label: const Text('热更新跳转检测'),
        )
      ],
    );
  }
}
