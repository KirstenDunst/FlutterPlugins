/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:44:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:10:38
 * @Description: 
 */
import 'dart:async';

import 'package:doraemonkit_csx/utils/regular_ext.dart';
import 'package:flutter/material.dart';
import '../csx_dokit.dart';
import '../vm/web_vm.dart';
import '../widget/qr_scan.dart';
import '../widget/web_cell.dart';
import 'common.dart';

class BasicH5Kit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_web_door.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseH5;
  }

  @override
  Widget createDisplayPage() {
    return WebPage();
  }
}

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  GlobalKey<EditViewState> editKey = GlobalKey();
  late String _contentStr;
  final _streamController = StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    _contentStr = '';
  }

  @override
  Widget build(BuildContext context) {
    _streamController.addStream(WebVM.getLocalWebSearchList().asStream());
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Column(
        children: [
          Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: EditView(
                      key: editKey,
                      valueChanged: (text) {
                        _contentStr = text;
                      },
                      skipBtnCall: _onTapSkipBtn,
                    ),
                  ),
                  InkWell(
                    onTap: _onTapSkipBtn,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.arrow_circle_right_outlined,
                        size: 40,
                        color: Colors.cyan,
                        semanticLabel: '点击跳转',
                      )),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: InkWell(
                  onTap: () {
                    //扫描
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QRController()),
                    ).then((result) {
                      if (result != null) {
                        _contentStr = result.toString();
                        editKey.currentState?.changeValue(_contentStr);
                      }
                    });
                  },
                  child: Image.asset(
                    'assets/images/dk_web_door_history_qrcode.png',
                    width: 30,
                    height: 30,
                    package: dkPackageName,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: _streamController.stream,
              initialData: <String>[],
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                List<String> result = snapshot.data ?? [];
                return ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return index < result.length
                        ? WebCell(result[index])
                        : WebCellFooter(
                            canTap: (result.isNotEmpty),
                            callback: () {
                              _streamController.addStream(
                                WebVM.getLocalWebSearchList().asStream(),
                              );
                            },
                          );
                  },
                  itemCount: result.length + 1,
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Divider(color: Colors.grey, height: 2),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future _onTapSkipBtn() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_contentStr.isEmpty) {
      CsxDokit.i.toast?.call('Url地址内容不能为空');
    } else if (!_contentStr.isWeb()) {
      CsxDokit.i.toast?.call('web地址格式不正确');
    } else {
      await WebVM.addSearchList(_contentStr);
      _streamController.addStream(WebVM.getLocalWebSearchList().asStream());
      if (mounted) {
        EnterWebTool.enterWeb(context, _contentStr);
      }
    }
  }
}
