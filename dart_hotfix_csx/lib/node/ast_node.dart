import 'dart:io';

enum AstNodeName {
  identifier,
  prefixedIdentifier,
  numericLiteral,
  stringLiteral,
  booleanLiteral,
  setOrMapLiteral,
  mapLiteralEntry,
  listLiteral,
  namedExpression,
  memberExpression,
  methodInvocation,
  fieldDeclaration,
  annotation,
  propertyAccess,
  argumentList,
  ifStatement,
  forStatement,
  switchStatement,
  switchCase,
  switchDefault,
  returnStatement,
  blockStatement,
  formalParameterList,
  simpleFormalParameter,
  typeName,
  classDeclaration,
  functionDeclaration,
  methodDeclaration,
  variableDeclarator,
  variableDeclarationList,
  binaryExpression,
  assignmentExpression,
  functionExpression,
  prefixExpression,
  awaitExpression,
  expressionStatement,
  indexExpression,
  program
}

String astNodeNameValue(AstNodeName nodeName) {
  var temp = nodeName.toString().split(".")[1];
  return "${temp[0].toUpperCase()}${temp.substring(1)}";
}

///ast node base class
abstract class AstNode {
  Map ast = {};
  String _type = '';

  AstNode({required this.ast, String? type}) {
    if (type != null) {
      _type = type;
    } else {
      _type = ast['type'];
    }
  }

  String get type => _type;

  Map toAst();
}

class Identifier extends AstNode {
  String name;

  Identifier(this.name, Map ast) : super(ast: ast);

  factory Identifier.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.identifier)) {
      throw ArgumentError(
          'Identifier.fromAst: type is not AstNodeName.identifier');
    }
    return Identifier(ast['name'], ast);
  }

  @override
  Map toAst() => ast;
}

/// grammar like (prefix.identifier), eg: People.name
class PrefixedIdentifier extends AstNode {
  String identifier;
  String prefix;

  PrefixedIdentifier(this.identifier, this.prefix, Map ast) : super(ast: ast);

  factory PrefixedIdentifier.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.prefixedIdentifier)) {
      throw ArgumentError(
          'PrefixedIdentifier.fromAst: type is not AstNodeName.prefixedIdentifier');
    }
    return PrefixedIdentifier(Identifier.fromAst(ast['identifier']).name,
        Identifier.fromAst(ast['prefix']).name, ast);
  }

  @override
  Map toAst() => ast;
}

class StringLiteral extends AstNode {
  String value;

  StringLiteral(this.value, Map ast) : super(ast: ast);

  factory StringLiteral.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.stringLiteral)) {
      throw ArgumentError(
          'StringLiteral.fromAst: type is not AstNodeName.stringLiteral');
    }
    return StringLiteral(ast['value'], ast);
  }

  @override
  Map toAst() => ast;
}

class NumericLiteral extends AstNode {
  num value;

  NumericLiteral(this.value, Map ast) : super(ast: ast);

  factory NumericLiteral.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.numericLiteral)) {
      throw ArgumentError(
          'NumericLiteral.fromAst: type is not AstNodeName.numericLiteral');
    }
    return NumericLiteral(ast['value'], ast);
  }

  @override
  Map toAst() => ast;
}

class BooleanLiteral extends AstNode {
  bool value;

  BooleanLiteral(this.value, Map ast) : super(ast: ast);

  factory BooleanLiteral.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.booleanLiteral)) {
      throw ArgumentError(
          'BooleanLiteral.fromAst: type is not AstNodeName.booleanLiteral');
    }
    return BooleanLiteral(ast['value'], ast);
  }

  @override
  Map toAst() => ast;
}

class MapLiteralEntry extends AstNode {
  String key;
  Expression value;

  MapLiteralEntry(this.key, this.value, Map ast) : super(ast: ast);

  factory MapLiteralEntry.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.mapLiteralEntry)) {
      throw ArgumentError(
          'MapLiteralEntry.fromAst: type is not AstNodeName.mapLiteralEntry');
    }
    return MapLiteralEntry(
        _parseStringValue(ast['key']), Expression(ast['value']), ast);
  }

  @override
  Map toAst() => ast;
}

class MapLiteral extends AstNode {
  Map<String, Expression> elements;

  MapLiteral(this.elements, Map ast) : super(ast: ast);

