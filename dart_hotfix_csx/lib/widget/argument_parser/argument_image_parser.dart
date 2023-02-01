/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 16:24:10
 * @Description: 
 */
import 'package:dart_hotfix_csx/ast_node.dart';
import 'package:flutter/material.dart';

BoxFit parseBoxFit(Expression expression) {
  if (expression.isPrefixedIdentifier) {
    switch (expression.asPrefixedIdentifier.identifier) {
      case 'fill':
        return BoxFit.fill;
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'scaleDown':
        return BoxFit.scaleDown;
      case 'none':
        return BoxFit.none;
    }
  }

  return BoxFit.none;
}
