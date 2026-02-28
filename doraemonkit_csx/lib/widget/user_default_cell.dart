/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 17:37:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 18:04:28
 * @Description: 
 */
import 'package:doraemonkit_csx/page/kits_page.dart';
import 'package:flutter/material.dart';

import '../channel/common/common_channel.dart';
import '../common/basic_userdefaults.dart';
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
      onTap: () =>
          // 进入下一界面编辑
          CommonPageInsertTool.overlayInsert(
            '编辑本地存储',
            UserDefaultEditPage(widget.userModel),
          ),
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
  final UserDefaultModel userModel;
  const UserDefaultEditPage(this.userModel, {super.key});
  @override
  State<UserDefaultEditPage> createState() => _UserDefaultEditPageState();
}

class _UserDefaultEditPageState extends State<UserDefaultEditPage> {
  late String _contentStr;

  @override
  void initState() {
    super.initState();
    _contentStr = widget.userModel.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Edit'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                widget.userModel.value = _contentStr;
                DoraemonkitCsx.setUserDefault({
                  ((widget.userModel.isFlutter
                              ? flutterUserdefaultsPrefix
                              : '') +
                          widget.userModel.key):
                      _contentStr,
                });
                Navigator.of(context, rootNavigator: true).pop(_contentStr);
              },
              child: Text('完成'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(widget.userModel.key),
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
                onChanged: (text) {
                  _contentStr = text;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
