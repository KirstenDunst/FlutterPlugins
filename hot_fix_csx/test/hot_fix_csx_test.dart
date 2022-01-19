/*
 * @Author: Cao Shixin
 * @Date: 2022-01-19 14:57:55
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-19 15:09:35
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('hot_fix_csx');

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
