import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vm_service/vm_service.dart';

import '../apm/vm_helper.dart';
import 'common.dart';

class BasicInfoKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_sys_info.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseInfo;
  }

  @override
  Widget createDisplayPage() {
    return BasicInfoPage();
  }
}

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var androidDeviceInfo = await deviceInfo.androidInfo;
        deviceData = androidDeviceInfo.data;
        if (kDebugMode) {
          print(deviceData);
        }
      } else if (Platform.isIOS) {
        deviceData = (await deviceInfo.iosInfo).data;
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.',
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        color: Color(0x00ffffff),
        child: Column(children: buildAppInfo()),
      ),
    );
  }

  List<Widget> buildAppInfo() {
    var list = <Widget>[];
    list.add(
      Container(
        height: 56,
        alignment: Alignment.centerLeft,
        child: Text(
          'VM信息 ${!kReleaseMode ? '' : '[release模式下不可用]'}',
          style: TextStyle(fontSize: 14, color: Color(0xff999999)),
        ),
      ),
    );
    list.add(InfoItem('CPU', VmHelper.instance.vm?.hostCPU));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(InfoItem('Dart虚拟机', VmHelper.instance.vm?.version));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(InfoItem('Flutter版本', VmHelper.instance.flutterVersion));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(IsolateItem());
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));

    list.add(
      Container(
        height: 56,
        alignment: Alignment.centerLeft,
        child: Text(
          'Package信息',
          style: TextStyle(fontSize: 14, color: Color(0xff999999)),
        ),
      ),
    );
    list.add(InfoItem('App包名', VmHelper.instance.packageInfo?.packageName));
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(
      InfoItem(
        'Module版本',
        (VmHelper.instance.packageInfo == null)
            ? '-'
            : '${VmHelper.instance.packageInfo?.version}+${VmHelper.instance.packageInfo?.buildNumber}',
      ),
    );
    list.add(Divider(height: 0.5, color: Color(0xffeeeeee)));
    list.add(
      Row(
        children: [
          Text('----自定义包信息获取,后续可以融合一下'),
          ElevatedButton.icon(
            onPressed: () => initPlatformState(),
            label: Icon(Icons.refresh),
          ),
        ],
      ),
    );
    list.addAll(
      _deviceData.keys.map((String property) {
        return Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                property,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(
                  '${_deviceData[property]}',
                  maxLines: 1000,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
    return list;
  }
}

class IsolateItem extends StatefulWidget {
  const IsolateItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IsolateItemState();
  }
}

class _IsolateItemState extends State<IsolateItem> {
  VM? vm;

  @override
  void initState() {
    super.initState();
    VmHelper.instance.startConnect().then(
      (value) => setState(() {
        vm = VmHelper.instance.vm;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? isolate;
    var index = 1;
    vm?.isolates?.forEach((element) {
      if (isolate == null) {
        isolate = '[isolate$index]: ${element.name} ${element.type}\n';
      } else {
        isolate =
            '${isolate!}[isolate$index]: ${element.name} ${element.type}\n';
      }
      index++;
    });
    if (isolate != null && (isolate?.length ?? 0) > 1) {
      isolate = isolate!.substring(0, isolate!.length - 1);
    }
    isolate ??= '-';
    return InfoItem('Isolates', isolate);
  }
}

class InfoItem extends StatelessWidget {
  final String label;
  final String? text;

  const InfoItem(this.label, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 14, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 16, color: Color(0xff333333))),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                text ?? '-',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 16, color: Color(0xff666666)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
