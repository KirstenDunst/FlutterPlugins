/*
 * @Author: Cao Shixin
 * @Date: 2021-01-05 15:53:20
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 16:10:53
 * @Description: 
 */
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('后台保活'),
        ),
      ),
    );
  }
}