  factory MapLiteral.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.setOrMapLiteral)) {
      throw ArgumentError(
          'MapLiteral.fromAst: type is not AstNodeName.setOrMapLiteral');
    }
    var astElements = ast['elements'] as List;
    var entries = <String, Expression>{};
    for (var e in astElements) {
      var entry = MapLiteralEntry.fromAst(e);
      entries[entry.key] = entry.value;
    }
    return MapLiteral(entries, ast);
  }

  @override
  Map toAst() => ast;
}

class ListLiteral extends AstNode {
  List<Expression> elements;

  ListLiteral(this.elements, Map ast) : super(ast: ast);

  factory ListLiteral.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.listLiteral)) {
      throw ArgumentError(
          'ListLiteral.fromAst: type is not AstNodeName.listLiteral');
    }
    var astElements = ast['elements'] as List;
    var items = <Expression>[];
    for (var e in astElements) {
      items.add(Expression.fromAst(e));
    }
    return ListLiteral(items, ast);
  }

  @override
  Map toAst() => ast;
}

class Annotation extends AstNode {
  String name;
  List<Expression> argumentList;

  Annotation(this.name, this.argumentList, Map ast) : super(ast: ast);

  factory Annotation.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.annotation)) {
      throw ArgumentError(
          'Annotation.fromAst: type is not AstNodeName.annotation');
    }
    return Annotation(Identifier.fromAst(ast['id']).name,
        _parseArgumentList(ast['argumentList']), ast);
  }

  @override
  Map toAst() => ast;
}

class MemberExpression extends AstNode {
  Expression object;
  String property;

  MemberExpression(this.object, this.property, Map ast) : super(ast: ast);

  factory MemberExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.memberExpression)) {
      throw ArgumentError(
          'MemberExpression.fromAst: type is not AstNodeName.memberExpression');
    }
    return MemberExpression(Expression.fromAst(ast['object']),
        Identifier.fromAst(ast['property']).name, ast);
  }

  @override
  Map toAst() => ast;
}

class SimpleFormalParameter extends AstNode {
  TypeName? paramType;
  String name;

  SimpleFormalParameter(this.paramType, this.name, Map ast) : super(ast: ast);

  factory SimpleFormalParameter.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.simpleFormalParameter)) {
      throw ArgumentError(
          'SimpleFormalParameter.fromAst: type is not AstNodeName.simpleFormalParameter');
    }
    var hasTypeName = ast.containsKey('paramType') && ast['paramType'] is Map;
    return SimpleFormalParameter(
        hasTypeName ? TypeName.fromAst(ast['paramType']) : null,
        ast['name'],
        ast);
  }

  @override
  Map toAst() => ast;
}

class TypeName extends AstNode {
  String name;

  TypeName(this.name, Map ast) : super(ast: ast);

  factory TypeName.fromAst(Map ast) {
    if (ast['type'] != 'TypeName') {
      throw ArgumentError('TypeName.fromAst: type is not AstNodeName.TypeName');
    }
    return TypeName(ast['name'], ast);
  }

  @override
  Map toAst() => ast;
}

class BlockStatement extends AstNode {
  ///代码块中各表达式
  List<Expression> body;

  BlockStatement(this.body, Map ast) : super(ast: ast);

  factory BlockStatement.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.blockStatement)) {
      throw ArgumentError(
          'BlockStatement.fromAst: type is not AstNodeName.blockStatement');
    }
    var astBody = ast['body'] as List;
    var bodies = <Expression>[];
    for (var arg in astBody) {
      bodies.add(Expression.fromAst(arg));
    }
    return BlockStatement(bodies, ast);
  }

  @override
  Map toAst() => ast;
}

class MethodDeclaration extends AstNode {
  String name;
  List<SimpleFormalParameter> parameterList;
  BlockStatement? body;
  bool isAsync;
  MethodDeclaration(this.name, this.parameterList, this.body, Map ast,
      {this.isAsync = false})
      : super(ast: ast);

