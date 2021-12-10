/*
 * @Author: Cao Shixin
 * @Date: 2021-12-10 09:13:34
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-12-10 09:36:57
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('common_plugin_csx');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  
}
