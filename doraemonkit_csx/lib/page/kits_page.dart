import 'dart:io';

import 'package:doraemonkit_csx/csx_kit.dart';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apm.dart';
import '../apm/fps_kit.dart';
// import '../apm/http_kit.dart';
import '../apm/http_kit_dio.dart';
import '../apm/log_kit.dart';
import '../apm/memory_kit.dart';
import '../apm/method_channel_kit.dart';
import '../apm/route_kit.dart';
import '../common/basic_clear_cache.dart';
import '../common/basic_dev_options.dart';
import '../common/basic_h5.dart';
import '../common/basic_info.dart';
import '../common/basic_languages.dart';
import '../common/basic_qr.dart';
import '../common/basic_sandbox.dart';
import '../common/basic_setting.dart';
import '../common/basic_userdefaults.dart';
import '../common/biz.dart';
import '../common/common.dart';
import '../kit.dart';

class KitsPage extends StatefulWidget {
  const KitsPage({super.key});

  static String tag = KitPageManager.kitAll;
  static final GlobalKey<KitsPageState> residentPageKey =
      GlobalKey<KitsPageState>();

  @override
  State<KitsPage> createState() => KitsPageState();
}

class KitsPageState extends State<KitsPage> {
  late bool _onDrag;
  final GlobalKey _residentContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _onDrag = false;
  }

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
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16),
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
            onTap: () {
              setState(() {
                kit.tabAction();
              });
            },
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
            setState(() {
              KitsPage.tag = KitPageManager.kitAll;
            });
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

  Widget _getPage() {
    Widget? page;
    page ??= ApmKitManager.instance.getKit(KitsPage.tag)?.createDisplayPage();
    page ??=
        CommonKitManager.instance.getKit(KitsPage.tag)?.createDisplayPage();
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
          _normalStateContent(
            '常驻工具',
            subTitle: '[最多放置4个]',
            KitPageManager.instance.getResidentKit(),
          ),
          _sectionContent(
              '基础工具',
              [
                BasicInfoKit(),
                BasicClearCacheKit(),
                BasicH5Kit(),
                BasicQRKit(),
                BasicSandBoxKit(),
                BasicUserDefaultsKit(),
                ...specialArr,
              ],
              subTitle: '[拖动图标放入常驻工具]'),
          _sectionContent(
              '性能检测工具',
              [
                HttpKit(),
                LogKit(),
                MethodChannelKit(),
              ],
              subTitle: '[拖动图标放入常驻工具]'),
          _sectionContent(
              '其他工具',
              [
                FpsKit(),
                RouteKit(),
                MemoryKit(),
              ],
              subTitle: '[拖动图标放入常驻工具]'),
        ],
      ),
    );
  }

  Widget _normalStateContent(
    String title,
    Map<String, IKit> kitMap, {
    String? subTitle,
  }) {
    return _contentContent(
      title,
      kitMap
          .map(
            (key, value) => MapEntry(
              key,
              Draggable(
                feedback: _cellWidget(value),
                onDragStarted: () {
                  setState(() {
                    _onDrag = true;
                  });
                },
                onDraggableCanceled: (Velocity velocity, Offset offset) {
                  setState(() {
                    _onDrag = false;
                    if (!inResidentContainerEdge(offset)) {
                      KitPageManager.instance.removeResidentKit(key);
                    }
                  });
                },
                onDragEnd: (DraggableDetails detail) {
                  setState(() {
                    _onDrag = false;
                    if (!inResidentContainerEdge(detail.offset)) {
                      KitPageManager.instance.removeResidentKit(key);
                    }
                  });
                },
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      value.tabAction();
                    });
                  },
                  padding: const EdgeInsets.all(0),
                  minWidth: 40,
                  child: _cellWidget(value),
                ),
              ),
            ),
          )
          .values
          .toList(),
      subTitle: subTitle,
      needGlobalKey: true,
    );
  }

  bool inResidentContainerEdge(Offset? offset) {
    final size = _residentContainerKey.currentContext?.size;
    if (offset == null || size == null) {
      return false;
    }

    final position =
        (_residentContainerKey.currentContext?.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);
    final rc1 = Rect.fromLTWH(offset.dx, offset.dy, 80, 80);
    final rc2 = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );

    return rc1.left + rc1.width > rc2.left &&
        rc2.left + rc2.width > rc1.left &&
        rc1.top + rc1.height > rc2.top &&
        rc2.top + rc2.height > rc1.top;
  }

  Widget _sectionContent(String title, List<IKit> arr, {String? subTitle}) {
    return _contentContent(
      title,
      arr
          .map(
            (e) => Draggable(
              feedback: _cellWidget(e),
              onDragStarted: () => {
                setState(() {
                  _onDrag = true;
                }),
              },
              onDragEnd: (detail) => {
                setState(() {
                  if (inResidentContainerEdge(detail.offset)) {
                    KitPageManager.instance.addResidentKit(e.getKitName());
                  }
                  _onDrag = false;
                }),
              },
              onDraggableCanceled: (v, offset) => {
                setState(() {
                  if (inResidentContainerEdge(offset)) {
                    KitPageManager.instance.addResidentKit(e.getKitName());
                  }
                  _onDrag = false;
                }),
              },
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    e.tabAction();
                  });
                },
                padding: EdgeInsets.all(0),
                minWidth: 40,
                child: _cellWidget(e),
              ),
            ),
          )
          .toList(),
      subTitle: subTitle,
    );
  }

  Widget _contentContent(
    String title,
    List<Widget> wrapChildrens, {
    String? subTitle,
    bool needGlobalKey = false,
  }) {
    return Container(
      key: needGlobalKey ? _residentContainerKey : null,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color:
          needGlobalKey ? (_onDrag ? Colors.red : Colors.white) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              if (subTitle != null)
                Text('  $subTitle',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
          SizedBox(height: 10),
          Wrap(spacing: 20, runSpacing: 10, children: wrapChildrens),
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
      child: Column(
        children: [
          Image.asset(apm.getIcon(), width: 40, package: dkPackageName),
          Text(apm.getKitName(),
              style: TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}

class CommonPageInsertTool {
  static overlayInsert(String title, Widget child) {
    Navigator.of(
      CsxKitShare.instance.overlayContext!,
    ).push(MaterialPageRoute(builder: (_) => child));
  }
}

class KitPageManager {
  KitPageManager._privateConstructor();

  static const String kitAll = '全部';
  static const String keyKitPageCache = 'key_kit_page_cache';
  List<String> residentList = <String>[ApmKitName.kitHttp, ApmKitName.kitLog];

  static final KitPageManager _instance = KitPageManager._privateConstructor();

  static KitPageManager get instance => _instance;

  String listToString(List<String>? list) {
    if (list == null || list.isEmpty) {
      return '';
    }
    String? result;
    for (final item in list) {
      if (result == null) {
        result = item;
      } else {
        result = '$result,$item';
      }
    }

    return result.toString();
  }

  bool addResidentKit(String? tag) {
    assert(tag != null);
    if (!residentList.contains(tag)) {
      if (residentList.length >= 4) {
        return false;
      }
      residentList.add(tag!);
      SharedPreferences.getInstance().then(
        (SharedPreferences prefs) =>
            prefs.setString(keyKitPageCache, listToString(residentList)),
      );
      return true;
    }
    return false;
  }

  bool removeResidentKit(String tag) {
    if (residentList.contains(tag)) {
      residentList.remove(tag);
      SharedPreferences.getInstance().then(
        (SharedPreferences prefs) =>
            prefs.setString(keyKitPageCache, listToString(residentList)),
      );
      return true;
    }
    return false;
  }

  Map<String, IKit> getOtherKit() {
    final kits = <String, IKit>{};
    CommonKitManager.instance.kitMap.forEach((String key, CommonKit value) {
      if (!residentList.contains(key)) {
        kits[key] = value;
      }
    });
    ApmKitManager.instance.kitMap.forEach((String key, ApmKit value) {
      if (!residentList.contains(key)) {
        kits[key] = value;
      }
    });
    // VisualKitManager.instance.kitMap.forEach((String key, IKit value) {
    //   if (!residentList.contains(key)) {
    //     kits[key] = value;
    //   }
    // });
    return kits;
  }

  Map<String, IKit> getResidentKit() {
    final kits = <String, IKit>{};
    for (final element in residentList) {
      if (ApmKitManager.instance.getKit(element) != null) {
        kits[element] = ApmKitManager.instance.getKit(element)!;
      }
      // else if (VisualKitManager.instance.getKit(element) != null) {
      //   kits[element] = VisualKitManager.instance.getKit(element)!;
      // }
      else if (CommonKitManager.instance.getKit(element) != null) {
        kits[element] = CommonKitManager.instance.getKit(element)!;
      }
    }
    return kits;
  }

  void loadCache() {
    SharedPreferences.getInstance().then<dynamic>((SharedPreferences prefs) {
      if (prefs.getString(KitPageManager.keyKitPageCache) != null) {
        if (prefs.getString(KitPageManager.keyKitPageCache) == '') {
          KitPageManager.instance.residentList = <String>[];
        } else {
          KitPageManager.instance.residentList =
              prefs.getString(KitPageManager.keyKitPageCache)?.split(',') ?? [];
        }
      }
      if (KitPageManager.instance.residentList.isNotEmpty) {
        KitsPage.tag = KitPageManager.instance.residentList.first;
      } else {
        KitsPage.tag = KitPageManager.kitAll;
      }
    });
  }
}
