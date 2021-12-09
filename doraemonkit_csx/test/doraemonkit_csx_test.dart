/*
 * @Author: Cao Shixin
 * @Date: 2021-02-04 17:28:14
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 12:03:53
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('doraemonkit_csx');

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