  factory MethodDeclaration.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.methodDeclaration)) {
      throw ArgumentError(
          'MethodDeclaration.fromAst: type is not AstNodeName.methodDeclaration');
    }
    var parameters = <SimpleFormalParameter>[];
    if (ast['parameters'] != null &&
        ast['parameters']['parameterList'] != null) {
      var astParameters = ast['parameters']['parameterList'] as List;
      for (var arg in astParameters) {
        parameters.add(SimpleFormalParameter.fromAst(arg));
      }
    }
    var contentBlock = ast.containsKey('body') && ast['body'] is Map;
    return MethodDeclaration(
        Identifier.fromAst(ast['id']).name,
        parameters,
        contentBlock ? BlockStatement.fromAst(ast['body']) : null,
        isAsync: ast['isAsync'] as bool,
        ast);
  }

  @override
  Map toAst() => ast;
}

class FunctionDeclaration extends AstNode {
  ///函数名称
  String name;
  FunctionExpression expression;

  FunctionDeclaration(this.name, this.expression, Map ast) : super(ast: ast);

  factory FunctionDeclaration.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.functionDeclaration)) {
      throw ArgumentError(
          'FunctionDeclaration.fromAst: type is not AstNodeName.functionDeclaration');
    }
    return FunctionDeclaration(Identifier.fromAst(ast['id']).name,
        FunctionExpression.fromAst(ast['expression']), ast);
  }

  @override
  Map toAst() => ast;
}

class MethodInvocation extends AstNode {
  Expression callee;
  List<Expression> argumentList;
  SelectAstClass? selectAstClass;

  MethodInvocation(this.callee, this.argumentList, this.selectAstClass, Map ast)
      : super(ast: ast);

  factory MethodInvocation.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.methodInvocation)) {
      throw ArgumentError(
          'MethodInvocation.fromAst: type is not AstNodeName.methodInvocation');
    }
    var hasSelectAstClass =
        ast.containsKey('selectAstClass') && ast['selectAstClass'] is Map;
    return MethodInvocation(
        Expression.fromAst(ast['callee']),
        _parseArgumentList(ast['argumentList']),
        hasSelectAstClass
            ? SelectAstClass.fromAst(ast['selectAstClass'])
            : null,
        ast);
  }

  @override
  Map toAst() => ast;
}

class NamedExpression extends AstNode {
  String label;
  Expression expression;

  NamedExpression(this.label, this.expression, Map ast) : super(ast: ast);

  factory NamedExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.namedExpression)) {
      throw ArgumentError(
          'NamedExpression.fromAst: type is not AstNodeName.namedExpression');
    }
    return NamedExpression(Identifier.fromAst(ast['id']).name,
        Expression.fromAst(ast['expression']), ast);
  }

  @override
  Map toAst() => ast;
}

class PrefixExpression extends AstNode {
  ///操作的变量名称
  String argument;

  ///操作符
  String operator;

  ///是否操作符前置
  bool prefix;

  PrefixExpression(this.argument, this.operator, this.prefix, Map ast)
      : super(ast: ast);

  factory PrefixExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.prefixExpression)) {
      throw ArgumentError(
          'PrefixExpression.fromAst: type is not AstNodeName.prefixExpression');
    }
    return PrefixExpression(Identifier.fromAst(ast['argument']).name,
        ast['operator'], ast['prefix'] as bool, ast);
  }
  @override
  Map toAst() => ast;
}

class VariableDeclarator extends AstNode {
  String name;
  Expression init;

  VariableDeclarator(this.name, this.init, Map ast) : super(ast: ast);

  factory VariableDeclarator.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.variableDeclarator)) {
      throw ArgumentError(
          'VariableDeclarator.fromAst: type is not AstNodeName.variableDeclarator');
    }
    return VariableDeclarator(Identifier.fromAst(ast['id']).name,
        Expression.fromAst(ast['init']), ast);
  }

  @override
  Map toAst() => ast;
}

class VariableDeclarationList extends AstNode {
  String typeAnnotation;
  List<VariableDeclarator> declarationList;

  VariableDeclarationList(this.typeAnnotation, this.declarationList, Map ast)
      : super(ast: ast);

  factory VariableDeclarationList.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.variableDeclarationList)) {
      throw ArgumentError(
          'VariableDeclarationList.fromAst: type is not AstNodeName.variableDeclarationList');
    }
    var astDeclarations = ast['declarations'] as List;
    var declarations = <VariableDeclarator>[];
    for (var arg in astDeclarations) {
      declarations.add(VariableDeclarator.fromAst(arg));
    }
    return VariableDeclarationList(
        Identifier.fromAst(ast['typeAnnotation']).name, declarations, ast);
  }

  @override
  Map toAst() => ast;
}

