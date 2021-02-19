/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 17:37:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 18:04:28
 * @Description: 
 */
import 'package:doraemonkit_csx/channel/common/common_channel.dart';
import 'package:doraemonkit_csx/kit/common/basic_userdefaults.dart';
import 'package:doraemonkit_csx/model/userdefaults_model.dart';
import 'package:flutter/material.dart';

class UserDefaultCellPage extends StatefulWidget {
  final UserDefaultModel userModel;
  UserDefaultCellPage(this.userModel);
  @override
  _UserDefaultCellPageState createState() => _UserDefaultCellPageState();
}

class _UserDefaultCellPageState extends State<UserDefaultCellPage> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 进入下一界面编辑
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return UserDefaultEditPage(widget.userModel);
        })).then((value) {
          if (value != null) {
            widget.userModel.value = value;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.userModel.key,
          style: TextStyle(
              color: widget.userModel.isFlutter ? Colors.orange : Colors.black),
        ),
      ),
    );
  }
}

class UserDefaultEditPage extends StatefulWidget {
  final UserDefaultModel userModel;
  UserDefaultEditPage(this.userModel);
  @override
  _UserDefaultEditPageState createState() => _UserDefaultEditPageState();
}

class _UserDefaultEditPageState extends State<UserDefaultEditPage> {
  var _contentStr;

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
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Edit'),
          actions: [
            RaisedButton(
              color: Colors.transparent,
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                widget.userModel.value = _contentStr;
                DoKitCommonCsx.setUserDefault({
                  ('${widget.userModel.isFlutter ? flutter_userdefaults_prefix : ''}' +
                      widget.userModel.key): _contentStr
                });
                Navigator.of(context, rootNavigator: true).pop(_contentStr);
              },
              child: Text('完成'),
            )
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
                border: Border.all(
                  color: Colors.blueGrey,
                ),
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
                          offset: _contentStr.length),
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
