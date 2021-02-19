import 'dart:ui';

import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:doraemonkit_csx/widget/fps_chart.dart';

import 'apm.dart';

class FpsInfo implements IInfo {
  int fps;
  String pageName;

  @override
  int getValue() {
    return fps;
  }
}

class FpsKit extends ApmKit {
  int lastFrame = 0;

  @override
  String getKitName() {
    return ApmKitName.KIT_FPS;
  }

  @override
  void start() {
    WidgetsBinding.instance.addTimingsCallback((timings) {
      int fps = 0;
      timings.forEach((element) {
        FrameTiming frameTiming = element;
        fps = frameTiming.totalSpan.inMilliseconds;
        if (checkValid(fps)) {
          FpsInfo fpsInfo = new FpsInfo();
          fpsInfo.fps = fps;
          save(fpsInfo);
        }
      });
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
    return Images.dk_frame_hist;
  }

}

class FpsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FpsPageState();
  }
}

class FpsPageState extends State<FpsPage> {
  @override
  Widget build(BuildContext context) {
    FpsKit kit = ApmKitManager.instance.getKit<FpsKit>(ApmKitName.KIT_FPS);
    List<IInfo> list = new List();
    if (kit != null) {
      list = kit.storage.getAll();
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              height: 44,
              child: Row(
                children: [
                  Container(
                    child: Image.asset(Images.dk_fps_chart,
                        package: DoKit.PACKAGE_NAME, height: 16, width: 16),
                    margin: EdgeInsets.only(left: 22, right: 6),
                  ),
                  Text('最近240帧耗时',
                      style: TextStyle(
                          color: Color(0xff333333),
                          fontWeight: FontWeight.normal,
                          fontFamily: 'PingFang SC',
                          fontSize: 14))
                ],
              )),
          Divider(
            height: 0.5,
            color: Color(0xffdddddd),
            indent: 16,
            endIndent: 16,
          ),
          FpsBarChart(data: list)
        ],
      ),
    );
  }
}