class FieldDeclaration extends AstNode {
  VariableDeclarationList fields;
  List<Annotation> metadata;

  FieldDeclaration(this.fields, this.metadata, Map ast) : super(ast: ast);

  factory FieldDeclaration.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.fieldDeclaration)) {
      throw ArgumentError(
          'FieldDeclaration.fromAst: type is not AstNodeName.FieldDeclaration');
    }
    var astMetadata = ast['metadata'] as List;
    var metadatas = <Annotation>[];
    for (var arg in astMetadata) {
      metadatas.add(Annotation.fromAst(arg));
    }
    return FieldDeclaration(
        VariableDeclarationList.fromAst(ast['fields']), metadatas, ast);
  }

  @override
  Map toAst() => ast;
}

class FunctionExpression extends AstNode {
  ///函数参数
  List<SimpleFormalParameter> parameterList;
  BlockStatement body;

  ///是否异步函数
  bool isAsync;

  FunctionExpression(this.parameterList, this.body, Map ast,
      {this.isAsync = false})
      : super(ast: ast);

  factory FunctionExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.functionExpression)) {
      throw ArgumentError(
          'FunctionExpression.fromAst: type is not AstNodeName.functionExpression');
    }
    var astParameters = ast['parameters']['parameterList'] as List;
    var parameters = <SimpleFormalParameter>[];
    for (var p in astParameters) {
      parameters.add(SimpleFormalParameter.fromAst(p));
    }
    return FunctionExpression(
        parameters,
        BlockStatement.fromAst(ast['body']),
        isAsync: ast['isAsync'] as bool,
        ast);
  }

  @override
  Map toAst() => ast;
}

class BinaryExpression extends AstNode {
  ///运算符
  /// * +
  /// * -
  /// * *
  /// * /
  /// * <
  /// * >
  /// * <=
  /// * >=
  /// * ==
  /// * &&
  /// * ||
  /// * %
  /// * <<
  /// * |
  /// * &
  /// * >>
  ///
  String operator;

  ///左操作表达式
  Expression left;

  ///右操作表达式
  Expression right;

  BinaryExpression(this.operator, this.left, this.right, Map ast)
      : super(ast: ast);

  factory BinaryExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.binaryExpression)) {
      throw ArgumentError(
          'BinaryExpression.fromAst: type is not AstNodeName.binaryExpression');
    }
    return BinaryExpression(ast['operator'], Expression.fromAst(ast['left']),
        Expression.fromAst(ast['right']), ast);
  }

  @override
  Map toAst() => ast;
}

class AssignmentExpression extends AstNode {
  String operator;
  Expression left;
  Expression right;

  AssignmentExpression(this.operator, this.left, this.right, Map ast)
      : super(ast: ast);

  factory AssignmentExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.assignmentExpression)) {
      throw ArgumentError(
          'AssignmentExpression.fromAst: type is not AstNodeName.assignmentExpression');
    }
    return AssignmentExpression(_parseStringValue(ast['operater']),
        Expression.fromAst(ast['left']), Expression.fromAst(ast['right']), ast);
  }

  @override
  Map toAst() => ast;
}

class AwaitExpression extends AstNode {
  MethodInvocation expression;

  AwaitExpression(this.expression, Map ast) : super(ast: ast);

  factory AwaitExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.awaitExpression)) {
      throw ArgumentError(
          'AwaitExpression.fromAst: type is not AstNodeName.awaitExpression');
    }
    return AwaitExpression(MethodInvocation.fromAst(ast['expression']), ast);
  }
  @override
  Map toAst() => ast;
}

class ClassDeclaration extends AstNode {
  String name;
  String superClause;
  List<Expression> body;

  ClassDeclaration(this.name, this.superClause, this.body, Map ast)
      : super(ast: ast);

  factory ClassDeclaration.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.classDeclaration)) {
      throw ArgumentError(
          'ClassDeclaration.fromAst: type is not AstNodeName.classDeclaration');
    }
    var astBody = ast['body'] as List;
    var bodies = <Expression>[];
    for (var arg in astBody) {
      bodies.add(Expression.fromAst(arg));
    }
    return ClassDeclaration(Identifier.fromAst(ast['id']).name,
        TypeName.fromAst(ast['superClause']).name, bodies, ast);
  }

  @override
  Map toAst() => ast;
}

class IfStatement extends AstNode {
  ///判断条件
  BinaryExpression condition;

