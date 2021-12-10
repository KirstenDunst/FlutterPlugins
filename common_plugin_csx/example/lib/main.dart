/*
 * @Author: Cao Shixin
 * @Date: 2021-12-10 09:13:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-12-10 10:54:03
 * @Description: 
 */
import 'package:common_plugin_csx/common_plugin_csx.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final ImagePicker _picker = ImagePicker();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: InkWell(
          child: const Icon(
            Icons.photo_album,
            size: 50,
          ),
          onTap: () async {
            var pickedFile = await _picker.getImage(
              source: ImageSource.gallery,
            );
            if (pickedFile != null) {
              var md5Str = await CommonPluginCsx.getFileMd5(pickedFile.path);
              setState(() {
                _platformVersion = md5Str ?? '';
              });
            }
          },
        ),
      ),
    );
  }
}
