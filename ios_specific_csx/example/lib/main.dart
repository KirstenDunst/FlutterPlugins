/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:21:00
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-04-01 15:26:44
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
                IosSpecificCsx.addHealthMindfulness(
                        DateTime(2021, 3, 26, 14, 10),
                        DateTime(2021, 3, 26, 14, 20))
                    .then((result) {
                  print('mindfulness加入结果：${result.toJson()}');
                });
              },
              child: Text("加入mindfulnes数据"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.getHealthAuthorityStatus(
                        HealthAppSubclassification.Mindfulness)
                    .then((result) {
                  print('mindfulness权限：$result');
                });
              },
              child: Text("获取mindfulness当前的权限信息"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.addHealthStature(170)
                    .then((value) => print(value.errorDescri));
              },
              child: Text("写入身高"),
            ),
          ],
        ));
  }
}
