/*
 * @Author: Cao Shixin
 * @Date: 2021-02-04 15:25:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 09:47:34
 * @Description: 
 */
import 'package:doraemonkit_csx/kit/kit_page.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

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
        builder: BotToastInit(),
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
