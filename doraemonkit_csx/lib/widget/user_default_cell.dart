/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 17:37:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 18:04:28
 * @Description: 
 */
import 'package:doraemonkit_csx/doraemonkit_csx.dart';
import 'package:doraemonkit_csx/utils/shared_prefer_util.dart';
import 'package:flutter/material.dart';

import '../model/userdefaults_model.dart';

class UserDefaultCellPage extends StatefulWidget {
  final UserDefaultModel userModel;
  const UserDefaultCellPage(this.userModel, {super.key});
  @override
  State<UserDefaultCellPage> createState() => _UserDefaultCellPageState();
}

class _UserDefaultCellPageState extends State<UserDefaultCellPage> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 进入下一界面编辑
      onTap: () => enterNewOverLayer((entry) => UserDefaultEditPage(
              widget.userModel.key, widget.userModel.value, (needRefresh) {
            entry?.remove();
            if (needRefresh) {
              setState(() {});
            }
          })),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.userModel.key,
          style: TextStyle(
            color: widget.userModel.isFlutter ? Colors.orange : Colors.black,
          ),
        ),
      ),
    );
  }
}

class UserDefaultEditPage extends StatefulWidget {
  final String udKey;
  final dynamic udValue;
  //返回是否需要刷新上一页面
  final Function(bool) archiveCall;
  const UserDefaultEditPage(this.udKey, this.udValue, this.archiveCall,
      {super.key});
  @override
  State<UserDefaultEditPage> createState() => _UserDefaultEditPageState();
}

class _UserDefaultEditPageState extends State<UserDefaultEditPage> {
  late String _contentStr;
  late String _udKey;
  dynamic _udValue;

  @override
  void initState() {
    super.initState();
    _udKey = widget.udKey;
    _udValue = widget.udValue;
    _contentStr = UserDefaultTransTool.transToString(_udValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('编辑UseDefault内容'),
          leading: GestureDetector(
            onTap: () => widget.archiveCall.call(false),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                dynamic saveValue = UserDefaultTransTool.transFromString(
                    _contentStr, _udValue);
                if (saveValue != null) {
                  await SPService.instance.set(_udKey, saveValue);
                  widget.archiveCall.call(_contentStr !=
                      UserDefaultTransTool.transToString(_udValue));
                } else {
                  CsxDokit.i.toastC('内容格式与原格式解析异常，开发补充');
                  widget.archiveCall.call(false);
                }
              },
              child: Text('完成'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(_udKey),
            ),
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
              ),
              child: TextFormField(
                decoration: InputDecoration(fillColor: Colors.blueGrey),
                maxLines: 900,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: _contentStr,
                    selection: TextSelection.fromPosition(
                      TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: _contentStr.length,
                      ),
                    ),
                  ),
                ),
                onChanged: (text) => _contentStr = text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
