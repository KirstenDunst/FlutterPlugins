/*
 * @Author: Cao Shixin
 * @Date: 2021-01-05 15:53:20
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-06 15:25:11
 * @Description: 
 */
import 'package:background_alive_csx/background_alive_csx.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //自动处理后台保活机制
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        BackgroundAliveCsx.stopBackgroundTask();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        BackgroundAliveCsx.openBackgroundTask();
        break;
      case AppLifecycleState.detached: // 申请将暂时停止
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Text('手动开启后台保活'),
                onTap: () async {
                  await BackgroundAliveCsx.openBackgroundTask();
                },
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                child: Text('手动结束结束保活'),
                onTap: () async {
                  await BackgroundAliveCsx.stopBackgroundTask();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
