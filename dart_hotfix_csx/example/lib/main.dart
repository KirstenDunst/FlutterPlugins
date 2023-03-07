import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dsl/listview_dsl.dart';
import 'package:dart_hotfix_csx/dart_hotfix_csx.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // debug模式开启
      showPerformanceOverlay: kDebugMode,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with \"flutter run\". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // \"hot reload\" (press \"r\" in the console where you ran \"flutter run\",
        // or simply save your changes to \"hot reload\" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('DSL模板'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _DSLListPage()));
              },
            ),
            ListTile(
              title: const Text('动态渲染'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => _DynamicFlutterList()));
              },
            ),
          ],
        ));
  }
}

class _DSLListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSL模板列表'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('ListView'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ListViewDSL()));
            },
          ),
        ],
      ),
    );
  }
}

class _DynamicFlutterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态渲染列表'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('ListView'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AstStatefulWidget(jsonDecode(listViewAst) as Map))),
          ),
        ],
      ),
    );
  }
}
//执行 dart lib/node/translation_node.dart -f example/lib/dsl/listview_dsl.dart 生成，目前widget文件里面不支持有const标记的内容，可以先取消掉const标记的参数

const listViewAst =
    '{"type":"Program","body":[{"type":"ClassDeclaration","id":{"type":"Identifier","name":"ListViewDSL"},"superClause":{"type":"TypeName","name":"StatefulWidget"},"implementsClause":null,"mixinClause":null,"metadata":[],"body":[{"type":"MethodDeclaration","id":{"type":"Identifier","name":"createState"},"parameters":{"type":"FormalParameterList","parameterList":[]},"typeParameters":null,"body":null,"returnType":{"type":"TypeName","name":"State"},"isAsync":false}]},{"type":"ClassDeclaration","id":{"type":"Identifier","name":"_ListViewDSLState"},"superClause":{"type":"TypeName","name":"State"},"implementsClause":null,"mixinClause":null,"metadata":[],"body":[{"type":"MethodDeclaration","id":{"type":"Identifier","name":"build"},"parameters":{"type":"FormalParameterList","parameterList":[{"type":"SimpleFormalParameter","paramType":{"type":"TypeName","name":"BuildContext"},"name":"context"}]},"typeParameters":null,"body":{"type":"BlockStatement","body":[{"type":"ReturnStatement","argument":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"Scaffold"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"AppBar"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"PrefixedIdentifier","prefix":{"type":"Identifier","name":"Colors"},"identifier":{"type":"Identifier","name":"red"}},"id":{"type":"Identifier","name":"backgroundColor"}},{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"Text"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"StringLiteral","value":"ListViewDSL"},{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"TextStyle"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"NumericLiteral","value":20},"id":{"type":"Identifier","name":"fontSize"}},{"type":"NamedExpression","expression":{"type":"PrefixedIdentifier","prefix":{"type":"Identifier","name":"Colors"},"identifier":{"type":"Identifier","name":"white"}},"id":{"type":"Identifier","name":"color"}}]}},"id":{"type":"Identifier","name":"style"}}]}},"id":{"type":"Identifier","name":"title"}},{"type":"NamedExpression","expression":{"type":"BooleanLiteral","value":true},"id":{"type":"Identifier","name":"centerTitle"}}]}},"id":{"type":"Identifier","name":"appBar"}},{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"MemberExpression","object":{"type":"Identifier","name":"ListView"},"property":{"type":"Identifier","name":"builder"}},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"FunctionExpression","parameters":{"type":"FormalParameterList","parameterList":[{"type":"SimpleFormalParameter","paramType":null,"name":"context"},{"type":"SimpleFormalParameter","paramType":null,"name":"index"}]},"body":{"type":"BlockStatement","body":[{"type":"ReturnStatement","argument":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"Container"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"MemberExpression","object":{"type":"Identifier","name":"EdgeInsets"},"property":{"type":"Identifier","name":"only"}},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"NumericLiteral","value":16},"id":{"type":"Identifier","name":"left"}},{"type":"NamedExpression","expression":{"type":"NumericLiteral","value":16},"id":{"type":"Identifier","name":"right"}}]}},"id":{"type":"Identifier","name":"padding"}},{"type":"NamedExpression","expression":{"type":"PrefixedIdentifier","prefix":{"type":"Identifier","name":"Alignment"},"identifier":{"type":"Identifier","name":"centerLeft"}},"id":{"type":"Identifier","name":"alignment"}},{"type":"NamedExpression","expression":{"type":"PropertyAccess","id":{"type":"Identifier","name":"shade300"},"expression":{"type":"PrefixedIdentifier","prefix":{"type":"Identifier","name":"Colors"},"identifier":{"type":"Identifier","name":"lightBlue"}}},"id":{"type":"Identifier","name":"color"}},{"type":"NamedExpression","expression":{"type":"NumericLiteral","value":45},"id":{"type":"Identifier","name":"height"}},{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"Text"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"StringLiteral","value":"Hellow World"},{"type":"NamedExpression","expression":{"type":"MethodInvocation","typeArguments":null,"callee":{"type":"Identifier","name":"TextStyle"},"argumentList":{"type":"ArgumentList","argumentList":[{"type":"NamedExpression","expression":{"type":"PrefixedIdentifier","prefix":{"type":"Identifier","name":"Colors"},"identifier":{"type":"Identifier","name":"white"}},"id":{"type":"Identifier","name":"color"}},{"type":"NamedExpression","expression":{"type":"NumericLiteral","value":18},"id":{"type":"Identifier","name":"fontSize"}}]}},"id":{"type":"Identifier","name":"style"}}]}},"id":{"type":"Identifier","name":"child"}}]}}}]},"isAsync":false},"id":{"type":"Identifier","name":"itemBuilder"}},{"type":"NamedExpression","expression":{"type":"NumericLiteral","value":50},"id":{"type":"Identifier","name":"itemCount"}}]}},"id":{"type":"Identifier","name":"body"}}]}}}]},"returnType":{"type":"TypeName","name":"Widget"},"isAsync":false}]}]}';
