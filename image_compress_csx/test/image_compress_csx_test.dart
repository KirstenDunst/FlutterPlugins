import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_compress_csx/image_compress_csx.dart';

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

  test('getPlatformVersion', () async {
    expect(await ImageCompressCsx.platformVersion, '42');
  });
}
