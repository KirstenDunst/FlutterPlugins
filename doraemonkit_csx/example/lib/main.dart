import 'package:bot_toast/bot_toast.dart';
import 'package:doraemonkit_csx/focus_element/element_util.dart';
import 'package:doraemonkit_csx/observer/nav_observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'global_static.dart';
import 'mock_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        var offset = event.localPosition;
        var ele = ElementUtil.resolveTree(offset, context);
        if (ele != null) {
          if (kDebugMode) {
            print('>>>>>>>>>${ElementUtil.toInfoString(ele)}');
          }
        } else {}
      },
      child: MaterialApp(
        navigatorKey: GlobalStatic.navigatorKey,
        title: 'webview测试',
        theme: ThemeData(primarySwatch: Colors.blue),
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver(), CsxKitNavObserver()],
        home: MyAppHome(),
      ),
    );
  }
}

class MyAppHome extends StatefulWidget {
  const MyAppHome({super.key});

  @override
  State<MyAppHome> createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => MockPage()),
            ),
            child: const Text('csx kit'),
          ),
        ],
      ),
    );
  }
}
