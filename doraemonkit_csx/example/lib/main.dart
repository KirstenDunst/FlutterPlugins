import 'package:bot_toast/bot_toast.dart';
import 'package:doraemonkit_csx/csx_dokit.dart';
import 'package:doraemonkit_csx/focus_element/element_util.dart';
import 'package:doraemonkit_csx/observer/nav_observer.dart';
import 'package:doraemonkit_csx/page/dokit_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'global_static.dart';
import 'mock_page.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() {
  var blackList = <String>[
    'plugins.flutter.io/sensors/gyroscope',
    'plugins.flutter.io/sensors/user_accel',
    'plugins.flutter.io/sensors/accelerometer',
  ];
  CsxDokit.run(
    app: DoKitApp(MyApp()),
    useInRelease: true,
    useRunZoned: false,
    logCallback: (log) => debugPrint,
    methodChannelBlackList: blackList,
    exceptionCallback: (dynamic obj, StackTrace trace) {
      debugPrint('ttt$obj');
    },
  );

  CsxDokit.i.isDoKitPageShow((bool isShow) {
    debugPrint('isShow = $isShow');
  });

  // 业务方接入自定义能力
  CsxDokit.i.buildBizKit(
    name: 'toB',
    group: '业务专区',
    desc: '[提供自动化测试能力]',
    action: () => {debugPrint('isShow = 业务专区 toB')},
  );

  CsxDokit.i.buildBizKit(
    name: 'toC',
    group: '业务专区',
    desc: '[提供自动化测试能力]',
    action: () => {debugPrint('isShow = 业务专区 toB')},
  );

  CsxDokit.i.buildBizKit(
    name: 'toC1',
    group: '业务专区1',
    desc: '[提供自动化测试能力1]',
    action: () => {debugPrint('isShow = 业务专区 toB')},
  );

  // CsxDokit.i.buildBizKit(
  //     name: '内存检测',
  //     group: '业务专区4',
  //     desc: '[提供触发内存泄漏扫描能力]',
  //     action: () {
  //       debugPrint('提供触发内存泄漏扫描能力');
  //       CsxDokit.i.scanLeaks();
  //     });

  CsxDokit.i.buildBizKit(
    name: 'toC2',
    group: '业务专区1',
    desc: '[提供自动化测试能力1]',
    kitBuilder: () => BizKitTestPage(),
  );

  var bizKit0 = CsxDokit.i.newBizKit(name: '1111', group: '业务专区2');
  CsxDokit.i.addKit(kit: bizKit0);

  var bizKit1 = CsxDokit.i.newBizKit(name: '2222', group: '业务专区3');
  var bizKit2 = CsxDokit.i.newBizKit(name: '3333', group: '业务专区3');
  var bizKit3 = CsxDokit.i.newBizKit(name: '4444', group: '业务专区3');
  CsxDokit.i.addBizKits([bizKit1, bizKit2, bizKit3]);

  // CsxDokit.i.addKit({kit: BizKit(name: '1111', group: '业务专区2')});
}

/// ===自定义BizKit Test===
class BizKitTestPage extends StatefulWidget {
  const BizKitTestPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return BizKitTestPageState();
  }
}

class BizKitTestPageState extends State<BizKitTestPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  '自定义BizKit Test Page',
                  style: TextStyle(
                    color: Color(0xff333333),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'PingFang SC',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 0.5,
            color: Color(0xffdddddd),
            indent: 16,
            endIndent: 16,
          ),
        ],
      ),
    );
  }
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
