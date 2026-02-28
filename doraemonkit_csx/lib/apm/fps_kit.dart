import 'dart:ui';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/material.dart';

import '../apm.dart';
import '../kit.dart';
import '../widget/fps_chart.dart';

class FpsInfo implements IInfo {
  final int fps;
  final String? pageName;
  const FpsInfo(this.fps, {this.pageName});

  @override
  int getValue() {
    return fps;
  }
}

class FpsKit extends ApmKit {
  int lastFrame = 0;

  @override
  String getKitName() {
    return ApmKitName.kitFps;
  }

  @override
  void start() {
    WidgetsBinding.instance.addTimingsCallback((timings) {
      int fps = 0;
      for (var element in timings) {
        FrameTiming frameTiming = element;
        fps = frameTiming.totalSpan.inMilliseconds;
        if (checkValid(fps)) {
          var fpsInfo = FpsInfo(fps);
          save(fpsInfo);
        }
      }
    });
  }

  bool checkValid(int fps) {
    return fps >= 0 && fps < 500;
  }

  @override
  void stop() {}

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 240);
  }

  @override
  Widget createDisplayPage() {
    return FpsPage();
  }

  @override
  String getIcon() {
    return 'assets/images/dk_frame_hist.png';
  }
}

class FpsPage extends StatefulWidget {
  const FpsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return FpsPageState();
  }
}

class FpsPageState extends State<FpsPage> {
  @override
  Widget build(BuildContext context) {
    var kit = ApmKitManager.instance.getKit<FpsKit>(ApmKitName.kitFps);
    List<IInfo> list = [];
    if (kit != null) {
      list = kit.storage.getAll();
    }
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 6),
                    child: Image.asset(
                      'assets/images/dk_fps_chart.png',
                      height: 16,
                      width: 16,
                      package: dkPackageName,
                    ),
                  ),
                  Text(
                    '最近240帧耗时',
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
            FpsBarChart(list),
          ],
        ),
      ),
    );
  }
}
