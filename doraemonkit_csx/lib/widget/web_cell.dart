/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 11:48:49
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 16:12:42
 * @Description: 
 */
import 'package:doraemonkit_csx/page/kits_page.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../csx_kit.dart';
import '../dokit.dart';
import '../model/dokit_model.dart';
import '../vm/web_vm.dart';

class WebCell extends StatefulWidget {
  final String url;
  const WebCell(this.url, {super.key});
  @override
  State<WebCell> createState() => _WebCellState();
}

class _WebCellState extends State<WebCell> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        EnterWebTool.enterWeb(context, widget.url);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Image.asset(
              'assets/images/dk_memory_search.png',
              width: 20,
              height: 20,
              package: dkPackageName,
            ),
            SizedBox(width: 10),
            Text(widget.url, maxLines: 100),
          ],
        ),
      ),
    );
  }
}

class WebCellFooter extends StatefulWidget {
  final bool canTap;
  final VoidCallback? callback;
  const WebCellFooter({super.key, this.canTap = false, this.callback});
  @override
  State<WebCellFooter> createState() => _WebCellFooterState();
}

class _WebCellFooterState extends State<WebCellFooter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () async {
          if (widget.canTap) {
            await WebVM.delectSearchList();
            widget.callback?.call();
          }
        },
        child: Text(widget.canTap ? '清除搜索历史' : '暂无搜索历史'),
      ),
    );
  }
}

typedef ValueChanged = Function(String value);

class EditView extends StatefulWidget {
  final ValueChanged? valueChanged;
  final VoidCallback? skipBtnCall;
  const EditView({super.key, this.valueChanged, this.skipBtnCall});
  @override
  EditViewState createState() => EditViewState();
}

class EditViewState extends State<EditView> {
  late String _contentStr;

  @override
  void initState() {
    _contentStr = '';
    super.initState();
  }

  void changeValue(String content) {
    setState(() {
      _contentStr = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TextFormField(
        decoration: InputDecoration(fillColor: Colors.blueGrey),
        maxLines: 900,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (text) {
          FocusScope.of(context).requestFocus(FocusNode());
          _textChange(text);
          widget.skipBtnCall?.call();
        },
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: _contentStr,
            selection: TextSelection.fromPosition(
              TextPosition(
                affinity: TextAffinity.downstream,
                offset: _contentStr.isEmpty ? 0 : _contentStr.length,
              ),
            ),
          ),
        ),
        onChanged: _textChange,
      ),
    );
  }

  void _textChange(String text) {
    _contentStr = text;
    widget.valueChanged?.call(_contentStr);
  }
}

class EnterWebTool {
  static void enterWeb(BuildContext context, String url) {
    var callback = CsxKitShare.instance.doCustomCallMap?[DokitCallType.baseWeb];
    if (callback != null) {
      callback(context, url);
      return;
    }
    var webViewController = WebViewController();
    webViewController.loadRequest(Uri.parse(url));
    CommonPageInsertTool.overlayInsert(
      '内部浏览器',
      WebViewWidget(controller: webViewController),
    );
  }
}
