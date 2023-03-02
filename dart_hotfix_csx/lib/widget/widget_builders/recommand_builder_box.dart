/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 16:09:46
 * @Description: 
 */
import 'package:dart_hotfix_csx/node/ast_node.dart';
import 'package:flutter/material.dart';
import 'basewidget_builder.dart';
import 'basebuilder_box.dart';
import 'components_builders.dart';
import 'layout_builders.dart';

class RecommandBuilderBox implements BaseBuilderBox {
  final List<BaseWidgetBuilder> _widgetBuilders = [
    TextWidgetBuilder(),
    CircularProgressIndicatorBuilder(),
    IconBuilder(),
    ImageBuilder(),
    AppBarBuilder(),
    ContainerBuilder(),
    ScaffoldBuilder(),
    DividerBuilder(),
    ListViewBuilder(),
    RowBuilder(),
    ColumnBuilder(),
  ];

  @override
  Widget build(Expression widgetExpression, {Map? variables}) {
    if (widgetExpression.isMethodInvocation) {
      var callee = widgetExpression.asMethodInvocation.callee;
      if (callee.isIdentifier) {
        for (var builder in _widgetBuilders) {
          if (builder.widgetName == callee.asIdentifier.name) {
            return builder.build(widgetExpression, variables: variables);
          }
        }
      } else if (callee.isMemberExpression) {
        for (var builder in _widgetBuilders) {
          if (builder.widgetName ==
              callee.asMemberExpression.object.asIdentifier.name) {
            return builder.build(widgetExpression, variables: variables);
          }
        }
      }
    }
    return const SizedBox();
  }
}
