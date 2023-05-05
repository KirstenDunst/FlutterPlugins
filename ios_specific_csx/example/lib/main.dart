/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:21:00
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-03-27 09:07:28
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:ios_specific_csx/ios_specific_csx.dart';

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
      builder: BotToastInit(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    IosSpecificCsx.instance.healthHandle.logStream.listen((event) {
      print('>>>>>>>>>>>>$event');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .isHealthDataAvailable()
                  .then((value) {
                BotToast.showText(text: '健康是否可用: $value');
              }),
              child: Text('健康是否可用'),
            ),
            ElevatedButton(
              onPressed: () => showHealthAppSubclassDialog(context).then(
                (value) => value != null
                    ? IosSpecificCsx()
                        .healthHandle
                        .getHealthAuthorityStatus(value)
                        .then((result) {
                        BotToast.showText(text: '权限状态:$result');
                      })
                    : null,
              ),
              child: Text('获取权限状态'),
            ),
            ElevatedButton(
              onPressed: () => showHealthAppSubclassDialog(context).then(
                (value) => value != null
                    ? IosSpecificCsx.instance.healthHandle
                        .requestHealthAuthority(value)
                        .then((result) {
                        BotToast.showText(text: '请求权限:${result.toJson()}');
                      })
                    : null,
              ),
              child: Text('请求权限'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .requestHealthSubmodulesAuthority([
                HealthAppSubclassification.bloodOxygen,
                HealthAppSubclassification.bodyFatPercentage,
                HealthAppSubclassification.bodyMass,
                HealthAppSubclassification.bodyMassIndex
              ]).then((result) {
                BotToast.showText(text: '请求权限:${result.toJson()}');
              }),
              child: Text('请求多个子模块权限'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthMindfulness(DateTime(2022, 3, 26, 14, 10),
                      DateTime(2022, 3, 26, 14, 20))
                  .then((result) {
                BotToast.showText(text: 'mindfulness加入结果:${result.toJson()}');
              }),
              child: Text("加入mindfulnes数据"),
            ),
            ElevatedButton(
              onPressed: () =>
                  IosSpecificCsx.instance.healthHandle.gotoHealthApp(),
              child: Text('打开健康app'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthStature(170)
                  .then((value) =>
                      BotToast.showText(text: '写入身高结果${value.toJson()}')),
              child: Text('写入身高'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthBodyMassIndex(70)
                  .then((value) =>
                      BotToast.showText(text: '写入身高体重指数结果${value.toJson()}')),
              child: Text('写入身高体重指数'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthBodyFatPercentage(70)
                  .then((value) =>
                      BotToast.showText(text: '写入体脂率结果${value.toJson()}')),
              child: Text('写入体脂率'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthBodyMass(60)
                  .then((value) =>
                      BotToast.showText(text: '写入体重结果${value.toJson()}')),
              child: Text('写入体重'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthLeanBodyMass(50)
                  .then((value) =>
                      BotToast.showText(text: '写入去脂体重${value.toJson()}')),
              child: Text('写入去脂体重'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthStepCount(170)
                  .then((value) =>
                      BotToast.showText(text: '写入步数结果${value.toJson()}')),
              child: Text('写入步数'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx()
                  .healthHandle
                  .addHealthWalkingRunning(10)
                  .then((value) =>
                      BotToast.showText(text: '写入步行+跑步:${value.toJson()}')),
              child: Text('写入步行+跑步'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx()
                  .healthHandle
                  .addHealthCycling(10)
                  .then((value) =>
                      BotToast.showText(text: '写入骑行:${value.toJson()}')),
              child: Text('写入骑行'),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthHeartRate(100)
                  .then((value) =>
                      BotToast.showText(text: '写入心率：${value.toJson()}')),
              child: Text("写入心率"),
            ),
            ElevatedButton(
              onPressed: () => IosSpecificCsx.instance.healthHandle
                  .addHealthBloodOxygen(0.9)
                  .then((value) =>
                      BotToast.showText(text: '写入血氧：${value.toJson()}')),
              child: Text("写入血氧"),
            ),
            ElevatedButton(
              onPressed: () {
                IosSpecificCsx.instance.commonHandle.platformVersion
                    .then((value) => BotToast.showText(text: '$value'));
              },
              child: Text("通用处理"),
            ),
          ],
        ));
  }
}

Future<HealthAppSubclassification?> showHealthAppSubclassDialog(
        BuildContext context) =>
    showDialog(
      context: context,
      builder: (_) {
        var showArr = HealthAppSubclassMap.keys.toList();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: 260,
              height: 225,
              color: Colors.white,
              child: ListView.builder(
                itemCount: showArr.length,
                itemBuilder: (context, index) {
                  var text = showArr[index];
                  return InkWell(
                    onTap: () =>
                        Navigator.pop(context, HealthAppSubclassMap[text]),
                    child: Container(
                      height: 40,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child: Text(text),
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
