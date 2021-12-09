/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:21:00
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-05-15 08:46:15
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'package:flutter/material.dart';
import 'package:ios_specific_csx/ios_specific_csx.dart';
import 'package:ios_specific_csx/specific_enum.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .isHealthDataAvailable()
                    .then((value) {
                  print('健康是否可用: $value');
                });
              },
              child: Text('健康是否可用'),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx()
                    .healthHandle
                    .getHealthAuthorityStatus(
                        HealthAppSubclassification.Mindfulness)
                    .then((result) {
                  print('获取mindfulness当前的权限状态：$result');
                });
              },
              child: Text('获取mindfulness当前的权限状态'),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .requestHealthAuthority(
                        HealthAppSubclassification.Mindfulness)
                    .then((result) {
                  print('请求mindfulnes权限：${result.toJson()}');
                });
              },
              child: Text('请求mindfulnes权限'),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthMindfulness(DateTime(2021, 3, 26, 14, 10),
                        DateTime(2021, 3, 26, 14, 20))
                    .then((result) {
                  print('mindfulness加入结果：${result.toJson()}');
                });
              },
              child: Text("加入mindfulnes数据"),
            ),
            ElevatedButton(
              onPressed: () =>
                  IosSpecificCsx.instance.healthHandle.gotoHealthApp(),
              child: Text('打开健康app'),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthStature(170)
                    .then((value) => print('写入身高结果${value.toJson()}'));
              },
              child: Text('写入身高'),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx()
                    .healthHandle
                    .addHealthStature(170)
                    .then((value) => print('获取身高:${value.toJson()}'));
              },
              child: Text('获取身高'),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx()
                    .healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx()
                    .healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx()
                    .healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx()
                    .healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.healthHandle
                    .addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.commonHandle.platformVersion
                    .then((value) => print('$value'));
              },
              child: Text("通用处理"),
            ),
          ],
        ));
  }
}
