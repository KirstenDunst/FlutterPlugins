import 'dart:async';

import 'package:dart_hotfix_csx/ast_node.dart';
import 'package:flutter/material.dart';
import 'widget_builders/widget_builders.dart';

class AstStatefulWidget extends StatefulWidget {
  final Map ast;

  const AstStatefulWidget(this.ast, {super.key});

  @override
  State<AstStatefulWidget> createState() => _AstStatefulWidgetState();
}

class _AstStatefulWidgetState extends State<AstStatefulWidget> {
  Widget? _bodyWidget;

  Future _parseRootAst(Map rootAst) async {
    var rootExpression = Expression.fromAst(rootAst);
    if (rootExpression.isProgram) {
      var bodyList = rootExpression.asProgram.body;

      if (bodyList.length == 2) {
        var stateClass = bodyList[1].asClassDeclaration;
        if (stateClass.superClause == 'State') {
          var stateBodyList = stateClass.body;
          for (var bodyNode in stateBodyList) {
            if (bodyNode.isMethodDeclaration) {
              switch (bodyNode.asMethodDeclaration.name) {
                case 'build':
                  var buildBodyReturn = bodyNode.asMethodDeclaration.body.body;
                  if (buildBodyReturn.isNotEmpty &&
                      buildBodyReturn[0].isReturnStatement) {
                    setState(() {
                      _bodyWidget =
                          FHWidgetBuilderFactory.buildWidgetWithExpression(
                              buildBodyReturn[0].asReturnStatement.argument);
                    });
                  }
                  break;
                case 'initState':
                  break;
                case 'didUpdateWidget':
                  break;
                case 'dispose':
                  break;
              }
            } else if (bodyNode.isFieldDeclaration) {
              //TODO state field declaration
            }
          }
        }
      }
    }
    return Future.value();
  }

  @override
  void initState() {
    super.initState();
    _parseRootAst(widget.ast);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: _bodyWidget ??
          Center(
            child: SizedBox.fromSize(
                size: const Size.square(30),
                child: const CircularProgressIndicator()),
          ),
    );
  }
}
