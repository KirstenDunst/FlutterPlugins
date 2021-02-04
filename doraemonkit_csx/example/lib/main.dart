import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/services.dart';

void main() {
  DoKit.runApp(
    app: DoKitApp(MyApp()),
    useInRelease: true,
    logCallback: (log) {
      String i = log;
    },
    exceptionCallback: (obj, trace) {
      print('ttt$obj');
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoKit Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DoKitTestPage(),
    );
  }
}

class DoKitTestPage extends StatefulWidget {
  @override
  _DoKitTestPageState createState() => _DoKitTestPageState();
}

class _DoKitTestPageState extends State<DoKitTestPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: FlatButton(
                child: Text('Mock Http Post',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onPressed: mockHttpPost,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: FlatButton(
                child: Text('Mock Http Get',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onPressed: mockHttpGet,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: FlatButton(
                child: Text('Test Method Channel',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onPressed: () {
                  testMethodChannel();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: FlatButton(
                child: Text('Open Route Page',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onPressed: () {
                  Navigator.of(context, rootNavigator: false).push(
                      new MaterialPageRoute(
                          builder: (context) {
                            //指定跳转的页面
                            return new TestPage2();
                          },
                          settings: new RouteSettings(
                              name: 'page1', arguments: ['test', '111'])));
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Color(0xffcccccc)),
              margin: EdgeInsets.only(bottom: 30),
              child: FlatButton(
                child: Text('Stop Timer',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                    )),
                onPressed: stopAll,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Timer timer;

  void testMethodChannel() {
    timer?.cancel();
    timer = new Timer.periodic(new Duration(seconds: 2), (timer) async {
      const MethodChannel _kChannel =
          MethodChannel('plugins.flutter.io/package_info');
      final Map<String, dynamic> map =
          await _kChannel.invokeMapMethod<String, dynamic>('getAll');
    });
  }

  void stopAll() {
    print('stopAll');
    timer?.cancel();
    timer = null;
  }

  void mockHttpPost() async {
    timer?.cancel();
    timer = new Timer.periodic(new Duration(seconds: 2), (timer) async {
      HttpClient client = new HttpClient();
      String url = 'https://pinzhi.didichuxing.com/kop_stable/gateway?api=hhh';
      HttpClientRequest request = await client.postUrl(Uri.parse(url));
      Map<String, String> map1 = new Map();
      map1["v"] = "1.0";
      map1["month"] = "7";
      map1["day"] = "25";
      map1["key"] = "bd6e35a2691ae5bb8425c8631e475c2a";
      request.add(utf8.encode(json.encode(map1)));
      request.add(utf8.encode(json.encode(map1)));
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
    });
  }

  void mockHttpGet() async {
    timer?.cancel();
    timer = new Timer.periodic(new Duration(seconds: 2), (timer) async {
      HttpClient client = new HttpClient();
      String url = 'https://www.baidu.com';
      HttpClientRequest request = await client.postUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
    });
  }
}

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => {
                Navigator.of(context, rootNavigator: false).push(
                    new MaterialPageRoute(
                        builder: (context) {
                          //指定跳转的页面
                          return new TestPage2();
                        },
                        settings: new RouteSettings(
                            name: 'page1', arguments: ['test', '111'])))
              },
              child: Text(
                'page1:',
              ),
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headline4,
            ),
            Container(height: 100, width: 300)
          ],
        ),
      ),
    );
  }
}

class TestPage2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestPageState2();
  }
}

class TestPageState2 extends State<TestPage2> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'page2:',
              ),
              Text(
                '0',
                style: Theme.of(context).textTheme.headline4,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TestPage3 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestPageState3();
  }
}

class TestPageState3 extends State<TestPage3> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => {
                Navigator.of(context, rootNavigator: false)
                    .push(new MaterialPageRoute(
                        builder: (context) {
                          //指定跳转的页面
                          return new MyApp();
                        },
                        settings: new RouteSettings(name: 'page3')))
              },
              child: Text(
                'page3:',
              ),
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headline4,
            )
          ],
        ),
      ),
    );
  }
}
