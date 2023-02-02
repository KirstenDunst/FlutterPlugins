/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 15:58:23
 * @Description: 
 */
import 'package:dart_hotfix_csx/node/ast_node.dart';
import 'package:flutter/material.dart';

abstract class BaseWidgetBuilder {
  Widget build(Expression widgetExpression, {Map? variables}) =>
      SizedBox.fromSize(
        size: const Size.square(0),
      );

  String get widgetName => "";
}
