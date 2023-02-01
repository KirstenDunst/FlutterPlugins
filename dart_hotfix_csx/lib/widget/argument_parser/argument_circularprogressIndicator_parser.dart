/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 16:22:43
 * @Description: 
 */
import 'package:dart_hotfix_csx/ast_node.dart';
import 'package:flutter/material.dart';
import 'argument_comm_parser.dart';

Animation<Color> parseValueColor(Expression expression) {
  if (expression.isMethodInvocation &&
      expression.asMethodInvocation.callee.isIdentifier &&
      expression.asMethodInvocation.callee.asIdentifier.name ==
          'AlwaysStoppedAnimation') {
    var argumentList = expression.asMethodInvocation.argumentList;
    if (argumentList.isNotEmpty) {
      return AlwaysStoppedAnimation(parseColor(argumentList[0]));
    }
  }
  return const AlwaysStoppedAnimation(Colors.black);
}
