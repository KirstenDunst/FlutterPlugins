/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 16:01:16
 * @Description: 
 */
import 'package:dart_hotfix_csx/node/ast_node.dart';
import 'package:flutter/material.dart';

IconData? parseIconData(Expression expression) {
  if (expression.isPrefixedIdentifier) {
    switch (expression.asPrefixedIdentifier.identifier) {
      case 'face':
        return Icons.face;
    }
  }
  return null;
}