  ///true 执行代码块
  BlockStatement consequent;

  ///false 执行代码块
  BlockStatement alternate;

  IfStatement(this.condition, this.consequent, this.alternate, Map ast)
      : super(ast: ast);

  factory IfStatement.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.ifStatement)) {
      throw ArgumentError(
          'IfStatement.fromAst: type is not AstNodeName.ifStatement');
    }
    return IfStatement(
        BinaryExpression.fromAst(ast['condition']),
        BlockStatement.fromAst(ast['consequent']),
        BlockStatement.fromAst(ast['alternate']),
        ast);
  }
  @override
  Map toAst() => ast;
}

class ForStatement extends AstNode {
  ForLoopParts forLoopParts;
  BlockStatement body;

  ForStatement(this.forLoopParts, this.body, Map ast) : super(ast: ast);

  factory ForStatement.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.forStatement)) {
      throw ArgumentError(
          'ForStatement.fromAst: type is not AstNodeName.forStatement');
    }
    return ForStatement(ForLoopParts.fromAst(ast['forLoopParts']),
        BlockStatement.fromAst(ast['body']), ast);
  }
  @override
  Map toAst() => ast;
}

class ForLoopParts extends AstNode {
  static const String forPartsWithDeclarations = "ForPartsWithDeclarations";
  static const String forPartsWithExpression = "ForPartsWithExpression";
  static const String forEachPartsWithDeclaration =
      "ForEachPartsWithDeclaration";

  ///初始化定义的值
  VariableDeclarationList? variableList;

  ///初始化赋值的值
  AssignmentExpression? initialization;

  ///循环判断条件
  BinaryExpression? condition;

  ///循环步进值
  Expression? updater;

  //for...in... 遍历迭代的数据集合变量名称
  String? iterable;
  //for...in... 遍历迭代值
  String? loopVariable;

  ForLoopParts(
    Map ast, {
    this.variableList,
    this.initialization,
    this.condition,
    this.updater,
    this.iterable,
    this.loopVariable,
  }) : super(ast: ast);

  factory ForLoopParts.fromAst(Map ast) {
    if (ast['type'] == forPartsWithDeclarations) {
      var updaters = ast['updaters'] as List;
      return ForLoopParts(
        variableList: VariableDeclarationList.fromAst(ast['variableList']),
        condition: BinaryExpression.fromAst(ast['condition']),
        updater: updaters.isNotEmpty ? Expression.fromAst(updaters[0]) : null,
        ast,
      );
    } else if (ast['type'] == forPartsWithExpression) {
      var updaters = ast['updaters'] as List;
      return ForLoopParts(
        initialization: AssignmentExpression.fromAst(ast['initialization']),
        condition: BinaryExpression.fromAst(ast['condition']),
        updater: updaters.isNotEmpty ? Expression.fromAst(updaters[0]) : null,
        ast,
      );
    } else if (ast['type'] == forEachPartsWithDeclaration) {
      return ForLoopParts(
          iterable: Identifier.fromAst(ast['iterable']).name,
          loopVariable: Identifier.fromAst(ast['loopVariable']['id']).name,
          {});
    }
    throw ArgumentError(
        'ForLoopParts.fromAst: type is not ForPartsWithDeclarations、 ForPartsWithExpression、ForEachPartsWithDeclaration');
  }
  @override
  Map toAst() => ast;
}

class SwitchStatement extends AstNode {
  Expression checkValue;
  List<SwitchCase> body;

  SwitchStatement(this.checkValue, this.body, Map ast) : super(ast: ast);

  factory SwitchStatement.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.switchStatement)) {
      throw ArgumentError(
          'SwitchStatement.fromAst: type is not AstNodeName.switchStatement');
    }
    var list = ast['body'] as List;
    var caseList = <SwitchCase>[];
    for (var s in list) {
      caseList.add(SwitchCase.fromAst(s));
    }
    return SwitchStatement(
        Expression.fromAst(ast['checkValue']), caseList, ast);
  }
  @override
  Map toAst() => ast;
}

class SwitchCase extends AstNode {
  Expression? condition;
  List<Expression> statements;
  bool isDefault;
  SwitchCase(this.condition, this.statements, this.isDefault, Map ast)
      : super(ast: ast);

