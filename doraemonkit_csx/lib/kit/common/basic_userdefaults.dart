/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:46:00
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 14:18:38
 * @Description: 
 */
import 'package:doraemonkit_csx/channel/common/common_channel.dart';
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/model/userdefaults_model.dart';
import 'package:doraemonkit_csx/widget/user_default_cell.dart';
import 'package:flutter/material.dart';

import 'common.dart';

//SharedPreferences内部的非暴漏前缀
const String flutter_userdefaults_prefix = 'flutter.';

class BasicUserDefaultsKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_db_view;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_USERDEFAULTS;
  }

  @override
  Widget createDisplayPage() {
    return UserDefaultsPage();
  }
}

class UserDefaultsPage extends StatefulWidget {
  @override
  _UserDefaultsPageState createState() => _UserDefaultsPageState();
}

class _UserDefaultsPageState extends State<UserDefaultsPage> {
  @override
  void initState() {
    super.initState();
    _getUserDefault();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _getUserDefault().asStream(),
      initialData: [UserDefaultModel()],
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        List<UserDefaultModel> result = snapshot.data;
        return ListView.separated(
          itemCount: result.length,
          itemBuilder: (BuildContext context, int index) {
            return UserDefaultCellPage(result[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(left: 30),
              child: Divider(
                color: Colors.grey,
                height: 2,
              ),
            );
          },
        );
      },
    );
  }

  Future<List<UserDefaultModel>> _getUserDefault() async {
    var tempResult = <UserDefaultModel>[];
    var result = await DoKitCommonCsx.getUserDefaults;
    result.forEach((key, value) {
      var isFlutter = key.toString().startsWith(flutter_userdefaults_prefix);
      var tempKey = isFlutter
          ? key.toString().replaceAll(flutter_userdefaults_prefix, '')
          : key;
      tempResult.add(
          UserDefaultModel(key: tempKey, value: value, isFlutter: isFlutter));
    });
    return tempResult;
  }
}

