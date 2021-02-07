import 'dart:io';

import 'package:doraemonkit_csx/common/assets.dart';
import 'package:doraemonkit_csx/dokitchannel.dart';
import 'package:doraemonkit_csx/kit/apm/vm_helper.dart';
import 'package:doraemonkit_csx/kit/common/common.dart';
import 'package:doraemonkit_csx/model/android_device_info.dart';
import 'package:doraemonkit_csx/model/ios_device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BasicInfoKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_sys_info;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASIC_INFO;
  }

  @override
  Widget createDisplayPage() {
    return BasicInfoPage();
  }
}

class BasicInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        color: Color(0xffffff),
        child: StreamBuilder(
            // initialData: Platform.isIOS ? IosDeviceInfo() : AndroidDeviceInfo(),
            stream: Platform.isIOS
                ? DoraemonkitCsx.iosInfo().asStream()
                : DoraemonkitCsx.androidInfo().asStream(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              var tempWidgets = buildAppInfo();
              tempWidgets.add(Container(
                  height: 56,
                  alignment: Alignment.centerLeft,
                  child: Text('设备信息',
                      style:
                          TextStyle(fontSize: 14, color: Color(0xff999999)))));
              if (snapshot.data != null) {
                var resultData = Platform.isIOS
                    ? (snapshot.data as IosDeviceInfo).toJson()
                    : (snapshot.data as AndroidDeviceInfo).toJson();
                resultData.forEach((key, value) {
                  tempWidgets.add(InfoItem('$key', '$value'));
                  tempWidgets
                      .add(Divider(height: 0.5, color: Color(0xffeeeeee)));
                });
              }
              return Column(
                children: tempWidgets,
              );
            }),
      ),
    );
  }

  List<Widget> buildAppInfo() {
    List<Widget> list = [];
    list.add(
      Container(
        height: 56,
        alignment: Alignment.centerLeft,
        child: Text(
          'VM信息 ' + (kReleaseMode ? '[release模式下不可用]' : ''),
          style: TextStyle(
            fontSize: 14,
            color: Color(0xff999999),
          ),
        ),
      ),
    );
    list.add(InfoItem('CPU', VmHelper.instance.vm?.hostCPU));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(InfoItem('Dart虚拟机', VmHelper.instance.vm?.version));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(InfoItem('Flutter版本', VmHelper.instance.flutterVersion));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    String isolate;
    int index = 1;
    VmHelper.instance.vm?.isolates?.forEach((element) {
      if (isolate == null) {
        isolate = '[isolate$index]: ${element.name} ${element.type}\n';
      } else {
        isolate += '[isolate$index]: ${element.name} ${element.type}\n';
      }
    });
    if (isolate != null && isolate.length > 1) {
      isolate = isolate.substring(0, isolate.length - 1);
    }
    list.add(InfoItem('Isolates', isolate));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));

    list.add(Container(
        height: 56,
        alignment: Alignment.centerLeft,
        child: Text('Package信息',
            style: TextStyle(fontSize: 14, color: Color(0xff999999)))));
    list.add(InfoItem('App包名', VmHelper.instance.packageInfo?.packageName));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(InfoItem(
        'Module版本',
        (VmHelper.instance.packageInfo == null)
            ? '-'
            : '${VmHelper.instance.packageInfo?.version}+${VmHelper.instance.packageInfo?.buildNumber}'));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    return list;
  }
}

class InfoItem extends StatelessWidget {
  final String label;
  final String text;

  InfoItem(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 14, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff333333),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                text ?? '-',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff666666),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