  factory SwitchCase.fromAst(Map ast) {
    var statements = <Expression>[];
    var list = ast['statements'] as List;
    for (var s in list) {
      statements.add(Expression.fromAst(s));
    }
    if (ast['type'] == astNodeNameValue(AstNodeName.switchCase)) {
      return SwitchCase(
          Expression.fromAst(ast['condition']), statements, false, ast);
    } else if (ast['type'] == astNodeNameValue(AstNodeName.switchDefault)) {
      return SwitchCase(null, statements, true, ast);
    }
    throw ArgumentError(
        'SwitchCase.fromAst: type is not AstNodeName.switchCase or AstNodeName.switchDefault');
  }
  @override
  Map toAst() => ast;
}

class ReturnStatement extends AstNode {
  Expression argument;

  ReturnStatement(this.argument, Map ast) : super(ast: ast);

  factory ReturnStatement.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.returnStatement)) {
      throw ArgumentError(
          'ReturnStatement.fromAst: type is not AstNodeName.returnStatement');
    }
    return ReturnStatement(Expression.fromAst(ast['argument']), ast);
  }

  @override
  Map toAst() => ast;
}

class PropertyAccess extends AstNode {
  String name;
  Expression expression;

  PropertyAccess(this.name, this.expression, Map ast) : super(ast: ast);

  factory PropertyAccess.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.propertyAccess)) {
      throw ArgumentError(
          'PropertyAccess.fromAst: type is not AstNodeName.propertyAccess');
    }
    return PropertyAccess(Identifier.fromAst(ast['id']).name,
        Expression.fromAst(ast['expression']), ast);
  }

  @override
  Map toAst() => ast;
}

class IndexExpression extends AstNode {
  Expression target;
  Expression index;

  IndexExpression(this.target, this.index, Map ast) : super(ast: ast);

  factory IndexExpression.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.indexExpression)) {
      throw ArgumentError(
          'IndexExpression.fromAst: type is not AstNodeName.indexExpression');
    }
    return IndexExpression(Expression.fromAst(ast['target']),
        Expression.fromAst(ast['index']), ast);
  }

  @override
  Map toAst() => ast;
}

class Program extends AstNode {
  List<Expression> body;

  Program(this.body, Map ast) : super(ast: ast);

  factory Program.fromAst(Map ast) {
    if (ast['type'] != astNodeNameValue(AstNodeName.program)) {
      throw ArgumentError('Program.fromAst: type is not AstNodeName.program');
    }
    var astBody = ast['body'] as List;
    var bodies = <Expression>[];
    for (var arg in astBody) {
      bodies.add(Expression.fromAst(arg));
    }
    return Program(bodies, ast);
  }

  @override
  Map toAst() => ast;
}

///通用 ast node
class Expression extends AstNode {
  AstNode _expression;

  bool isProgram;
  bool isClassDeclaration;
  bool isIdentifier;
  bool isPrefixedIdentifier;
  bool isStringLiteral;
  bool isNumericLiteral;
  bool isBooleanLiteral;
  bool isListLiteral;
  bool isMapLiteral;
  bool isMethodInvocation;
  bool isMemberExpression;
  bool isNamedExpression;
  bool isVariableDeclarationList;
  bool isBinaryExpression;
  bool isAssignmentExpression;
  bool isPropertyAccess;
  bool isMethodDeclaration;
  bool isReturnStatement;
  bool isFieldDeclaration;
  bool isFunctionExpression;
  bool isBlockStatement;
  bool isFunctionDeclaration;
  bool isAwaitExpression;
  bool isPrefixExpression;
  bool isExpressionStatement;
  bool isIfStatement;
  bool isForStatement;
  bool isSwitchStatement;
  bool isIndexExpression;

  @override
  Map toAst() => ast;

  Expression(
    this._expression, {
    this.isProgram = false,
    this.isIdentifier = false,
    this.isPrefixedIdentifier = false,
    this.isStringLiteral = false,
    this.isNumericLiteral = false,
    this.isBooleanLiteral = false,
    this.isListLiteral = false,
    this.isMapLiteral = false,
    this.isMethodInvocation = false,
    this.isMemberExpression = false,
    this.isNamedExpression = false,
    this.isVariableDeclarationList = false,
    this.isBinaryExpression = false,
    this.isAssignmentExpression = false,
    this.isPropertyAccess = false,
    this.isClassDeclaration = false,
    this.isMethodDeclaration = false,
    this.isReturnStatement = false,
    this.isFieldDeclaration = false,
    this.isFunctionExpression = false,
    this.isBlockStatement = false,
    this.isFunctionDeclaration = false,
    this.isAwaitExpression = false,
    this.isPrefixExpression = false,
    this.isExpressionStatement = false,
    this.isIfStatement = false,
    this.isForStatement = false,
    this.isSwitchStatement = false,
    this.isIndexExpression = false,
    Map? ast,
  }) : super(ast: ast ?? {});

