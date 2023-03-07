import 'dart:io';
import 'dart:convert';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:args/args.dart';
import 'ast_runtime_class.dart';
// ignore: depend_on_referenced_packages
import 'package:pub_semver/pub_semver.dart';

main(List<String> arguments) async {
  final parser = ArgParser()..addFlag("file", negatable: false, abbr: 'f');
  stdout.writeln('arguments: $arguments');
  var argResults = parser.parse(arguments);
  final paths = argResults.rest;
  stdout.writeln('paths: $paths');
  if (paths.isEmpty) {
    stdout.writeln('No file found');
  } else {
    var ast = await astGenerate(paths.first);
    //测试Runtime
    var astRuntime = AstRuntime(ast);
    var res = await astRuntime.callFunction('incTen', [100]);
    stdout.writeln('Invoke incTec(100) result: $res');
  }
}

class DemoAstVisitor extends GeneralizingAstVisitor<Map> {
  @override
  Map visitNode(AstNode node) {
    //输出遍历AST Node 节点内容
    stdout.writeln("${node.runtimeType}<---->${node.toSource()}");
    return super.visitNode(node) ?? {};
  }
}

class MyAstVisitor extends SimpleAstVisitor<Map> {
  /// 遍历节点
  Map? _safelyVisitNode(AstNode? node) {
    stdout.writeln('_safelyVisitNode: $node');
    return node?.accept(this);
  }

  /// 遍历节点列表
  List<Map> _safelyVisitNodeList(NodeList<AstNode>? nodes) {
    var maps = <Map>[];
    if (nodes != null) {
      int size = nodes.length;
      for (int i = 0; i < size; i++) {
        var node = nodes[i];
        stdout.writeln('_safelyVisitNodeList: $i $node');
        var res = node.accept(this);
        if (res != null) {
          maps.add(res);
        }
      }
    }
    return maps;
  }

  @override
  Map visitCompilationUnit(CompilationUnit node) {
    //构造根节点
    stdout.writeln('visitCompilationUnit: ${node.declarations}');
    return {
      "type": "Program",
      "body": _safelyVisitNodeList(node.declarations),
    };
  }

  @override
  Map visitBlock(Block node) {
    //构造代码块Bloc 结构
    stdout.writeln('visitBlock: ${node.statements}');
    return {
      "type": "BlockStatement",
      "body": _safelyVisitNodeList(node.statements)
    };
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    stdout.writeln('visitBlockFunctionBody: ${node.block}');
    return _safelyVisitNode(node.block);
  }

  @override
  Map visitVariableDeclaration(VariableDeclaration node) {
    stdout.writeln('visitVariableDeclaration: $node>>>>>${node.initializer}');
    return {
      "type": "VariableDeclarator",
      "id": _safelyVisitNode(node.name),
      "init": _safelyVisitNode(node.initializer),
    };
  }

