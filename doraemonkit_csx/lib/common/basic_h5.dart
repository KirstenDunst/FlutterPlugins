/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:44:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:10:38
 * @Description: 
 */
import 'dart:async';

import 'package:doraemonkit_csx/csx_kit.dart';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:doraemonkit_csx/utils/regular_ext.dart';
import 'package:flutter/material.dart';
import '../page/kits_page.dart';
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
  void tabAction() {
    CommonPageInsertTool.overlayInsert('', createDisplayPage());
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
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(CommonKitName.kitBaseH5),
          actions: [_enterWebDetail()],
        ),
        body: Column(
          children: [
            Stack(
              children: [
                EditView(
                  key: editKey,
                  valueChanged: (text) {
                    _contentStr = text;
                  },
                  skipBtnCall: _onTapSkipBtn,
                ),
                Positioned(
                  right: 25,
                  bottom: 15,
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
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
      ),
    );
  }

  Widget _enterWebDetail() {
    return InkWell(
      onTap: _onTapSkipBtn,
      child: Container(
        padding: EdgeInsets.only(right: 15),
        alignment: Alignment.center,
        height: 45,
        child: Text('点击跳转', style: TextStyle(fontSize: 15)),
      ),
    );
  }

  Future _onTapSkipBtn() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_contentStr.isEmpty) {
      CsxKitShare.instance.toast('内容不能为空');
    } else if (!_contentStr.isWeb()) {
      CsxKitShare.instance.toast('web地址格式不正确');
    } else {
      await WebVM.addSearchList(_contentStr);
      _streamController.addStream(WebVM.getLocalWebSearchList().asStream());
      if (mounted) {
        EnterWebTool.enterWeb(context, _contentStr);
      }
    }
  }
}
