import 'package:flutter/material.dart';

import '../apm.dart';
import '../common/biz.dart';
import '../common/common.dart';
import '../kit.dart';
import '../ui/kit_page.dart';

class ResidentPage extends StatefulWidget {
  ResidentPage() : super(key: residentPageKey);

  static String tag = KitPageManager.kitAll;
  static final GlobalKey<ResidentPageState> residentPageKey =
      GlobalKey<ResidentPageState>();

  @override
  State<StatefulWidget> createState() {
    return ResidentPageState();
  }
}

class ResidentPageState extends State<ResidentPage> {
  Widget getPage() {
    Widget? page;
    page ??= ApmKitManager.instance
        .getKit(ResidentPage.tag)
        ?.createDisplayPage();
    page ??= CommonKitManager.instance
        .getKit(ResidentPage.tag)
        ?.createDisplayPage();
    page ??= BizKitManager.instance.getKit(ResidentPage.tag)?.displayPage();
    page ??= KitPage();
    return page;
  }

  String getTitle() {
    String? title;
    title ??= ApmKitManager.instance.getKit(ResidentPage.tag)?.getKitName();
    title ??= CommonKitManager.instance.getKit(ResidentPage.tag)?.getKitName();
    title ??= BizKitManager.instance.getKit(ResidentPage.tag)?.getKitName();
    title ??= 'DoKit';
    return title;
  }

  void _tapListener(String current) {
    setState(() {
      ResidentPage.tag = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final topMargin = MediaQuery.of(context).orientation == Orientation.portrait
        ? 100
        : 0;
    if (height == 0) {
      return Container();
    }
    return Positioned(
      child: Container(
        width: width,
        color: const Color(0x88000000),
        height: height - topMargin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              width: width,
              height: height - topMargin - 50,
              //todo Scaffold在ios 11上会出现顶部组件点击事件失效问题（应该是在计算触摸事件的时候计算了刘海屏的高度，在这个高度内的控件不响应事件），这里修改了层级把标题放到了Scaffold内部
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: width,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xfff6f6f7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        getTitle(),
                        style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          color: Color(0xff000000),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      height: height - topMargin - 100,
                      color: Colors.white,
                      child: getPage(),
                    ),
                    Container(
                      height: 0.5,
                      color: const Color(0xffeae6ea),
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 50),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 0.5, color: Color(0xffeae6ea)),
            Container(
              height: 49,
              width: width,
              color: const Color(0xfff6f6f7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildBottomWidgets(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildBottomWidgets() {
    final list = <Widget>[];
    KitPageManager.instance.getResidentKit().forEach((String key, IKit kit) {
      list.add(
        Expanded(
          flex: 1,
          child: GestureDetector(
            child: Container(
              alignment: Alignment.center,
              height: 29,
              child: Text(
                key,
                style: TextStyle(
                  color: ResidentPage.tag == key
                      ? const Color(0xFF337CC4)
                      : const Color(0xff333333),
                  fontWeight: FontWeight.normal,
                  fontFamily: 'PingFang SC',
                  decoration: TextDecoration.none,
                  fontSize: 13,
                ),
              ),
            ),
            onTap: () {
              kit.tabAction();
            },
            behavior: HitTestBehavior.opaque,
          ),
        ),
      );
      list.add(
        Container(
          width: 0.5,
          height: 18,
          decoration: const BoxDecoration(color: Color(0xffe5e5e6)),
        ),
      );
    });
    list.add(
      Expanded(
        flex: 1,
        child: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            height: 29,
            child: Text(
              KitPageManager.kitAll,
              style: TextStyle(
                color: ResidentPage.tag == KitPageManager.kitAll
                    ? const Color(0xFF337CC4)
                    : const Color(0xff333333),
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                fontSize: 13,
              ),
            ),
          ),
          onTap: () {
            _tapListener(KitPageManager.kitAll);
          },
          behavior: HitTestBehavior.opaque,
        ),
      ),
    );
    return list;
  }
}
