/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:46:00
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 17:36:01
 * @Description: 
 */
import 'package:flutter/material.dart';

import '../channel/common/common_channel.dart';
import '../dokit.dart';
import '../model/userdefaults_model.dart';
import '../widget/user_default_cell.dart';
import 'common.dart';

//SharedPreferences内部的非暴漏前缀
const String flutterUserdefaultsPrefix = 'flutter.';

class BasicUserDefaultsKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_db_view.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseUserDefaults;
  }

  @override
  Widget createDisplayPage() {
    return UserDefaultsPage();
  }
}

class UserDefaultsPage extends StatefulWidget {
  const UserDefaultsPage({super.key});

  @override
  State<UserDefaultsPage> createState() => _UserDefaultsPageState();
}

class _UserDefaultsPageState extends State<UserDefaultsPage> {
  late bool _onlyFlutter;
  @override
  void initState() {
    super.initState();
    _onlyFlutter = true;
    _getUserDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _onlyFlutter = !_onlyFlutter;
            });
          },
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                padding: EdgeInsets.only(left: 16),
                child: Image.asset(
                  _onlyFlutter
                      ? 'assets/images/dk_channel_check_h.png'
                      : 'assets/images/dk_channel_check_n.png',
                  height: 13,
                  width: 13,
                  package: dkPackageName,
                ),
              ),
              Text(
                '只显示Flutter',
                style: TextStyle(
                  color: _onlyFlutter ? Color(0xff337cc4) : Color(0xff333333),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _getUserDefault().asStream(),
            initialData: [UserDefaultModel()],
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              List<UserDefaultModel>? result = snapshot.data;
              return ListView.separated(
                itemCount: result?.length ?? 0,
                itemBuilder: (BuildContext context, int index) =>
                    UserDefaultCellPage(result![index]),
                separatorBuilder: (BuildContext context, int index) => Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Divider(color: Colors.grey, height: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<UserDefaultModel>> _getUserDefault() async {
    var tempResult = <UserDefaultModel>[];
    var result = await DoraemonkitCsx.getUserDefaults();
    result.forEach((key, value) {
      var isFlutter = key.toString().startsWith(flutterUserdefaultsPrefix);
      var tempKey = isFlutter
          ? key.toString().replaceAll(flutterUserdefaultsPrefix, '')
          : key;
      if ((_onlyFlutter && isFlutter) || !_onlyFlutter) {
        tempResult.add(
          UserDefaultModel(key: tempKey, value: value, isFlutter: isFlutter),
        );
      }
    });
    return tempResult;
  }
}
