import 'package:flutter/material.dart';

import '../common/biz.dart';
import '../csx_dokit.dart';
import '../kit.dart';
import '../widget/dash_decoration.dart';
import 'kit_manage.dart';

class KitPage extends StatefulWidget {
  const KitPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _KitPage();
  }
}

class _KitPage extends State<KitPage> {
  bool _onDrag = false;
  final GlobalKey _residentContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _onDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            color: const Color(0xffffffff),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 15, bottom: 10),
                  child: Container(
                    key: _residentContainerKey,
                    decoration: _onDrag
                        ? const DashedDecoration(
                            dashedColor: Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)))
                        : null,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _normalStateContent(
                            '常驻工具',
                            subTitle: '[最多放置4个]',
                            KitPageManager.instance.getResidentKit()),
                      ],
                    ),
                  ),
                ),
                _sectionContent('基础工具', KitPageManager.instance.getBaseKit(),
                    subTitle: '[拖动图标放入常驻工具]'),
                _sectionContent('性能检测工具', KitPageManager.instance.getApmKit(),
                    subTitle: '[拖动图标放入常驻工具]'),
                _sectionContent('其他工具', KitPageManager.instance.getVisualKit(),
                    subTitle: '[拖动图标放入常驻工具]'),
                // 自定义工具
                buildBizGroupView(context),
              ],
            )));
  }

  Widget _normalStateContent(
    String title,
    Map<String, IKit> kitMap, {
    String? subTitle,
  }) {
    return kitMap.isEmpty
        ? Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Row(
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
          )
        : _contentContent(
            title,
            kitMap
                .map(
                  (key, value) => MapEntry(
                    key,
                    Draggable(
                      feedback: KitItem(value),
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
                        child: KitItem(value),
                      ),
                    ),
                  ),
                )
                .values
                .toList(),
            subTitle: subTitle,
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
    final rc2 =
        Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

    return rc1.left + rc1.width > rc2.left &&
        rc2.left + rc2.width > rc1.left &&
        rc1.top + rc1.height > rc2.top &&
        rc2.top + rc2.height > rc1.top;
  }

  Widget buildBizGroupView(BuildContext context) {
    final widgets = <Widget>[];
    final width = MediaQuery.of(context).size.width;
    var groupKeys = BizKitManager.instance.groupKeys();
    var counts = groupKeys.length;
    if (counts == 0) {
      return SizedBox();
    }
    for (var i = 0; i < counts; i++) {
      var key = groupKeys[i];
      var tip = BizKitManager.instance.kitGroupTips[key];
      widgets.add(
          Container(width: width, height: 12, color: const Color(0xfff5f6f7)));
      widgets.add(Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 10, top: 10, bottom: 15),
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: key, // 这块也是外部获取
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff333333),
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: '  ${tip ?? ''}', // 外部获取
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff333333),
                      )),
                ])),
              ),
              // 这里的数据从BizMananger中获取
              buildBizKitView(width, key)
            ],
          ),
        ),
      ));
      widgets.add(Container(width: width, height: 12, color: Colors.white));
    }
    final wrap = Wrap(children: widgets);
    return wrap;
  }

  Widget buildBizKitView(double width, String key) {
    final widgets = <Widget>[];
    final round = (width - 80 * 4 - 30) / 3;
    for (var value in BizKitManager.instance.kitGroupMap[key]!) {
      widgets.add(
        MaterialButton(
            onPressed: () {
              setState(() {
                value.tabAction();
              });
            },
            padding: EdgeInsets.zero,
            minWidth: 40,
            child: KitItem(value)),
      );
    }
    final wrap = Wrap(
      spacing: round,
      runSpacing: 15,
      children: widgets,
    );
    return wrap;
  }

  Widget _sectionContent(String title, Map<String, IKit> kitMap,
      {String? subTitle}) {
    return _contentContent(
        title,
        kitMap.values
            .toList()
            .map(
              (e) => Draggable(
                feedback: KitItem(e),
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
                  child: KitItem(e),
                ),
              ),
            )
            .toList(),
        subTitle: subTitle,
        needTopSpace: true);
  }

  Widget _contentContent(String title, List<Widget> wrapChildrens,
      {String? subTitle, bool needTopSpace = false}) {
    var titlePadding = EdgeInsets.only(top: 12, left: 20, right: 10);
    return wrapChildrens.isEmpty
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: needTopSpace ? 12 : 0,
                  color: const Color(0xfff5f6f7)),
              Padding(
                padding: needTopSpace ? titlePadding : EdgeInsets.zero,
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff333333),
                      ),
                    ),
                    if (subTitle != null)
                      Text('  $subTitle',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff333333),
                          )),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Wrap(spacing: 20, runSpacing: 10, children: wrapChildrens),
              SizedBox(height: 20)
            ],
          );
  }
}

class KitItem extends StatelessWidget {
  const KitItem(this.kit, {super.key});
  final IKit kit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Image.asset(
            kit.getIcon(),
            width: 34,
            height: 34,
            fit: BoxFit.fitWidth,
            package: dkPackageName,
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            child: Text(kit.getKitName(),
                style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: Color(0xff666666))),
          ),
        ],
      ),
    );
  }
}
