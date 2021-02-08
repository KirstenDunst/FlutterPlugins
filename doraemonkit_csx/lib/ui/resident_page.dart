/*
 * @Author: Cao Shixin
 * @Date: 2021-02-04 15:25:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-08 16:43:48
 * @Description: 
 */
import 'package:doraemonkit_csx/kit/kit_page.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class ResidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ResidentPageState();
  }
}

class ResidentPageState extends State<ResidentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: 'DoKit',
        home: Scaffold(
          appBar: AppBar(
            title: Text('DoKit'),
          ),
          body: KitPage(),
        ),
      ),
    );
  }
}
