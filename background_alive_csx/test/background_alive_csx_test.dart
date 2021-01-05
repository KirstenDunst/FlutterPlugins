/*
 * @Author: Cao Shixin
 * @Date: 2021-01-05 15:53:19
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 16:10:18
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('background_alive_csx');

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
