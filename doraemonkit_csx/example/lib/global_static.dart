/*
 * @Author: Cao Shixin
 * @Date: 2021-05-15 17:53:01
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-05-15 17:55:16
 * @Description: 
 */
import 'package:flutter/material.dart';

class GlobalStatic {
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context =>
      navigatorKey.currentState?.overlay?.context;
}