  factory Expression.fromAst(Map ast) {
    var astType = ast['type'];
    if (astType == astNodeNameValue(AstNodeName.program)) {
      return Expression(Program.fromAst(ast), isProgram: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.expressionStatement)) {
      return Expression(Expression.fromAst(ast['expression']),
          isExpressionStatement: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.identifier)) {
      return Expression(Identifier.fromAst(ast), isIdentifier: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.prefixedIdentifier)) {
      return Expression(PrefixedIdentifier.fromAst(ast),
          isPrefixedIdentifier: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.stringLiteral)) {
      return Expression(StringLiteral.fromAst(ast),
          isStringLiteral: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.numericLiteral)) {
      return Expression(NumericLiteral.fromAst(ast),
          isNumericLiteral: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.booleanLiteral)) {
      return Expression(BooleanLiteral.fromAst(ast),
          isBooleanLiteral: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.listLiteral)) {
      return Expression(ListLiteral.fromAst(ast),
          isListLiteral: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.setOrMapLiteral)) {
      return Expression(MapLiteral.fromAst(ast), isMapLiteral: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.methodInvocation)) {
      return Expression(MethodInvocation.fromAst(ast),
          isMethodInvocation: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.memberExpression)) {
      return Expression(MemberExpression.fromAst(ast),
          isMemberExpression: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.namedExpression)) {
      return Expression(NamedExpression.fromAst(ast),
          isNamedExpression: true, ast: ast);
    } else if (astType ==
        astNodeNameValue(AstNodeName.variableDeclarationList)) {
      return Expression(VariableDeclarationList.fromAst(ast),
          isVariableDeclarationList: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.binaryExpression)) {
      return Expression(BinaryExpression.fromAst(ast),
          isBinaryExpression: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.assignmentExpression)) {
      return Expression(AssignmentExpression.fromAst(ast),
          isAssignmentExpression: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.propertyAccess)) {
      return Expression(PropertyAccess.fromAst(ast),
          isPropertyAccess: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.classDeclaration)) {
      return Expression(ClassDeclaration.fromAst(ast),
          isClassDeclaration: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.methodDeclaration)) {
      return Expression(MethodDeclaration.fromAst(ast),
          isMethodDeclaration: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.returnStatement)) {
      return Expression(ReturnStatement.fromAst(ast),
          isReturnStatement: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.fieldDeclaration)) {
      return Expression(FieldDeclaration.fromAst(ast),
          isFieldDeclaration: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.functionExpression)) {
      return Expression(FunctionExpression.fromAst(ast),
          isFunctionExpression: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.blockStatement)) {
      return Expression(BlockStatement.fromAst(ast),
          isBlockStatement: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.functionDeclaration)) {
      return Expression(FunctionDeclaration.fromAst(ast),
          isFunctionDeclaration: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.awaitExpression)) {
      return Expression(AwaitExpression.fromAst(ast),
          isAwaitExpression: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.prefixExpression)) {
      return Expression(PrefixExpression.fromAst(ast),
          isPrefixExpression: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.ifStatement)) {
      return Expression(IfStatement.fromAst(ast),
          isIfStatement: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.forStatement)) {
      return Expression(ForStatement.fromAst(ast),
          isForStatement: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.switchStatement)) {
      return Expression(SwitchStatement.fromAst(ast),
          isSwitchStatement: true, ast: ast);
    } else if (astType == astNodeNameValue(AstNodeName.indexExpression)) {
      return Expression(IndexExpression.fromAst(ast),
          isIndexExpression: true, ast: ast);
    }
    throw ArgumentError('Expression astType 未匹配：$astType');
  }

  Expression get asExpression => _expression as Expression;

  Identifier get asIdentifier => _expression as Identifier;

  PrefixedIdentifier get asPrefixedIdentifier =>
      _expression as PrefixedIdentifier;

