import 'dart:io';

import 'package:doraemonkit_csx/csx_kit.dart';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/material.dart';

import '../apm.dart';
import '../apm/fps_kit.dart';
import '../apm/http_kit.dart';
import '../apm/log_kit.dart';
import '../apm/memory_kit.dart';
import '../apm/method_channel_kit.dart';
import '../apm/route_kit.dart';
import '../common/basic_clear_cache.dart';
import '../common/basic_dev_options.dart';
import '../common/basic_h5.dart';
import '../common/basic_info.dart';
import '../common/basic_languages.dart';
import '../common/basic_location.dart';
import '../common/basic_qr.dart';
import '../common/basic_sandbox.dart';
import '../common/basic_setting.dart';
import '../common/basic_userdefaults.dart';
import '../common/biz.dart';
import '../common/common.dart';
import '../kit.dart';
import '../ui/kit_page.dart';

class KitsPage extends StatefulWidget {
  const KitsPage({super.key});

  static String tag = KitPageManager.kitAll;
  static final GlobalKey<KitsPageState> residentPageKey =
      GlobalKey<KitsPageState>();

  @override
  State<KitsPage> createState() => KitsPageState();
}

class KitsPageState extends State<KitsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 237, 237),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                _getTitle(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(child: _getPage()),
          _bottomTab(),
        ],
      ),
    );
  }

  Widget _bottomTab() {
    return Container(
      height: CsxKitShare.instance.areaPadding.bottom + 40,
      color: Colors.white,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buildBottomWidgets(),
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
            onTap: kit.tabAction,
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              height: 29,
              child: Text(
                key,
                style: TextStyle(
                  color: KitsPage.tag == key
                      ? const Color(0xFF337CC4)
                      : const Color(0xff333333),
                  fontWeight: FontWeight.normal,
                  fontFamily: 'PingFang SC',
                  decoration: TextDecoration.none,
                  fontSize: 13,
                ),
              ),
            ),
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
          onTap: () {
            _tapListener(KitPageManager.kitAll);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            height: 29,
            child: Text(
              KitPageManager.kitAll,
              style: TextStyle(
                color: KitsPage.tag == KitPageManager.kitAll
                    ? const Color(0xFF337CC4)
                    : const Color(0xff333333),
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
    return list;
  }

  void _tapListener(String current) {
    setState(() {
      KitsPage.tag = current;
    });
  }

  Widget _getPage() {
    Widget? page;
    page ??= ApmKitManager.instance.getKit(KitsPage.tag)?.createDisplayPage();
    page ??= CommonKitManager.instance
        .getKit(KitsPage.tag)
        ?.createDisplayPage();
    page ??= BizKitManager.instance.getKit(KitsPage.tag)?.displayPage();
    page ??= _initWidget();
    return page;
  }

  String _getTitle() {
    String? title;
    title ??= ApmKitManager.instance.getKit(KitsPage.tag)?.getKitName();
    title ??= CommonKitManager.instance.getKit(KitsPage.tag)?.getKitName();
    title ??= BizKitManager.instance.getKit(KitsPage.tag)?.getKitName();
    title ??= 'CsxKit';
    return title;
  }

  Widget _initWidget() {
    var specialArr = [];
    if (Platform.isAndroid) {
      specialArr.add(BasicDevOptionsKit());
      specialArr.add(BasicLanguagesKit());
    } else {
      specialArr.add(BasicSettingKit());
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _sectionContent('常驻工具', [HttpKit(), LogKit(), MethodChannelKit()]),
          _sectionContent('基础工具', [
            BasicInfoKit(),
            BasicClearCacheKit(),
            BasicH5Kit(),
            BasicLocationsKit(),
            BasicQRKit(),
            BasicSandBoxKit(),
            BasicUserDefaultsKit(),
            ...specialArr,
          ]),
          _sectionContent('其他工具', [FpsKit(), RouteKit(), MemoryKit()]),
        ],
      ),
    );
  }

  Widget _sectionContent(String title, List<IKit> arr) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: arr.map((e) => _cellWidget(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _cellWidget(IKit apm) {
    return GestureDetector(
      onTap: () {
        setState(() {
          apm.tabAction();
        });
        
      },
      // () {
      //   Widget? diaplayPage;
      //   if (apm is ApmKit) {
      //     diaplayPage = apm.createDisplayPage();
      //   } else if (apm is CommonKit) {
      //     diaplayPage = apm.createDisplayPage();
      //   }
      //   if (diaplayPage != null) {
      //     CommonPageInsertTool.overlayInsert(apm.getKitName(), diaplayPage);
      //   }
      // },
      child: Column(
        children: [
          Image.asset(apm.getIcon(), width: 40, package: dkPackageName),
          Text(apm.getKitName(), style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class CommonPageInsertTool {
  static overlayInsert(String title, Widget child) {
    Navigator.of(CsxKitShare.instance.overlayContext!).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: InkWell(
              onTap: () => Navigator.pop(CsxKitShare.instance.overlayContext!),
              child: Icon(Icons.arrow_back_ios_new),
            ),
          ),
          body: child,
        ),
      ),
    );
  }
}