  @override
  Map? visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    stdout.writeln('visitVariableDeclarationStatement: ${node.variables}');
    return _safelyVisitNode(node.variables);
  }

  @override
  Map visitVariableDeclarationList(VariableDeclarationList node) {
    //构造变量声明
    stdout.writeln(
        'visitVariableDeclarationList: ${node.type}>>>>>${node.variables}');
    return {
      "type": "VariableDeclarationList",
      "typeAnnotation": _safelyVisitNode(node.type),
      "declarations": _safelyVisitNodeList(node.variables),
    };
  }

  @override
  Map visitSimpleIdentifier(SimpleIdentifier node) {
    stdout.writeln('visitSimpleIdentifier: ${node.name}');
    //构造标识符定义
    return {"type": "Identifier", "name": node.name};
  }

  @override
  Map visitBinaryExpression(BinaryExpression node) {
    //构造运算表达式结构
    stdout.writeln(
        'visitBinaryExpression: ${node.leftOperand}>>>${node.rightOperand}>>>${node.operator.lexeme}');
    return {
      "type": "BinaryExpression",
      "operator": node.operator.lexeme,
      "left": _safelyVisitNode(node.leftOperand),
      "right": _safelyVisitNode(node.rightOperand)
    };
  }

  @override
  Map visitIntegerLiteral(IntegerLiteral node) {
    //构造数值定义
    stdout.writeln('visitIntegerLiteral: ${node.value}');
    return {"type": "NumericLiteral", "value": node.value};
  }

  @override
  Map visitFunctionDeclaration(FunctionDeclaration node) {
    //构造函数声明
    stdout.writeln(
        'visitFunctionDeclaration: $node >>> ${node.functionExpression}');
    return {
      "type": "FunctionDeclaration",
      "id": _safelyVisitNode(node.name),
      "expression": _safelyVisitNode(node.functionExpression),
    };
  }

  @override
  Map? visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    stdout.writeln(
        'visitFunctionDeclarationStatement: ${node.functionDeclaration}');
    return _safelyVisitNode(node.functionDeclaration);
  }

  @override
  Map visitFunctionExpression(FunctionExpression node) {
    //构造函数表达式
    stdout.writeln(
        'visitFunctionExpression: ${node.parameters}>>>${node.body}>>>>${node.body.isAsynchronous}');
    return {
      "type": "FunctionExpression",
      "parameters": _safelyVisitNode(node.parameters),
      "body": _safelyVisitNode(node.body),
      "isAsync": node.body.isAsynchronous,
    };
  }

  @override
  Map visitSimpleFormalParameter(SimpleFormalParameter node) {
    //构造函数参数
    stdout.writeln(
        'visitSimpleFormalParameter: ${node.type}>>>${node.identifier?.name}');
    return {
      "type": "SimpleFormalParameter",
      "paramType": _safelyVisitNode(node.type),
      "name": node.identifier?.name,
    };
  }

  @override
  Map visitFormalParameterList(FormalParameterList node) {
    //构造函数参数
    stdout.writeln('visitFormalParameterList: ${node.parameterElements}');
    var tempArr = _safelyVisitNodeList(node.parameters);
    stdout.writeln('visitFormalParameterList: end: $tempArr');
    return {
      "type": "FormalParameterList",
      "parameterList": _safelyVisitNodeList(node.parameters)
    };
  }

  @override
  Map visitNamedType(NamedType node) {
    //构造函数参数类型
    stdout.writeln('visitNamedType: ${node.name}');
    return {
      "type": "TypeName",
      "name": _safelyVisitNode(node.name),
    };
  }

  @override
  Map visitReturnStatement(ReturnStatement node) {
    //构造返回数据定义
    stdout.writeln('visitReturnStatement: ${node.expression}');
    return {
      "type": "ReturnStatement",
      "argument": _safelyVisitNode(node.expression),
    };
  }

  @override
  Map visitMethodDeclaration(MethodDeclaration node) {
    stdout.writeln(
        'visitMethodDeclaration: $node>>>${node.parameters}>>>${node.typeParameters}>>>${node.body}>>>${node.returnType}');
    return {
      "type": "MethodDeclaration",
      "id": _safelyVisitNode(node.name),
      "parameters": _safelyVisitNode(node.parameters),
      "typeParameters": _safelyVisitNode(node.typeParameters),
      "body": _safelyVisitNode(node.body),
      "returnType": _safelyVisitNode(node.returnType),
      "isAsync": node.body.isAsynchronous,
    };
  }

  @override
  Map visitNamedExpression(NamedExpression node) {
    stdout.writeln('visitNamedExpression: ${node.name}>>>>${node.expression}');
    var tempDic = _safelyVisitNode(node.name);
    var expressionDic = _safelyVisitNode(node.expression);
    if (tempDic?['name'] == 'title') {
      stdout.writeln('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
      stdout.writeln('${node.expression}');
      stdout.writeln('$expressionDic');
      stdout.writeln('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    }
    return {
      "type": "NamedExpression",
      "expression": expressionDic,
      "id": tempDic,
    };
  }

  @override
  Map visitPrefixedIdentifier(PrefixedIdentifier node) {
    stdout.writeln(
        'visitPrefixedIdentifier: ${node.identifier}>>>>${node.prefix}');
    return {
      "type": "PrefixedIdentifier",
      "prefix": _safelyVisitNode(node.prefix),
      "identifier": _safelyVisitNode(node.identifier),
    };
  }

  @override
  Map visitMethodInvocation(MethodInvocation node) {
    stdout.writeln('visitMethodInvocation: $node');
    return {
      "type": "MethodInvocation",
      "typeArguments": _safelyVisitNode(node.typeArguments),
      "callee": node.target != null
          ? {
              "type": "MemberExpression",
              "object": _safelyVisitNode(node.target),
              "property": _safelyVisitNode(node.methodName),
            }
          : _safelyVisitNode(node.methodName),
      "argumentList": _safelyVisitNode(node.argumentList),
    };
  }

  @override
  Map visitClassDeclaration(ClassDeclaration node) {
    stdout.writeln('visitClassDeclaration: ${node.name}>>>${node.members}');
    return {
      "type": "ClassDeclaration",
      "id": _safelyVisitNode(node.name),
      "superClause": _safelyVisitNode(node.extendsClause),
      "implementsClause": _safelyVisitNode(node.implementsClause),
      "mixinClause": _safelyVisitNode(node.withClause),
      'metadata': _safelyVisitNodeList(node.metadata),
      "body": _safelyVisitNodeList(node.members),
    };
  }

  @override
  Map visitSimpleStringLiteral(SimpleStringLiteral node) {
    stdout.writeln('visitSimpleStringLiteral: ${node.value}');
    return {
      "type": "StringLiteral",
      "value": node.value,
    };
  }

  @override
  Map? visitBooleanLiteral(BooleanLiteral node) {
    stdout.writeln('visitBooleanLiteral: ${node.value}');
    return {
      "type": "BooleanLiteral",
      "value": node.value,
    };
  }

  @override
  Map? visitArgumentList(ArgumentList node) {
    stdout.writeln('visitArgumentList: ${node.arguments}');
    return {
      "type": "ArgumentList",
      "argumentList": _safelyVisitNodeList(node.arguments),
    };
  }

  @override
  Map? visitLabel(Label node) {
    stdout.writeln('visitLabel: ${node.label}');
    return _safelyVisitNode(node.label);
  }

  @override
  Map? visitExtendsClause(ExtendsClause node) {
    stdout.writeln('visitExtendsClause: ${node.superclass}');
    return _safelyVisitNode(node.superclass);
  }

  @override
  Map? visitImplementsClause(ImplementsClause node) {
    stdout.writeln('visitImplementsClause: ${node.interfaces}');
    return {
      "type": "ImplementsClause",
      "implements": _safelyVisitNodeList(node.interfaces)
    };
  }

  @override
  Map? visitWithClause(WithClause node) {
    stdout.writeln('visitWithClause: $node');
    return _safelyVisitNode(node);
  }

  @override
  Map? visitPropertyAccess(PropertyAccess node) {
    stdout
        .writeln('visitPropertyAccess: ${node.propertyName}>>>${node.target}');
    return {
      "type": "PropertyAccess",
      "id": _safelyVisitNode(node.propertyName),
      "expression": _safelyVisitNode(node.target),
    };
  }
}

final FeatureSet language_2_18_5 = FeatureSet.fromEnableFlags2(
  sdkLanguageVersion: Version.parse('2.18.5'),
  flags: [],
);

///生成AST
Future<Map> astGenerate(String path) async {
  if (path.isEmpty) {
    stdout.writeln("No file found");
  } else {
    if (await FileSystemEntity.isDirectory(path)) {
      stderr.writeln('error: $path is a directory');
    } else {
      try {
        var parseResult = parseFile(path: path, featureSet: language_2_18_5);
        var compilationUnit = parseResult.unit;
        //遍历AST DemoAstVisitor MyAstVisitor
        var astData = compilationUnit.accept(MyAstVisitor());
        stdout.writeln('\n\n');
        stdout.writeln(jsonEncode(astData));
        return Future.value(astData);
      } catch (e) {
        stdout.writeln('Parse file error: ${e.toString()}');
      }
    }
  }
  return Future.value({});
}
