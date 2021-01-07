/*
 * @Author: Cao Shixin
 * @Date: 2021-01-06 16:18:56
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-06 17:07:21
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('image_compress_csx');

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