  StringLiteral get asStringLiteral => _expression as StringLiteral;

  NumericLiteral get asNumericLiteral => _expression as NumericLiteral;

  BooleanLiteral get asBooleanLiteral => _expression as BooleanLiteral;

  ListLiteral get asListLiteral => _expression as ListLiteral;

  MapLiteral get asMapLiteral => _expression as MapLiteral;

  MethodInvocation get asMethodInvocation => _expression as MethodInvocation;

  MemberExpression get asMemberExpression => _expression as MemberExpression;

  NamedExpression get asNamedExpression => _expression as NamedExpression;

  VariableDeclarationList get asVariableDeclarationList =>
      _expression as VariableDeclarationList;

  BinaryExpression get asBinaryExpression => _expression as BinaryExpression;

  AssignmentExpression get asAssignmentExpression =>
      _expression as AssignmentExpression;

  PropertyAccess get asPropertyAccess => _expression as PropertyAccess;

  Program get asProgram => _expression as Program;

  ClassDeclaration get asClassDeclaration => _expression as ClassDeclaration;

  MethodDeclaration get asMethodDeclaration => _expression as MethodDeclaration;

  ReturnStatement get asReturnStatement => _expression as ReturnStatement;

  FieldDeclaration get asFieldDeclaration => _expression as FieldDeclaration;

  FunctionExpression get asFunctionExpression =>
      _expression as FunctionExpression;

  BlockStatement get asBlockStatement => _expression as BlockStatement;

  AwaitExpression get asAwaitExpression => _expression as AwaitExpression;

  PrefixExpression get asPrefixExpression => _expression as PrefixExpression;

  IfStatement get asIfStatement => _expression as IfStatement;

  ForStatement get asForStatement => _expression as ForStatement;

  SwitchStatement get asSwitchStatement => _expression as SwitchStatement;

  FunctionDeclaration get asFunctionDeclaration =>
      _expression as FunctionDeclaration;
  IndexExpression get asIndexExpression => _expression as IndexExpression;
}

class SelectAstClass {
  String? name;
  String? metadata;
  String? version;
  String? filePath;
  String? classId;

  SelectAstClass(
      {this.name, this.metadata, this.version, this.filePath, this.classId});
  factory SelectAstClass.fromAst(Map ast) {
    return SelectAstClass(
        name: ast['name'],
        metadata: ast['metadata'],
        version: ast['version'],
        filePath: ast['filePath'],
        classId: ast['classId']);
  }
}

///解析ArgumentList 字段
List<Expression> _parseArgumentList(Map ast) {
  var astArguments = ast['argumentList'] as List;
  var arguments = <Expression>[];
  for (var arg in astArguments) {
    arguments.add(Expression.fromAst(arg));
  }
  return arguments;
}

num _parseNumericValue(Map ast) {
  num n = 0;
  if (ast['type'] == astNodeNameValue(AstNodeName.numericLiteral)) {
    n = ast['value'] as num;
  }
  return n;
}

String _parseStringValue(Map ast) {
  String s = "";
  if (ast['type'] == astNodeNameValue(AstNodeName.stringLiteral)) {
    s = ast['value'] as String;
  }
  return s;
}

bool _parseBooleanValue(Map ast) {
  bool b = false;
  if (ast['type'] == astNodeNameValue(AstNodeName.booleanLiteral)) {
    b = ast['value'] as bool;
  }
  return b;
}

///解析基本数据类型
dynamic _parseLiteral(Map ast) {
  var valueType = ast['type'];
  if (valueType == astNodeNameValue(AstNodeName.stringLiteral)) {
    return _parseStringValue(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.numericLiteral)) {
    return _parseNumericValue(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.booleanLiteral)) {
    return _parseBooleanValue(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.setOrMapLiteral)) {
    return MapLiteral.fromAst(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.listLiteral)) {
    return ListLiteral.fromAst(ast);
  }

  return null;
}

///解析File 对象 ast
File? parseFileObject(MethodInvocation fileMethod) {
  var callee = fileMethod.callee;
  if (callee.isIdentifier && callee.asIdentifier.name == 'File') {
    var argumentList = fileMethod.argumentList;
    if (argumentList.isNotEmpty && argumentList[0].isStringLiteral) {
      var path = argumentList[0].asStringLiteral.value;
      return File(path);
    }
  }
  return null;
}
