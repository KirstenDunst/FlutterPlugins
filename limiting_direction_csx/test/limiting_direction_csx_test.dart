/*
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:12:14
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 15:31:36
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('limiting_direction_csx');

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
