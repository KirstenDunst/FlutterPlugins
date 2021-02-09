/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 11:06:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 11:27:19
 * @Description: 
 */
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class BasicQRKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_web_door_history_qrcode;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_QR;
  }

  @override
  Widget createDisplayPage() {
    return QRPage();
  }
}

class QRPage extends StatefulWidget {
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
