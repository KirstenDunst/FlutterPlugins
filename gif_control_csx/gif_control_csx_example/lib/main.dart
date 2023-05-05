/*
 * @Author: Cao Shixin
 * @Date: 2023-04-13 17:23:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-04-14 11:46:10
 * @Description: 
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gif_control_csx/gif_control_csx.dart';
import 'const.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late GifController controller1, controller2, controller3, controller4;

  @override
  void initState() {
    controller1 = GifController(vsync: this);
    controller2 = GifController(vsync: this);
    controller4 = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller1.repeat(
          min: 0, max: 53, period: const Duration(milliseconds: 200));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller2.repeat(
          min: 0, max: 13, period: const Duration(milliseconds: 200));
      controller4.repeat(
          min: 0, max: 13, period: const Duration(milliseconds: 200));
    });
    controller3 = GifController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? ''),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                child: Text("不同类型图片"),
              ),
              Tab(
                child: Text("控制方式"),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ListView(
              children: <Widget>[
                const Text("资源"),
                GifImageCsx(
                  controller: controller1,
                  image: const AssetImage("images/animate.gif"),
                  width: 100,
                  height: 100,
                ),
                const Text("网络"),
                GifImageCsx(
                  controller: controller2,
                  image: const NetworkImage(
                      "http://img.mp.itc.cn/upload/20161107/5cad975eee9e4b45ae9d3c1238ccf91e.jpg"),
                  width: 100,
                  height: 100,
                ),
                const Text("内存"),
                GifImageCsx(
                  controller: controller4,
                  image: MemoryImage(base64Decode(base64_url)),
                  width: 100,
                  height: 100,
                )
              ],
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text("无限循环"),
                      onPressed: () {
                        controller3.repeat(
                            min: 0,
                            max: 25,
                            period: const Duration(milliseconds: 500));
                      },
                    ),
                    ElevatedButton(
                      child: const Text("暂停"),
                      onPressed: () {
                        controller3.stop();
                      },
                    ),
                    ElevatedButton(
                      child: const Text("播放到末尾一次"),
                      onPressed: () {
                        controller3.animateTo(52,
                            duration: const Duration(milliseconds: 1000));
                      },
                    )
                  ],
                ),
                Slider(
                  onChanged: (v) {
                    controller3.value = v;
                    setState(() {});
                  },
                  max: 53,
                  min: 0,
                  value: controller3.value,
                ),
                GifImageCsx(
                  controller: controller3,
                  image: const AssetImage("images/animate.gif"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
