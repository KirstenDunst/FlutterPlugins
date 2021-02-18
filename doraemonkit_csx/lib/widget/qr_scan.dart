/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 16:54:34
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:09:04
 * @Description: 
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRController extends StatefulWidget {
  @override
  _QRControllerState createState() => _QRControllerState();
}

class _QRControllerState extends State<QRController> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController _qrController;
  bool _isOver;

  @override
  void reassemble() {
    super.reassemble();
    print('触发。。。。。');
    if (Platform.isAndroid) {
      _qrController.pauseCamera();
    } else if (Platform.isIOS) {
      _qrController.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    _isOver = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫描界面'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isOver) {
        _isOver = true;
        Navigator.of(context, rootNavigator: true).pop(scanData.code);
      }
    });
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }
}
