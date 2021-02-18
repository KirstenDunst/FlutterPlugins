/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 11:48:49
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 16:12:42
 * @Description: 
 */
import 'package:doraemonkit_csx/dokit.dart';
import 'package:doraemonkit_csx/model/dokit_model.dart';
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/vm/web_vm.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebCell extends StatefulWidget {
  final String url;
  WebCell(this.url);
  @override
  _WebCellState createState() => _WebCellState();
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
              Images.dk_memory_search,
              width: 20,
              height: 20,
              package: DoKit.PACKAGE_NAME,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              widget.url ?? '',
              maxLines: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class WebCellFooter extends StatefulWidget {
  final bool canTap;
  final VoidCallback callback;
  WebCellFooter({this.canTap = false, this.callback});
  @override
  _WebCellFooterState createState() => _WebCellFooterState();
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
            if (widget.callback != null) {
              widget.callback();
            }
          }
        },
        child: Text(widget.canTap ? '清除搜索历史' : '暂无搜索历史'),
      ),
    );
  }
}

typedef ValueChanged = Function(String value);

class EditView extends StatefulWidget {
  final ValueChanged valueChanged;
  final VoidCallback skipBtnCall;
  EditView({Key key, this.valueChanged, this.skipBtnCall}) : super(key: key);
  @override
  EditViewState createState() => EditViewState();
}

class EditViewState extends State<EditView> {
  String _contentStr;

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
    return Container(
      height: 150,
      child: TextFormField(
        decoration: InputDecoration(fillColor: Colors.blueGrey),
        maxLines: 900,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (text) {
          FocusScope.of(context).requestFocus(FocusNode());
          _textChange(text);
          if (widget.skipBtnCall != null) {
            widget.skipBtnCall();
          }
        },
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: _contentStr ?? '',
            selection: TextSelection.fromPosition(
              TextPosition(
                  affinity: TextAffinity.downstream,
                  offset: _contentStr.isEmpty ? 0 : _contentStr.length),
            ),
          ),
        ),
        onChanged: _textChange,
      ),
    );
  }

  void _textChange(String text) {
    _contentStr = text;
    if (widget.valueChanged != null) {
      widget.valueChanged(_contentStr);
    }
  }
}

class EnterWebTool {
  static void enterWeb(BuildContext context, String url) {
    if (DoKit.doCustomCallMap != null &&
        DoKit.doCustomCallMap.containsKey(DokitCallType.BASE_WEB)) {
      CustomCallback callback = DoKit.doCustomCallMap[DokitCallType.BASE_WEB];
      if (callback != null) {
        callback(context, url);
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('内部浏览器'),
          ),
          body: WebView(
            initialUrl: url,
          ),
        ),
      ),
    );
  }
}
