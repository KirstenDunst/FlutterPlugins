/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 16:54:34
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:09:04
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRController extends StatefulWidget {
  final OverlayEntry? entry;
  final Function(String)? detectBack;
  const QRController({super.key, this.entry, this.detectBack});

  @override
  State<QRController> createState() => _QRControllerState();
}

class _QRControllerState extends State<QRController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫描界面'),
        leading: GestureDetector(
          onTap: () => widget.entry?.remove(),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
      ),
      body: MobileScanner(onDetect: (barcodeCap) {
        var barcodes = barcodeCap.barcodes.where((e) => e.rawValue != null);
        var barcodeValue = barcodes.isEmpty ? null : barcodes.first.rawValue!;
        if (mounted && barcodeValue != null) {
          widget.detectBack?.call(barcodeValue);
          widget.entry?.remove();
        }
      }),
    );
  }
}
