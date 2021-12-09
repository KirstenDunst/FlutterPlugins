/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 11:06:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-19 10:58:29
 * @Description: 
 */
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'common.dart';

class BasicQRKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_qr;
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
  var _contentStr = '';
  bool _showQr;
  @override
  void initState() {
    _contentStr = '';
    _showQr = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('输入想要生成的内容'),
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (text) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _contentStr = text;
                    _showQr = true;
                  });
                },
                decoration: InputDecoration(fillColor: Colors.blueGrey),
                maxLines: 900,
                onChanged: (text) {
                  _showQr = false;
                  _contentStr = text;
                },
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                RaisedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      _showQr = false;
                      _contentStr = '';
                    });
                  },
                  child: Text('清除'),
                ),
                Spacer(),
                RaisedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      _showQr = true;
                    });
                  },
                  child: Text('生成'),
                ),
                SizedBox(
                  width: 15,
                ),
              ],
            ),
            if (_contentStr != null && _contentStr.isNotEmpty && _showQr)
              QrImage(
                data: _contentStr,
                version: QrVersions.auto,
                size: 200.0,
              ),
          ],
        ),
      ),
    );
  }
}
