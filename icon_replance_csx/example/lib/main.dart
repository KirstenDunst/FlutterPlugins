import 'package:flutter/material.dart';
import 'package:icon_replance_csx/icon_replance_csx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () => IconReplanceCsx().removeSysAlert(),
              child: Text('remove alert'),
            ),
            ElevatedButton(
              onPressed: () => IconReplanceCsx().resetSysAlert(),
              child: Text('reset alert'),
            ),
            ElevatedButton(
              onPressed: () => NormalTool.changeIcon('春'),
              child: Text('更换春icon'),
            ),
            ElevatedButton(
              onPressed: () => NormalTool.changeIcon('夏'),
              child: Text('更换夏icon'),
            ),
            ElevatedButton(
              onPressed: () => NormalTool.changeIcon('秋'),
              child: Text('更换秋icon'),
            ),
            ElevatedButton(
              onPressed: () => NormalTool.changeIcon('冬'),
              child: Text('更换冬icon'),
            ),
            ElevatedButton(
              onPressed: () => NormalTool.changeIcon(null),
              child: Text('恢复原来'),
            ),
          ],
        ),
      ),
    );
  }
}

class NormalTool {
  static Future changeIcon(String? iconName) async {
    await IconReplanceCsx().removeSysAlert();
    var result = await IconReplanceCsx().changeIcon(iconName);
    await IconReplanceCsx().resetSysAlert();
    print('${result?.toJson()}');
  }
}
