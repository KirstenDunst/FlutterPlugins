/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-02-01 16:12:06
 * @Description: 
 */
import 'package:dart_hotfix_csx/ast_node.dart';
import 'package:flutter/material.dart';
import 'recommand_builder_box.dart';
import 'basebuilder_box.dart';

class FHWidgetBuilderFactory {
  static final List<BaseBuilderBox> _builderBox = [RecommandBuilderBox()];

  ///设置自定义扩展Widget 构建器
  static void setExtendBuilderBox(BaseBuilderBox builderBox) {
    if (_builderBox.length == 2) {
      _builderBox.removeLast();
    }
    _builderBox.add(builderBox);
  }

  static Widget buildWidget(Map widgetAst, {Map? variables}) {
    return buildWidgetWithExpression(Expression.fromAst(widgetAst),
        variables: variables);
  }

  static Widget buildWidgetWithExpression(Expression widgetExpression,
      {Map? variables}) {
    //从builder box 中查找匹配的widget builder， 优先顺序 ExtendBuilderBox > RecommandBuilderBox
    for (var i = _builderBox.length; i > 0; i--) {
      var w = _builderBox[i - 1].build(widgetExpression, variables: variables);
      if (w != const SizedBox()) {
        return w;
      }
    }
    return Container();
  }
}
